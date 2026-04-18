import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/core/utils/app_formatters.dart';
import 'package:rentora_app/models/cart_model.dart';
import 'package:rentora_app/models/product_model.dart';
import 'package:rentora_app/controllers/transaction_controller.dart';
import 'package:rentora_app/controllers/user_controller.dart';
import 'package:rentora_app/models/transaction_model.dart';
import 'order_detail_screen.dart';

class SellerOrderScreen extends StatefulWidget {
  const SellerOrderScreen({super.key});

  @override
  State<SellerOrderScreen> createState() => _SellerOrderScreenState();
}

class _SellerOrderScreenState extends State<SellerOrderScreen> {
  final TransactionController _transactionController = TransactionController();
  List<TransactionModel> _transactions = [];
  bool _loading = true;
  String? _error;

  static const List<String> _tabTitles = [
    'Semua',
    'Diproses',
    'Disewa',
    'Dikembalikan',
    'Dibatalkan',
  ];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final store = await _transactionController.storeController.getStore();
      if (store == null) {
        setState(() {
          _error = 'Toko tidak ditemukan';
          _loading = false;
        });
        return;
      }

      final transactions = await _transactionController.transactionService
          .getTransactionsByStore(store.uid, [
            'Diproses',
            'Disewa',
            'Dikembalikan',
            'Dibatalkan',
          ]);

      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<TransactionModel> _transactionsByTab(String tab) {
    if (tab == 'Semua') return _transactions;
    if (tab == 'Diproses') {
      final set = {'Belum Bayar', 'Diproses', 'Dikemas', 'Dikirim'};
      return _transactions.where((t) => set.contains(t.status)).toList();
    }
    if (tab == 'Disewa') {
      return _transactions
          .where(
            (t) =>
                t.status.toLowerCase().contains('disewa') ||
                t.status == 'Sedang Disewa',
          )
          .toList();
    }
    if (tab == 'Dikembalikan') {
      final set = {'Selesai', 'Dikembalikan'};
      return _transactions.where((t) => set.contains(t.status)).toList();
    }
    if (tab == 'Dibatalkan') {
      return _transactions.where((t) => t.status == 'Dibatalkan').toList();
    }
    return [];
  }

  Widget _buildTabContent(String tab) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColor.primary),
      );
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }

    final filtered = _transactionsByTab(tab);
    if (filtered.isEmpty) {
      return const Center(child: Text('Belum ada pesanan'));
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: filtered.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final tx = filtered[index];
          return OrderProductsCard(transaction: tx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabTitles.length,
      child: Scaffold(
        backgroundColor: AppColor.backgroundLight,
        appBar: AppBar(
          toolbarHeight: 58,
          backgroundColor: AppColor.primary,
          foregroundColor: AppColor.textOnPrimary,
          title: const Text(
            'Pesanan',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColor.surface,
            labelColor: AppColor.surface,
            unselectedLabelColor: AppColor.textOnPrimary.withAlpha(170),
            tabs: _tabTitles.map((t) => Tab(text: t)).toList(),
          ),
        ),
        body: TabBarView(children: _tabTitles.map(_buildTabContent).toList()),
      ),
    );
  }
}

// ---------------- Inlined OrderProductsCard ----------------
class OrderProductsCard extends StatefulWidget {
  final TransactionModel transaction;

  const OrderProductsCard({super.key, required this.transaction});

  @override
  State<OrderProductsCard> createState() => _OrderProductsCardState();
}

class _OrderProductsCardState extends State<OrderProductsCard> {
  bool _expanded = false;
  bool _suppressNavigationTap = false;
  final UserController _userController = UserController();
  String? _buyerUsername;
  bool _loadingUser = true;

  int _computeTotal() {
    int total = 0;
    for (final item in widget.transaction.items) {
      final normalized = _normalizeItem(item);
      final product = (normalized['product'] as Map<String, dynamic>?) ?? {};
      final hargaVal = product['hargaPerHari'] ?? product['harga'] ?? 0;
      final qty = normalized['quantity'] ?? 0;
      final days = normalized['rental_days'] ?? widget.transaction.rentalDays;

      final harga = (hargaVal is int
          ? hargaVal
          : int.tryParse(hargaVal.toString()) ?? 0);
      final quantity = (qty is int ? qty : int.tryParse(qty.toString()) ?? 0);
      final rentalDays = (days is int
          ? days
          : int.tryParse(days.toString()) ?? 0);

      total += harga * quantity * rentalDays;
    }
    return total;
  }

  Map<String, dynamic> _normalizeItem(dynamic item) {
    if (item is Map<String, dynamic>) {
      final product = item['product_data'];
      Map<String, dynamic> prodMap;
      if (product is String) {
        try {
          prodMap = jsonDecode(product) as Map<String, dynamic>;
        } catch (_) {
          prodMap = {};
        }
      } else if (product is Map<String, dynamic>) {
        prodMap = product;
      } else {
        prodMap = {};
      }
      return {
        'product': prodMap,
        'quantity': item['quantity'] ?? 1,
        'rental_days': item['rental_days'] ?? widget.transaction.rentalDays,
      };
    }

    if (item is CartModel) {
      final ProductModel prod = item.product;
      return {
        'product': {
          'images': prod.images,
          'namaProduk': prod.namaProduk,
          'hargaPerHari': prod.hargaPerHari,
        },
        'quantity': item.quantity,
        'rental_days': item.rentalDays,
      };
    }

    return {
      'product': {},
      'quantity': 1,
      'rental_days': widget.transaction.rentalDays,
    };
  }

  @override
  void initState() {
    super.initState();
    _loadBuyerUsername();
  }

  Future<void> _loadBuyerUsername() async {
    try {
      final user = await _userController.getUserByUid(
        widget.transaction.userUid,
      );
      if (!mounted) return;
      setState(() {
        if (user != null) {
          final uname = user.username;
          if (uname != null && uname.trim().isNotEmpty) {
            _buyerUsername = uname;
          } else {
            _buyerUsername = user.email;
          }
        } else {
          _buyerUsername = '-';
        }
        _loadingUser = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _buyerUsername = '-';
        _loadingUser = false;
      });
    }
  }

  Widget _buildItem(dynamic rawItem) {
    final item = _normalizeItem(rawItem);
    final product = item['product'] as Map<String, dynamic>;

    List<String> images = [];
    final rawImages = product['images'];
    if (rawImages is String) {
      try {
        final parsed = jsonDecode(rawImages);
        if (parsed is List) images = parsed.map((e) => e.toString()).toList();
      } catch (_) {}
    } else if (rawImages is List) {
      images = List<String>.from(rawImages);
    }

    final firstImage = images.isNotEmpty ? images[0] : null;
    final nama = product['namaProduk'] ?? product['nama'] ?? '-';
    final hargaPerHari = product['hargaPerHari'] ?? 0;
    final quantity = item['quantity'] ?? 1;
    final rentalDays = item['rental_days'] ?? widget.transaction.rentalDays;
    final itemTotal =
        (int.tryParse(hargaPerHari.toString()) ?? 0) *
        (int.tryParse(quantity.toString()) ?? 0) *
        (int.tryParse(rentalDays.toString()) ?? 0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: firstImage != null
                ? Image.network(
                    firstImage,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 72,
                    height: 72,
                    color: AppColor.border,
                    child: const Icon(Icons.image, color: AppColor.textHint),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(
                  'Rp ${AppFormatters.formatRupiah(hargaPerHari)} /hari • ${rentalDays} hari',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColor.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Subtotal: Rp ${AppFormatters.formatRupiah(itemTotal)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'x$quantity',
            style: const TextStyle(color: AppColor.textSecondary),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _computeTotal();

    return GestureDetector(
      onTap: () {
        if (_suppressNavigationTap) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OrderDetailScreen(transaction: widget.transaction),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _loadingUser ? '...' : (_buyerUsername ?? '-'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.transaction.status,
                  style: const TextStyle(color: AppColor.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildItem(widget.transaction.items[0]),
            if (_expanded)
              Column(
                children: widget.transaction.items
                    .sublist(1)
                    .map(
                      (e) => Column(
                        children: [const Divider(height: 1), _buildItem(e)],
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 4),
            if (widget.transaction.items.length > 1)
              Center(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _expanded = !_expanded;
                      _suppressNavigationTap = true;
                    });
                    // prevent parent tap from immediately navigating
                    Future.delayed(const Duration(milliseconds: 150), () {
                      _suppressNavigationTap = false;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _expanded ? 'Sembunyikan' : 'Lihat Lainnya',
                          style: const TextStyle(
                            color: AppColor.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColor.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              const SizedBox(),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total ${widget.transaction.items.length} produk: Rp ${AppFormatters.formatRupiah(total)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

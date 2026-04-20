import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/controllers/transaction_controller.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/core/utils/app_formatters.dart';
import 'package:rentora_app/models/transaction_model.dart';
import 'package:rentora_app/widgets/custom_button.dart';
import 'dart:io';

class TransactionHistoryScreen extends StatefulWidget {
  final int initialIndex;
  const TransactionHistoryScreen({super.key, this.initialIndex = 0});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final TransactionController _transactionController = TransactionController();

  static const List<String> _tabTitles = [
    'Semua',
    'Belum Bayar',
    'Diproses',
    'Sedang Disewa',
    'Selesai',
    'Dibatalkan',
  ];

  bool _isLoading = true;
  List<TransactionModel> _transactions = [];

  @override
  void initState() {
    super.initState();
    // Ambil data transaksi saat widget dibuat
    _loadTransactions();
  }

  // Ambil data transaksi user
  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _transactionController.getCurrentUserTransactions();
      if (!mounted) return;
      setState(() {
        _transactions = data;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Filter transaksi berdasarkan status tab
  List<TransactionModel> _transactionsByStatus(String status) {
    if (status == 'Semua') return _transactions;
    return _transactions.where((t) => t.status == status).toList();
  }

  // Tampilkan tombol hubungi penjual jika status sesuai
  bool _showContactSellerButton(String status) {
    return status == 'Belum Bayar' ||
        status == 'Diproses' ||
        status == 'Sedang Disewa';
  }

  // Tampilkan tombol beri nilai jika status selesai
  bool _showRateButton(String status) {
    return status == 'Selesai';
  }

  // Widget kartu transaksi
  Widget _buildTransactionCard(TransactionModel transaction) {
    final item = transaction.items.first;
    final imagePath = item.product.images.isNotEmpty
        ? item.product.images.first
        : null;
    return Container(
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(transaction.storeName), Text(transaction.status)],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColor.border,
                  image: imagePath != null
                      ? DecorationImage(
                          image: imagePath.trim().startsWith('http')
                              ? NetworkImage(imagePath.trim())
                              : FileImage(File(imagePath.trim()))
                                    as ImageProvider,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.namaProduk),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text('x${item.quantity}'),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          'Rp${AppFormatters.formatRupiah(item.product.hargaPerHari)}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Pinjam ${transaction.rentalDays} hari: '),
                Text(
                  'Rp${AppFormatters.formatRupiah(transaction.totalPayment)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_showContactSellerButton(transaction.status))
            Align(
              alignment: Alignment.bottomRight,
              child: CustomButton(
                width: 126,
                height: 36,
                isOutlined: true,
                text: 'Hubungi Penjual',
                borderColor: AppColor.textHint,
                textColor: AppColor.textHint,
                onPressed: () {},
              ),
            ),
          if (_showRateButton(transaction.status))
            Align(
              alignment: Alignment.bottomRight,
              child: CustomButton(
                width: 88,
                height: 36,
                isOutlined: true,
                text: 'Beri Nilai',
                borderColor: AppColor.primary,
                textColor: AppColor.primary,
                onPressed: () {},
              ),
            ),
        ],
      ),
    );
  }

  // Widget isi tab transaksi
  Widget _buildTabContent(String status) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColor.primary),
      );
    }
    final filtered = _transactionsByStatus(status);
    if (filtered.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.money_bag, size: 56, color: AppColor.textHint),
            SizedBox(height: 12),
            Text(
              'Belum ada transaksi',
              style: TextStyle(color: AppColor.textHint),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          return _buildTransactionCard(filtered[index]);
        },
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemCount: filtered.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabTitles.length,
      initialIndex: widget.initialIndex,
      child: Scaffold(
        backgroundColor: AppColor.backgroundLight,
        appBar: AppBar(
          toolbarHeight: 58,
          backgroundColor: AppColor.primary,
          foregroundColor: AppColor.textOnPrimary,
          title: Text(
            "Riwayat Transaksi",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Symbols.chat, weight: 600)),
            SizedBox(width: 8),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColor.surface,
            labelColor: AppColor.surface,
            unselectedLabelColor: AppColor.textOnPrimary.withAlpha(170),
            tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
          ),
        ),
        body: TabBarView(children: _tabTitles.map(_buildTabContent).toList()),
      ),
    );
  }
}

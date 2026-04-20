import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/controllers/cart_controller.dart';
import 'package:rentora_app/controllers/store_controller.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/core/utils/app_formatters.dart';
import 'package:rentora_app/models/cart_model.dart';
import 'package:rentora_app/models/store_model.dart';
import 'package:rentora_app/views/checkout/checkout_screen.dart';
import 'package:rentora_app/core/extensions/navigator.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController _cartController = CartController();
  final StoreController _storeController = StoreController();

  final Map<String, StoreModel?> _stores = {};
  final Map<String, int> _rentalDays = {};
  Timer? _debounceTimer;
  final Duration _debounceDuration = Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();
    _cartController.cartItemsNotifier.addListener(_onCartItemsChanged);
    _loadCart();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _cartController.cartItemsNotifier.removeListener(_onCartItemsChanged);
    super.dispose();
  }

  // Listener perubahan cart, debounce agar tidak terlalu sering update
  void _onCartItemsChanged() {
    final cartItems = _cartController.cartItemsNotifier.value;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      _initializeRentalDays(cartItems);
      _loadStoresForCartItems(cartItems);
    });
  }

  // Load cart dari database
  void _loadCart() async {
    await _cartController.loadCartFromDB();
    setState(() {});
  }

  // Inisialisasi hari sewa per toko
  void _initializeRentalDays(List<CartModel> cartItems) {
    final groupedByStore = _groupCartItemsByStore(cartItems);
    final currentStoreIds = groupedByStore.keys.toSet();
    bool needsSetState = false;
    // Hapus store yang sudah tidak ada di cart
    for (String storeUid in _rentalDays.keys.toList()) {
      if (!currentStoreIds.contains(storeUid)) {
        _rentalDays.remove(storeUid);
        needsSetState = true;
      }
    }
    // Tambah store baru
    for (var entry in groupedByStore.entries) {
      String storeUid = entry.key;
      List<CartModel> items = entry.value;
      if (!_rentalDays.containsKey(storeUid) && items.isNotEmpty) {
        _rentalDays[storeUid] = items.first.rentalDays;
        needsSetState = true;
      }
    }
    if (needsSetState && mounted) {
      setState(() {});
    }
  }

  // Load data toko untuk setiap cart item
  void _loadStoresForCartItems(List<CartModel> cartItems) async {
    final groupedByStore = _groupCartItemsByStore(cartItems);
    bool needsSetState = false;
    // Hapus toko yang sudah tidak ada di cart
    for (String storeUid in _stores.keys.toList()) {
      if (!groupedByStore.containsKey(storeUid)) {
        _stores.remove(storeUid);
        needsSetState = true;
      }
    }
    // Ambil toko yang belum ada di cache
    final idsToFetch = groupedByStore.keys
        .where((id) => !_stores.containsKey(id))
        .toList();
    if (idsToFetch.isNotEmpty) {
      try {
        final results = await Future.wait(
          idsToFetch.map(
            (id) => _storeController.getStoreById(id).catchError((_) => null),
          ),
        );
        for (int i = 0; i < idsToFetch.length; i++) {
          final id = idsToFetch[i];
          final StoreModel? store = results[i];
          _stores[id] = store;
          needsSetState = true;
        }
      } catch (_) {}
    }
    if (needsSetState && mounted) {
      setState(() {});
    }
  }

  // Group cart item berdasarkan toko
  Map<String, List<CartModel>> _groupCartItemsByStore(
    List<CartModel> cartItems,
  ) {
    final Map<String, List<CartModel>> groupedItems = {};
    for (CartModel item in cartItems) {
      final storeUid = item.product.storeUid;
      groupedItems.putIfAbsent(storeUid, () => []).add(item);
    }
    return groupedItems;
  }

  // Update hari sewa semua item dalam satu toko
  void _applyRentalDaysUpdate(List<CartModel> cartItems, int days) {
    for (final item in cartItems) {
      _cartController.updateRentalDays(item.uid, item, days);
    }
  }

  // Update jumlah barang
  void _applyQuantityUpdate(CartModel cartItem, int newQty) {
    _cartController.updateCartQuantity(cartItem.uid, cartItem, newQty);
    if (mounted) setState(() {});
  }

  // Tampilkan pesan snackbar
  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  // Hitung total harga produk yang dipilih
  int _calculateTotal(
    Map<String, List<CartModel>> groupedItems,
    List<String> selectedProductUids,
  ) {
    int total = 0;
    for (var entry in groupedItems.entries) {
      for (CartModel item in entry.value) {
        if (selectedProductUids.contains(item.product.uid)) {
          total += item.product.hargaPerHari * item.quantity * item.rentalDays;
        }
      }
    }
    return total;
  }

  // Ambil list cart item yang dipilih
  List<CartModel> _getSelectedCartItems(
    List<CartModel> cartItems,
    List<String> selectedProductUids,
  ) {
    return cartItems
        .where((item) => selectedProductUids.contains(item.product.uid))
        .toList();
  }

  // Tambah hari sewa
  void _incrementDays(List<CartModel> cartItems) {
    if (cartItems.isEmpty) return;
    int maxDays = cartItems
        .map((item) => item.product.maxHariPinjam)
        .reduce((a, b) => a < b ? a : b);
    String storeUid = cartItems.first.product.storeUid;
    int currentRentalDays = _rentalDays[storeUid] ?? 1;
    if (currentRentalDays < maxDays) {
      int newDays = currentRentalDays + 1;
      setState(() {
        _rentalDays[storeUid] = newDays;
      });
      _applyRentalDaysUpdate(cartItems, newDays);
    } else {
      _showSnack('Maksimal sewa untuk salah satu barang adalah $maxDays hari');
    }
  }

  // Kurangi hari sewa
  void _decrementDays(List<CartModel> cartItems) {
    if (cartItems.isEmpty) return;
    String storeUid = cartItems.first.product.storeUid;
    int currentRentalDays = _rentalDays[storeUid] ?? 1;
    if (currentRentalDays > 1) {
      int newDays = currentRentalDays - 1;
      setState(() {
        _rentalDays[storeUid] = newDays;
      });
      _applyRentalDaysUpdate(cartItems, newDays);
    }
  }

  // Tambah jumlah barang
  void _incrementQuantity(CartModel cartItem) {
    int currentQty = cartItem.quantity;
    int maxStock = cartItem.product.stok;
    if (currentQty < maxStock) {
      _applyQuantityUpdate(cartItem, currentQty + 1);
    }
  }

  // Kurangi jumlah barang
  void _decrementQuantity(CartModel cartItem) {
    int currentQty = cartItem.quantity;
    if (currentQty > 1) {
      _applyQuantityUpdate(cartItem, currentQty - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data cart dan group by toko
    final cartItems = _cartController.cartItemsNotifier.value;
    final groupedByStore = _groupCartItemsByStore(cartItems);

    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: AppBar(
        toolbarHeight: 58,
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.textOnPrimary,
        title: const Text(
          "Keranjang",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Symbols.chat, weight: 700),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset("assets/animations/EmptyBox.json"),
                  const Text('Keranjang Anda kosong'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: groupedByStore.entries.map((entry) {
                  final storeUid = entry.key;
                  final items = entry.value;
                  final store = _stores[storeUid];
                  final rentalDays =
                      _rentalDays[storeUid] ??
                      (items.isNotEmpty ? items.first.rentalDays : 1);
                  return StoreCartCard(
                    key: ValueKey('store-$storeUid'),
                    storeUid: storeUid,
                    cartItems: items,
                    cartController: _cartController,
                    store: store,
                    rentalDays: rentalDays,
                    onIncrementDays: () => _incrementDays(items),
                    onDecrementDays: () => _decrementDays(items),
                    onIncrementQuantity: _incrementQuantity,
                    onDecrementQuantity: _decrementQuantity,
                  );
                }).toList(),
              ),
            ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: _cartController.selectedProductUids,
        builder: (context, selectedProductUids, child) {
          final totalPrice = _calculateTotal(
            groupedByStore,
            selectedProductUids,
          );
          final totalLabel = selectedProductUids.isEmpty
              ? 'Rp-'
              : 'Rp ${AppFormatters.formatRupiah(totalPrice.toString())}';
          return Container(
            decoration: const BoxDecoration(
              color: AppColor.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColor.shadowLight,
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: kBottomNavigationBarHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        totalLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColor.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          final selectedItems = _getSelectedCartItems(
                            cartItems,
                            selectedProductUids,
                          );
                          if (selectedItems.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Pilih minimal 1 produk untuk checkout',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          context.push(
                            CheckoutScreen(cartItems: selectedItems),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColor.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          width: 120,
                          height: double.infinity,
                          alignment: Alignment.center,
                          child: const Text(
                            "Checkout",
                            style: TextStyle(
                              color: AppColor.surface,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class StoreCartCard extends StatelessWidget {
  final String storeUid;
  final List<CartModel> cartItems;
  final CartController cartController;
  final StoreModel? store;
  final int rentalDays;
  final VoidCallback onIncrementDays;
  final VoidCallback onDecrementDays;
  final ValueChanged<CartModel> onIncrementQuantity;
  final ValueChanged<CartModel> onDecrementQuantity;

  const StoreCartCard({
    super.key,
    required this.storeUid,
    required this.cartItems,
    required this.cartController,
    required this.store,
    required this.rentalDays,
    required this.onIncrementDays,
    required this.onDecrementDays,
    required this.onIncrementQuantity,
    required this.onDecrementQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, right: 8, bottom: 8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ValueListenableBuilder<String?>(
        valueListenable: cartController.selectedStoreUid,
        builder: (context, selectedStoreUid, _) {
          final bool isSelected = selectedStoreUid == storeUid;
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: isSelected,
                    activeColor: AppColor.primary,
                    onChanged: (value) {
                      if (value == true) {
                        cartController.selectStore(storeUid);
                      } else {
                        final selectedUids = List<String>.from(
                          cartController.selectedProductUids.value,
                        );
                        for (CartModel item in cartItems) {
                          if (selectedUids.contains(item.product.uid)) {
                            cartController.selectProduct(item.product.uid);
                          }
                        }
                      }
                    },
                  ),
                  Expanded(
                    child: Text(
                      store?.name ?? 'Memuat nama toko...',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 28,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColor.border),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 16,
                          onPressed: onDecrementDays,
                          icon: const Icon(Icons.remove),
                        ),
                        Text(
                          "$rentalDays hari",
                          style: const TextStyle(fontSize: 12),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 16,
                          onPressed: onIncrementDays,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<List<String>>(
                valueListenable: cartController.selectedProductUids,
                builder: (context, selectedProductUids, _) {
                  return Column(
                    children: cartItems.map((cartItem) {
                      return CartItemCard(
                        key: ValueKey('cart-${cartItem.uid}'),
                        cartItem: cartItem,
                        cartController: cartController,
                        isEnabled: isSelected,
                        isSelected: selectedProductUids.contains(
                          cartItem.product.uid,
                        ),
                        onIncrement: () => onIncrementQuantity(cartItem),
                        onDecrement: () => onDecrementQuantity(cartItem),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartModel cartItem;
  final CartController cartController;
  final bool isEnabled;
  final bool isSelected;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.cartController,
    required this.isEnabled,
    required this.isSelected,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: isSelected,
            activeColor: AppColor.primary,
            onChanged: isEnabled
                ? (value) {
                    cartController.selectProduct(cartItem.product.uid);
                  }
                : null,
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.border),
              image: cartItem.product.images.isNotEmpty
                  ? DecorationImage(
                      image:
                          cartItem.product.images.first.trim().startsWith(
                            'http',
                          )
                          ? NetworkImage(cartItem.product.images.first.trim())
                          : FileImage(
                                  File(cartItem.product.images.first.trim()),
                                )
                                as ImageProvider,
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: cartItem.product.images.isEmpty
                ? const Icon(Icons.image, color: AppColor.textHint)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.product.namaProduk,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      "Rp${AppFormatters.formatRupiah(cartItem.product.hargaPerHari.toString())}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColor.secondary,
                      ),
                    ),
                    const Text(
                      "/hari",
                      style: TextStyle(fontSize: 10, color: AppColor.textHint),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 28,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.border),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 16,
                        onPressed: onDecrement,
                        icon: const Icon(Icons.remove),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          "${cartItem.quantity} buah",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 16,
                        onPressed: onIncrement,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: AppColor.surface,
                    title: const Text("Hapus Barang"),
                    content: const Text(
                      "Apakah Anda yakin ingin menghapus barang ini dari keranjang?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Batal",
                          style: TextStyle(color: AppColor.textSecondary),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          cartController.removeFromCart(cartItem.uid);
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Hapus",
                          style: TextStyle(color: AppColor.error),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.delete_outline, color: AppColor.error),
          ),
        ],
      ),
    );
  }
}

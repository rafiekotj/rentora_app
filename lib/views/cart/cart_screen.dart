import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/controllers/cart_controller.dart';
import 'package:rentora_app/controllers/store_controller.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/core/utils/app_formatters.dart';
import 'package:rentora_app/models/cart_model.dart';
import 'package:rentora_app/models/store_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController _cartController = CartController();
  final StoreController _storeController = StoreController();

  final Map<int, StoreModel?> _stores = {};
  final Map<int, int> _rentalDays = {};

  @override
  void initState() {
    super.initState();
    _cartController.cartItemsNotifier.addListener(_onCartItemsChanged);
    _loadCart();
  }

  void _loadCart() async {
    await _cartController.loadCartFromDB();
    setState(() {});
  }

  @override
  void dispose() {
    _cartController.cartItemsNotifier.removeListener(_onCartItemsChanged);
    super.dispose();
  }

  // Dipanggil setiap ada perubahan pada data keranjang
  void _onCartItemsChanged() {
    final cartItems = _cartController.cartItemsNotifier.value;
    _initializeRentalDays(cartItems);
    _loadStoresForCartItems(cartItems);
  }

  // Menginisialisasi jumlah hari sewa untuk setiap toko
  void _initializeRentalDays(List<CartModel> cartItems) {
    Map<int, List<CartModel>> groupedByStore = _groupCartItemsByStore(
      cartItems,
    );

    Set<int> currentStoreIds = groupedByStore.keys.toSet();

    bool needsSetState = false;

    for (int storeId in _rentalDays.keys.toList()) {
      if (!currentStoreIds.contains(storeId)) {
        _rentalDays.remove(storeId);
        needsSetState = true;
      }
    }

    for (var entry in groupedByStore.entries) {
      int storeId = entry.key;
      List<CartModel> items = entry.value;

      if (!_rentalDays.containsKey(storeId) && items.isNotEmpty) {
        _rentalDays[storeId] = items.first.rentalDays;
        needsSetState = true;
      }
    }

    if (needsSetState && mounted) {
      setState(() {});
    }
  }

  // Memuat data detail toko untuk setiap toko yang ada di keranjang
  void _loadStoresForCartItems(List<CartModel> cartItems) async {
    Map<int, List<CartModel>> groupedByStore = _groupCartItemsByStore(
      cartItems,
    );

    bool needsSetState = false;

    for (int storeId in _stores.keys.toList()) {
      if (!groupedByStore.containsKey(storeId)) {
        _stores.remove(storeId);
        needsSetState = true;
      }
    }

    for (int storeId in groupedByStore.keys) {
      if (!_stores.containsKey(storeId)) {
        StoreModel? store = await _storeController.getStoreById(storeId);

        if (mounted) {
          _stores[storeId] = store;
          needsSetState = true;
        }
      }
    }

    if (needsSetState && mounted) {
      setState(() {});
    }
  }

  // Menambah jumlah hari sewa untuk semua item dalam satu toko
  void _incrementDays(int userId, List<CartModel> cartItems) {
    if (cartItems.isEmpty) return;

    int maxDays = cartItems.first.product.maxHariPinjam;

    for (CartModel item in cartItems) {
      if (item.product.maxHariPinjam < maxDays) {
        maxDays = item.product.maxHariPinjam;
      }
    }

    int currentRentalDays = _rentalDays[userId] ?? 1;

    if (currentRentalDays < maxDays) {
      int newDays = currentRentalDays + 1;

      setState(() {
        _rentalDays[userId] = newDays;
      });

      for (CartModel item in cartItems) {
        _cartController.updateRentalDays(item, newDays);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Maksimal sewa untuk salah satu barang adalah $maxDays hari',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Mengurangi jumlah hari sewa.
  void _decrementDays(int userId, List<CartModel> cartItems) {
    int currentRentalDays = _rentalDays[userId] ?? 1;

    if (currentRentalDays > 1) {
      int newDays = currentRentalDays - 1;

      setState(() {
        _rentalDays[userId] = newDays;
      });

      for (CartModel item in cartItems) {
        _cartController.updateRentalDays(item, newDays);
      }
    }
  }

  // Menambah kuantitas satu item
  void _incrementQuantity(CartModel cartItem) {
    int currentQty = cartItem.quantity;
    int maxStock = cartItem.product.stok;

    if (currentQty < maxStock) {
      int newQty = currentQty + 1;
      _cartController.updateCartQuantity(cartItem, newQty);

      setState(() {});
    }
  }

  // Mengurangi kuantitas satu item
  void _decrementQuantity(CartModel cartItem) {
    int currentQty = cartItem.quantity;

    if (currentQty > 1) {
      int newQty = currentQty - 1;
      _cartController.updateCartQuantity(cartItem, newQty);

      setState(() {});
    }
  }

  // Mengelompokkan item keranjang berdasarkan ID toko
  Map<int, List<CartModel>> _groupCartItemsByStore(List<CartModel> cartItems) {
    Map<int, List<CartModel>> groupedItems = {};

    for (CartModel item in cartItems) {
      int storeId = item.product.storeId;

      // Jika toko belum ada di map, buat list baru
      if (!groupedItems.containsKey(storeId)) {
        groupedItems[storeId] = [];
      }

      // Tambahkan item ke list toko tersebut
      groupedItems[storeId]!.add(item);
    }

    return groupedItems;
  }

  // Menghitung total harga dari semua item yang dipilih di keranjang
  int _calculateTotal(
    Map<int, List<CartModel>> groupedItems,
    List<int> selectedProductIds,
  ) {
    int total = 0;

    for (var entry in groupedItems.entries) {
      List<CartModel> items = entry.value;

      for (CartModel item in items) {
        int productId = item.product.id ?? 0;

        if (selectedProductIds.contains(productId)) {
          int harga = item.product.hargaPerHari;
          int quantity = item.quantity;
          int days = item.rentalDays;

          total += harga * quantity * days;
        }
      }
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    // Ambil semua item keranjang dari controller
    List<CartModel> cartItems = _cartController.cartItemsNotifier.value;

    // Kelompokkan item berdasarkan toko
    Map<int, List<CartModel>> groupedByStore = _groupCartItemsByStore(
      cartItems,
    );

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
            icon: const Icon(Symbols.chat, weight: 600),
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
                // Membuat daftar `StoreCartCard` untuk setiap toko.
                children: groupedByStore.entries.map((entry) {
                  final storeId = entry.key;
                  final items = entry.value;
                  final store = _stores[storeId];
                  final rentalDays =
                      _rentalDays[storeId] ??
                      (items.isNotEmpty ? items.first.rentalDays : 1);

                  return StoreCartCard(
                    userId: storeId,
                    cartItems: items,
                    cartController: _cartController,
                    store: store,
                    rentalDays: rentalDays,
                    onIncrementDays: () => _incrementDays(storeId, items),
                    onDecrementDays: () => _decrementDays(storeId, items),
                    onIncrementQuantity: _incrementQuantity,
                    onDecrementQuantity: _decrementQuantity,
                  );
                }).toList(),
              ),
            ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: _cartController.selectedProductIds,
        builder: (context, selectedProductIds, child) {
          return Container(
            height: 56,
            decoration: const BoxDecoration(color: AppColor.surface),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Rp ${AppFormatters.formatRupiah(_calculateTotal(groupedByStore, selectedProductIds).toString())}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {},
                  child: Container(
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
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Menampilkan semua item dari satu toko yang sama dalam sebuah kartu
class StoreCartCard extends StatelessWidget {
  final int userId;
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
    required this.userId,
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
      child: ValueListenableBuilder<int?>(
        valueListenable: cartController.selectedStoreId,
        builder: (context, selectedStoreId, _) {
          final bool isSelected = selectedStoreId == userId;
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
                        // Select store dan semua produk
                        cartController.selectStore(userId);
                        for (CartModel item in cartItems) {
                          if (item.product.id != null &&
                              !cartController.selectedProductIds.value.contains(
                                item.product.id,
                              )) {
                            cartController.selectProduct(item.product.id!);
                          }
                        }
                      } else {
                        // Unselect semua produk di store ini
                        final selectedIds =
                            cartController.selectedProductIds.value;
                        for (CartModel item in cartItems) {
                          if (item.product.id != null &&
                              selectedIds.contains(item.product.id)) {
                            cartController.selectProduct(item.product.id!);
                          }
                        }
                        // Toggle store (akan otomatis deselect)
                        cartController.selectStore(userId);
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
              ValueListenableBuilder<List<int>>(
                valueListenable: cartController.selectedProductIds,
                builder: (context, selectedProductIds, _) {
                  return Column(
                    children: cartItems.map((cartItem) {
                      return CartItemCard(
                        cartItem: cartItem,
                        cartController: cartController,
                        isEnabled: isSelected,
                        isSelected: selectedProductIds.contains(
                          cartItem.product.id,
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

// Menampilkan detail satu item di dalam keranjang, seperti gambar, nama produk, harga, dan kuantitas
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
                    if (cartItem.product.id != null) {
                      cartController.selectProduct(cartItem.product.id!);
                    }
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
                      image: FileImage(File(cartItem.product.images.first)),
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
                          cartController.removeFromCart(cartItem);
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

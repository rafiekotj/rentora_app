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

  // Map untuk menyimpan data toko yang sudah dimuat
  final Map<int, StoreModel?> _stores = {};

  // Map untuk menyimpan jumlah hari sewa untuk setiap toko
  final Map<int, int> _rentalDays = {};

  @override
  void initState() {
    super.initState();
    _cartController.loadCartFromDB();
    // Menambahkan listener untuk mendeteksi perubahan pada item keranjang setiap kali ada perubahan
    _cartController.cartItemsNotifier.addListener(_onCartItemsChanged);
  }

  @override
  void dispose() {
    _cartController.cartItemsNotifier.removeListener(_onCartItemsChanged);
    super.dispose();
  }

  // Fungsi yang dipanggil setiap ada perubahan pada data keranjang
  void _onCartItemsChanged() {
    final cartItems = _cartController.cartItemsNotifier.value;
    // Memperbarui jumlah hari sewa berdasarkan data keranjang terbaru
    _initializeRentalDays(cartItems);
    // Memuat data toko untuk item yang ada di keranjang
    _loadStoresForCartItems(cartItems);
  }

  // Menginisialisasi jumlah hari sewa
  void _initializeRentalDays(List<CartModel> cartItems) {
    final groupedByStore = _groupCartItemsByStore(cartItems);
    final currentStoreIds = groupedByStore.keys.toSet();

    bool needsSetState = false;

    // Menghapus data hari sewa untuk toko yang sudah tidak ada di keranjang
    _rentalDays.removeWhere((storeId, _) {
      final shouldRemove = !currentStoreIds.contains(storeId);
      if (shouldRemove) needsSetState = true;
      return shouldRemove;
    });

    // Menambahkan data hari sewa untuk toko yang baru ditambahkan ke keranjang
    for (var entry in groupedByStore.entries) {
      if (!_rentalDays.containsKey(entry.key) && entry.value.isNotEmpty) {
        _rentalDays[entry.key] = entry.value.first.rentalDays;
        needsSetState = true;
      }
    }

    if (needsSetState && mounted) {
      setState(() {});
    }
  }

  // Memuat data detail toko untuk setiap toko yang ada di keranjang
  void _loadStoresForCartItems(List<CartModel> cartItems) async {
    final groupedByStore = _groupCartItemsByStore(cartItems);
    bool needsSetState = false;

    // Menghapus data toko jika toko tersebut tidak lagi ada di keranjang
    _stores.removeWhere((storeId, _) {
      final shouldRemove = !groupedByStore.keys.toSet().contains(storeId);
      if (shouldRemove) needsSetState = true;
      return shouldRemove;
    });

    // Memuat data untuk toko yang belum ada di keranjang
    for (var storeId in groupedByStore.keys) {
      if (_stores[storeId] == null) {
        final store = await _storeController.getStoreByUserId(storeId);
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

    // Menentukan batas maksimal hari pinjam dari semua item di toko tersebut.
    final maxDays = cartItems
        .map((item) => item.product.maxHariPinjam)
        .reduce((a, b) => a < b ? a : b);

    int currentRentalDays = _rentalDays[userId] ?? 1;

    if (currentRentalDays < maxDays) {
      setState(() {
        _rentalDays[userId] = currentRentalDays + 1;
      });
      for (var item in cartItems) {
        _cartController.updateRentalDays(item, currentRentalDays + 1);
      }
    } else {
      // Menampilkan peringatan jika sudah mencapai batas maksimal
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
      setState(() {
        _rentalDays[userId] = currentRentalDays - 1;
      });
      for (var item in cartItems) {
        _cartController.updateRentalDays(item, currentRentalDays - 1);
      }
    }
  }

  // Menambah kuantitas satu item
  void _incrementQuantity(CartModel cartItem) {
    if (cartItem.quantity < cartItem.product.stok) {
      _cartController.updateCartQuantity(cartItem, cartItem.quantity + 1);
    }
  }

  // Mengurangi kuantitas satu item
  void _decrementQuantity(CartModel cartItem) {
    if (cartItem.quantity > 1) {
      _cartController.updateCartQuantity(cartItem, cartItem.quantity - 1);
    }
  }

  // Mengelompokkan item keranjang berdasarkan ID toko
  Map<int, List<CartModel>> _groupCartItemsByStore(List<CartModel> cartItems) {
    final Map<int, List<CartModel>> groupedItems = {};
    for (var item in cartItems) {
      if (groupedItems.containsKey(item.product.storeId)) {
        groupedItems[item.product.storeId]!.add(item);
      } else {
        groupedItems[item.product.storeId] = [item];
      }
    }
    return groupedItems;
  }

  // Menghitung total harga dari semua item yang dipilih di keranjang
  int _calculateTotal(
    Map<int, List<CartModel>> groupedItems,
    List<int> selectedProductIds,
  ) {
    int total = 0;
    groupedItems.forEach((userId, items) {
      for (var item in items) {
        if (selectedProductIds.contains(item.product.id)) {
          total += item.product.hargaPerHari * item.quantity * item.rentalDays;
        }
      }
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder digunakan untuk secara otomatis membangun ulang UI setiap kali ada perubahan pada `cartItemsNotifier`.
    return ValueListenableBuilder<List<CartModel>>(
      valueListenable: _cartController.cartItemsNotifier,
      builder: (context, cartItems, child) {
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
      },
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
                      cartController.selectStore(userId);
                    },
                  ),
                  Text(
                    store?.name ?? 'Memuat nama toko...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
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

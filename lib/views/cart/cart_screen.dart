import 'dart:io';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/controllers/cart_controller.dart';
import 'package:rentora_app/controllers/store_controller.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/models/cart_model.dart';
import 'package:rentora_app/models/store_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController _cartController = CartController();

  @override
  void initState() {
    super.initState();
    _cartController.loadCartFromDB();
  }

  @override
  Widget build(BuildContext context) {
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
              ? const Center(child: Text('Keranjang Anda kosong'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: groupedByStore.entries.map((entry) {
                      return StoreCartCard(
                        userId: entry.key,
                        cartItems: entry.value,
                        cartController: _cartController,
                      );
                    }).toList(),
                  ),
                ),
          bottomNavigationBar: cartItems.isEmpty
              ? null
              : BottomAppBar(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: Rp ${_calculateTotal(groupedByStore)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Checkout'),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

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

  int _calculateTotal(Map<int, List<CartModel>> groupedItems) {
    int total = 0;
    groupedItems.forEach((userId, items) {
      for (var item in items) {
        total += item.product.hargaPerHari * item.quantity * item.rentalDays;
      }
    });
    return total;
  }
}

class StoreCartCard extends StatefulWidget {
  final int userId;
  final List<CartModel> cartItems;
  final CartController cartController;

  const StoreCartCard({
    super.key,
    required this.userId,
    required this.cartItems,
    required this.cartController,
  });

  @override
  State<StoreCartCard> createState() => _StoreCartCardState();
}

class _StoreCartCardState extends State<StoreCartCard> {
  final StoreController _storeController = StoreController();
  StoreModel? _store;
  int _rentalDays = 1;

  @override
  void initState() {
    super.initState();
    _loadStore();
    if (widget.cartItems.isNotEmpty) {
      _rentalDays = widget.cartItems.first.rentalDays;
    }
  }

  Future<void> _loadStore() async {
    final store = await _storeController.getStoreByUserId(widget.userId);
    if (mounted) {
      setState(() {
        _store = store;
      });
    }
  }

  void _incrementDays() {
    if (widget.cartItems.isEmpty) return;

    final maxDays = widget.cartItems
        .map((item) => item.product.maxHariPinjam)
        .reduce((a, b) => a < b ? a : b);

    if (_rentalDays < maxDays) {
      setState(() {
        _rentalDays++;
      });
      for (var item in widget.cartItems) {
        widget.cartController.updateRentalDays(item, _rentalDays);
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

  void _decrementDays() {
    if (_rentalDays > 1) {
      setState(() {
        _rentalDays--;
      });
      for (var item in widget.cartItems) {
        widget.cartController.updateRentalDays(item, _rentalDays);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, right: 8, bottom: 8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: true,
                activeColor: AppColor.primary,
                onChanged: (value) {},
              ),
              Text(
                _store?.name ?? 'Memuat nama toko...',
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
                      onPressed: _decrementDays,
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      "$_rentalDays hari",
                      style: const TextStyle(fontSize: 12),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 16,
                      onPressed: _incrementDays,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.cartItems.map((cartItem) {
            return CartItemCard(
              cartItem: cartItem,
              cartController: widget.cartController, // pakai instance yg sama
            );
          }),
        ],
      ),
    );
  }
}

class CartItemCard extends StatefulWidget {
  final CartModel cartItem;
  final CartController cartController;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.cartController,
  });

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  void _incrementQuantity() {
    if (widget.cartItem.quantity < widget.cartItem.product.stok &&
        widget.cartItem.quantity < 4) {
      widget.cartItem.quantity++;
      widget.cartController.updateCartQuantity(
        widget.cartItem,
        widget.cartItem.quantity,
      );
    }
  }

  void _decrementQuantity() {
    if (widget.cartItem.quantity > 1) {
      widget.cartItem.quantity--;
      widget.cartController.updateCartQuantity(
        widget.cartItem,
        widget.cartItem.quantity,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: true,
            activeColor: AppColor.primary,
            onChanged: (value) {},
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.border),
              image: widget.cartItem.product.images.isNotEmpty
                  ? DecorationImage(
                      image: FileImage(
                        File(widget.cartItem.product.images.first),
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: widget.cartItem.product.images.isEmpty
                ? const Icon(Icons.image, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.cartItem.product.namaProduk,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Rp${widget.cartItem.product.hargaPerHari}/hari",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColor.textHint,
                  ),
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
                        onPressed: _decrementQuantity,
                        icon: const Icon(Icons.remove),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "${widget.cartItem.quantity}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 16,
                        onPressed: _incrementQuantity,
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
              widget.cartController.removeFromCart(widget.cartItem);
            },
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

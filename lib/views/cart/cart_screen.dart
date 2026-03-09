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
                          'Total: Rp ${_calculateTotal(cartItems)}',
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
      if (groupedItems.containsKey(item.product.userId)) {
        groupedItems[item.product.userId]!.add(item);
      } else {
        groupedItems[item.product.userId] = [item];
      }
    }
    return groupedItems;
  }

  int _calculateTotal(List<CartModel> cartItems) {
    int total = 0;
    for (var item in cartItems) {
      total += item.product.hargaPerHari * item.quantity;
    }
    return total;
  }
}

class StoreCartCard extends StatefulWidget {
  final int userId;
  final List<CartModel> cartItems;

  const StoreCartCard({
    super.key,
    required this.userId,
    required this.cartItems,
  });

  @override
  State<StoreCartCard> createState() => _StoreCartCardState();
}

class _StoreCartCardState extends State<StoreCartCard> {
  final StoreController _storeController = StoreController();
  StoreModel? _store;

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  Future<void> _loadStore() async {
    final store = await _storeController.getStoreByUserId(widget.userId);
    if (mounted) {
      setState(() {
        _store = store;
      });
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
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColor.border,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          bottomLeft: Radius.circular(4),
                        ),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 16,
                        onPressed: () {},
                        icon: const Icon(Icons.remove),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text("7 hari", style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColor.border,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 16,
                        onPressed: () {},
                        icon: const Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.cartItems.map((cartItem) {
            return CartItemCard(cartItem: cartItem);
          }),
        ],
      ),
    );
  }
}

class CartItemCard extends StatefulWidget {
  final CartModel cartItem;

  const CartItemCard({super.key, required this.cartItem});

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  final CartController _cartController = CartController();

  void _incrementQuantity() {
    if (widget.cartItem.quantity < widget.cartItem.product.stok &&
        widget.cartItem.quantity < 4) {
      setState(() {
        widget.cartItem.quantity++;
      });
      _cartController.cartItemsNotifier.notifyListeners();
    }
  }

  void _decrementQuantity() {
    if (widget.cartItem.quantity > 1) {
      setState(() {
        widget.cartItem.quantity--;
      });
      _cartController.cartItemsNotifier.notifyListeners();
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
                Row(
                  children: [
                    Text(
                      "Rp${widget.cartItem.product.hargaPerHari}/hari",
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColor.textHint,
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
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColor.border,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4),
                                bottomLeft: Radius.circular(4),
                              ),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 16,
                              onPressed: _decrementQuantity,
                              icon: const Icon(Icons.remove),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.cartItem.quantity.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColor.border,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(4),
                                bottomRight: Radius.circular(4),
                              ),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 16,
                              onPressed: _incrementQuantity,
                              icon: const Icon(Icons.add),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _cartController.removeFromCart(widget.cartItem);
            },
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

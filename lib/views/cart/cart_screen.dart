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
        return ValueListenableBuilder<Map<int, int>>(
          valueListenable: _cartController.daysPerStoreNotifier,
          builder: (context, daysPerStore, child) {
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
                            initialDays: daysPerStore[entry.key] ?? 7,
                            onDaysChanged: (newDays) {
                              _cartController.updateDaysForStore(
                                entry.key,
                                newDays,
                              );
                            },
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
                              'Total: Rp ${_calculateTotal(groupedByStore, daysPerStore)}',
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

  int _calculateTotal(
    Map<int, List<CartModel>> groupedItems,
    Map<int, int> daysPerStore,
  ) {
    int total = 0;
    groupedItems.forEach((userId, items) {
      final days = daysPerStore[userId] ?? 1;
      for (var item in items) {
        total += item.product.hargaPerHari * item.quantity * days;
      }
    });
    return total;
  }
}

class StoreCartCard extends StatefulWidget {
  final int userId;
  final List<CartModel> cartItems;
  final int initialDays;
  final ValueChanged<int> onDaysChanged;

  const StoreCartCard({
    super.key,
    required this.userId,
    required this.cartItems,
    required this.initialDays,
    required this.onDaysChanged,
  });

  @override
  State<StoreCartCard> createState() => _StoreCartCardState();
}

class _StoreCartCardState extends State<StoreCartCard> {
  final StoreController _storeController = StoreController();
  StoreModel? _store;
  int _numberOfDays = 7;
  late int _maxAllowedDays;

  @override
  void initState() {
    super.initState();
    _loadStore();
    _numberOfDays = widget.initialDays;

    if (widget.cartItems.isNotEmpty) {
      _maxAllowedDays = widget.cartItems
          .map((item) => item.product.maxHariPinjam)
          .reduce((min, current) => current < min ? current : min);
    } else {
      _maxAllowedDays = 7; // Default fallback
    }

    if (_numberOfDays > _maxAllowedDays) {
      _numberOfDays = _maxAllowedDays;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onDaysChanged(_numberOfDays);
      });
    }
  }

  @override
  void didUpdateWidget(covariant StoreCartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDays != oldWidget.initialDays) {
      setState(() {
        _numberOfDays = widget.initialDays;
        if (_numberOfDays > _maxAllowedDays) {
          _numberOfDays = _maxAllowedDays;
        }
      });
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
    if (_numberOfDays < _maxAllowedDays) {
      final newDays = _numberOfDays + 1;
      setState(() {
        _numberOfDays = newDays;
      });
      widget.onDaysChanged(newDays);
    }
  }

  void _decrementDays() {
    if (_numberOfDays > 1) {
      final newDays = _numberOfDays - 1;
      setState(() {
        _numberOfDays = newDays;
      });
      widget.onDaysChanged(newDays);
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
                        onPressed: _decrementDays,
                        icon: const Icon(Icons.remove),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$_numberOfDays hari",
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
                        onPressed: _incrementDays,
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
                Text(
                  "Rp${widget.cartItem.product.hargaPerHari}/hari",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColor.textHint,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 28,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.border),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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

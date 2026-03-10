import 'package:flutter/material.dart';
import 'package:rentora_app/models/cart_model.dart';
import 'package:rentora_app/services/database/sqflite.dart';

class CartController {
  static final CartController _instance = CartController._internal();

  factory CartController() {
    return _instance;
  }

  CartController._internal() {
    loadCartFromDB();
  }

  final ValueNotifier<List<CartModel>> cartItemsNotifier = ValueNotifier([]);
  final ValueNotifier<int?> selectedStoreId = ValueNotifier(null);
  final ValueNotifier<List<int>> selectedProductIds = ValueNotifier([]);

  Future<void> loadCartFromDB() async {
    final cartList = await DBHelper.getAllCart();
    cartItemsNotifier.value = cartList;
  }

  void selectStore(int storeId) {
    if (selectedStoreId.value == storeId) {
      selectedStoreId.value = null;
      selectedProductIds.value = [];
    } else {
      selectedStoreId.value = storeId;
      final storeProductIds = cartItemsNotifier.value
          .where((item) => item.product.storeId == storeId)
          .map((item) => item.product.id)
          .whereType<int>()
          .toList();
      selectedProductIds.value = storeProductIds;
    }
  }

  void selectProduct(int productId) {
    final newSelectedProductIds = List<int>.from(selectedProductIds.value);
    if (newSelectedProductIds.contains(productId)) {
      newSelectedProductIds.remove(productId);
    } else {
      newSelectedProductIds.add(productId);
    }
    selectedProductIds.value = newSelectedProductIds;
  }

  void clearSelection() {
    selectedStoreId.value = null;
    selectedProductIds.value = [];
  }

  Future<void> addToCart(CartModel cartItem) async {
    final index = cartItemsNotifier.value.indexWhere(
      (element) => element.product.id == cartItem.product.id,
    );

    if (index >= 0) {
      cartItemsNotifier.value[index].quantity += cartItem.quantity;
      await DBHelper.updateCart(cartItemsNotifier.value[index]);
    } else {
      final id = await DBHelper.insertCart(cartItem);
      cartItem = CartModel(
        id: id,
        product: cartItem.product,
        quantity: cartItem.quantity,
        rentalDays: cartItem.rentalDays,
      );
      cartItemsNotifier.value = [...cartItemsNotifier.value, cartItem];
    }
  }

  Future<void> removeFromCart(CartModel cartItem) async {
    if (cartItem.id != null) {
      await DBHelper.deleteCart(cartItem.id!);
    }
    cartItemsNotifier.value = cartItemsNotifier.value
        .where((e) => e.id != cartItem.id)
        .toList();
  }

  Future<void> updateCartQuantity(CartModel cartItem, int quantity) async {
    cartItem.quantity = quantity;
    if (cartItem.id != null) await DBHelper.updateCart(cartItem);
    cartItemsNotifier.value = List.from(cartItemsNotifier.value);
  }

  Future<void> updateRentalDays(CartModel cartItem, int days) async {
    cartItem.rentalDays = days;
    if (cartItem.id != null) await DBHelper.updateCart(cartItem);
    cartItemsNotifier.value = List.from(cartItemsNotifier.value);
  }

  Future<void> clearCart() async {
    await DBHelper.clearCart();
    cartItemsNotifier.value = [];
  }
}

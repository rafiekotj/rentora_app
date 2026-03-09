import 'package:flutter/foundation.dart';
import 'package:rentora_app/models/cart_model.dart';
import 'package:rentora_app/models/product_model.dart';

class CartController {
  static final CartController _instance = CartController._internal();

  factory CartController() {
    return _instance;
  }

  CartController._internal();

  final ValueNotifier<List<CartModel>> cartItemsNotifier =
      ValueNotifier<List<CartModel>>([]);

  void addToCart(ProductModel product) {
    final List<CartModel> currentItems =
        List<CartModel>.from(cartItemsNotifier.value);
    for (var item in currentItems) {
      if (item.product.id == product.id) {
        item.quantity++;
        cartItemsNotifier.value = currentItems;
        return;
      }
    }
    currentItems.add(CartModel(product: product));
    cartItemsNotifier.value = currentItems;
  }

  void removeFromCart(CartModel cartItem) {
    final List<CartModel> currentItems =
        List<CartModel>.from(cartItemsNotifier.value);
    currentItems.remove(cartItem);
    cartItemsNotifier.value = currentItems;
  }

  void clearCart() {
    cartItemsNotifier.value = [];
  }

  int get cartItemCount {
    return cartItemsNotifier.value.length;
  }

  void dispose() {
    cartItemsNotifier.dispose();
  }
}


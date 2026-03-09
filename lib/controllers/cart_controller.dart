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
  final ValueNotifier<Map<int, int>> daysPerStoreNotifier =
      ValueNotifier<Map<int, int>>({});

  int? getMaxDaysForStore(int storeId) {
    final itemsForStore = cartItemsNotifier.value
        .where((item) => item.product.userId == storeId)
        .toList();

    if (itemsForStore.isNotEmpty) {
      return itemsForStore
          .map((item) => item.product.maxHariPinjam)
          .reduce((min, current) => current < min ? current : min);
    }
    return null;
  }

  void updateDaysForStore(int storeId, int days) {
    final maxDays = getMaxDaysForStore(storeId);
    int cappedDays = days;

    if (maxDays != null && days > maxDays) {
      cappedDays = maxDays;
    }

    // Ensure days don't go below 1
    if (cappedDays < 1) {
      cappedDays = 1;
    }

    final currentDaysMap = Map<int, int>.from(daysPerStoreNotifier.value);

    // Only update if the value is different to avoid unnecessary rebuilds
    if (currentDaysMap[storeId] != cappedDays) {
      currentDaysMap[storeId] = cappedDays;
      daysPerStoreNotifier.value = currentDaysMap;
    }
  }

  void addToCart(ProductModel product) {
    final List<CartModel> currentItems =
        List<CartModel>.from(cartItemsNotifier.value);
    bool isNewItem = true;
    for (var item in currentItems) {
      if (item.product.id == product.id) {
        item.quantity++;
        cartItemsNotifier.value = currentItems;
        isNewItem = false;
        break;
      }
    }

    if (isNewItem) {
      currentItems.add(CartModel(product: product));
      cartItemsNotifier.value = currentItems;
    }

    final currentDaysMap = Map<int, int>.from(daysPerStoreNotifier.value);
    if (!currentDaysMap.containsKey(product.userId)) {
      currentDaysMap[product.userId] = 7; // Default 7 days
      daysPerStoreNotifier.value = currentDaysMap;
    }

    // After adding a new item, the max days might have changed, so we need to re-validate.
    final maxDays = getMaxDaysForStore(product.userId);
    if (maxDays != null && currentDaysMap[product.userId]! > maxDays) {
      updateDaysForStore(product.userId, maxDays);
    }
  }

  void removeFromCart(CartModel cartItem) {
    final List<CartModel> currentItems =
        List<CartModel>.from(cartItemsNotifier.value);
    currentItems.remove(cartItem);
    cartItemsNotifier.value = currentItems;

    final storeId = cartItem.product.userId;
    bool isStoreEmpty =
        !currentItems.any((item) => item.product.userId == storeId);
    if (isStoreEmpty) {
      final currentDaysMap = Map<int, int>.from(daysPerStoreNotifier.value);
      currentDaysMap.remove(storeId);
      daysPerStoreNotifier.value = currentDaysMap;
    } else {
      // If the removed item was the one setting the lowest max-day limit, we need to re-validate.
      final maxDays = getMaxDaysForStore(storeId);
      final currentDays = daysPerStoreNotifier.value[storeId];
      if (maxDays != null && currentDays != null && currentDays > maxDays) {
        updateDaysForStore(storeId, maxDays);
      }
    }
  }

  void clearCart() {
    cartItemsNotifier.value = [];
    daysPerStoreNotifier.value = {};
  }

  int get cartItemCount {
    return cartItemsNotifier.value.length;
  }

  void dispose() {
    cartItemsNotifier.dispose();
    daysPerStoreNotifier.dispose();
  }
}


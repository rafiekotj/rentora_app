import 'package:flutter/material.dart';

import 'package:rentora_app/controllers/store_controller.dart';
import 'package:rentora_app/models/cart_model.dart';
import 'package:rentora_app/controllers/user_controller.dart';
import 'package:rentora_app/services/database/cart_service.dart';

class CartController {
  static final CartController _instance = CartController._internal();
  final UserController _userController = UserController();
  final StoreController _storeController = StoreController();
  final CartService _cartService = CartService();

  factory CartController() {
    return _instance;
  }

  CartController._internal() {
    loadCartFromDB();
  }

  final ValueNotifier<List<CartModel>> cartItemsNotifier = ValueNotifier([]);
  final ValueNotifier<String?> selectedStoreUid = ValueNotifier(null);
  final ValueNotifier<List<String>> selectedProductUids = ValueNotifier([]);

  Future<void> loadCartFromDB() async {
    final user = await _userController.getCurrentUser();
    if (user?.uid == null) {
      cartItemsNotifier.value = [];
      selectedStoreUid.value = null;
      selectedProductUids.value = [];
      return;
    }
    final cartList = await _cartService.getAllCart(userUid: user!.uid);
    cartItemsNotifier.value = cartList;
  }

  void selectStore(String storeUid) {
    if (selectedStoreUid.value == storeUid) {
      selectedStoreUid.value = null;
      selectedProductUids.value = [];
    } else {
      selectedStoreUid.value = storeUid;
      final storeProductUids = cartItemsNotifier.value
          .where((item) => item.product.storeUid == storeUid)
          .map((item) => item.product.uid)
          .whereType<String>()
          .toList();
      selectedProductUids.value = storeProductUids;
    }
  }

  void selectProduct(String productUid) {
    final newSelectedProductUids = List<String>.from(selectedProductUids.value);
    if (newSelectedProductUids.contains(productUid)) {
      newSelectedProductUids.remove(productUid);
    } else {
      newSelectedProductUids.add(productUid);
    }
    selectedProductUids.value = newSelectedProductUids;

    final currentStoreUid = selectedStoreUid.value;
    if (currentStoreUid != null) {
      final hasSelectedProductInCurrentStore = cartItemsNotifier.value.any(
        (item) =>
            item.product.storeUid == currentStoreUid &&
            newSelectedProductUids.contains(item.product.uid),
      );

      if (!hasSelectedProductInCurrentStore) {
        selectedStoreUid.value = null;
      }
    }
  }

  Future<void> addToCart(CartModel cartItem) async {
    final user = await _userController.getCurrentUser();
    final userUid = user?.uid;
    if (userUid == null || userUid.isEmpty) {
      throw Exception('User belum login');
    }

    final store = await _storeController.getStoreById(
      cartItem.product.storeUid,
    );
    if (store != null && store.userUid == user!.uid) {
      throw Exception('Tidak bisa menambahkan produk sendiri ke keranjang');
    }

    final existingIndex = cartItemsNotifier.value.indexWhere(
      (element) => element.product.uid == cartItem.product.uid,
    );
    if (existingIndex >= 0) {
      cartItemsNotifier.value[existingIndex].quantity += cartItem.quantity;
    } else {
      final docRef = await _cartService.cartsCollection.add({
        'userUid': userUid,
        ...cartItem.toMap(),
      });
      await _cartService.cartsCollection.doc(docRef.id).update({
        'uid': docRef.id,
      });
      final newCart = CartModel(
        uid: docRef.id,
        product: cartItem.product,
        quantity: cartItem.quantity,
        rentalDays: cartItem.rentalDays,
      );
      cartItemsNotifier.value = [...cartItemsNotifier.value, newCart];
    }
  }

  Future<void> removeFromCart(String cartUid) async {
    await _cartService.deleteCart(cartUid);
    cartItemsNotifier.value = cartItemsNotifier.value
        .where((e) => e.uid != cartUid)
        .toList();
  }

  Future<void> updateCartQuantity(
    String cartUid,
    CartModel cartItem,
    int quantity,
  ) async {
    cartItem.quantity = quantity;
    await _cartService.updateCart(cartUid, cartItem);
    cartItemsNotifier.value = List.from(cartItemsNotifier.value);
  }

  Future<void> updateRentalDays(
    String cartUid,
    CartModel cartItem,
    int days,
  ) async {
    cartItem.rentalDays = days;
    await _cartService.updateCart(cartUid, cartItem);
    cartItemsNotifier.value = List.from(cartItemsNotifier.value);
  }

  void removeMultipleLocally(List<String> cartUids) {
    cartItemsNotifier.value = cartItemsNotifier.value
        .where((e) => !cartUids.contains(e.uid))
        .toList();
  }
}

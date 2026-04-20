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
    if (user == null) {
      // Jika user belum login, kosongkan cart dan pilihan
      cartItemsNotifier.value = [];
      selectedStoreUid.value = null;
      selectedProductUids.value = [];
    } else {
      // Jika user sudah login, ambil cart dari database
      final cartList = await _cartService.getAllCart(userUid: user.uid);
      cartItemsNotifier.value = cartList;
    }
  }

  void selectStore(String storeUid) {
    // Jika store yang dipilih sama dengan yang sudah dipilih, batalkan pilihan
    if (selectedStoreUid.value == storeUid) {
      selectedStoreUid.value = null;
      selectedProductUids.value = [];
      return;
    }
    // Pilih store dan produk-produk di store tersebut
    selectedStoreUid.value = storeUid;
    selectedProductUids.value = cartItemsNotifier.value
        .where((item) => item.product.storeUid == storeUid)
        .map((item) => item.product.uid)
        .whereType<String>()
        .toList();
  }

  void selectProduct(String productUid) {
    // Salin daftar produk yang dipilih
    final newSelectedProductUids = List<String>.from(selectedProductUids.value);
    if (newSelectedProductUids.contains(productUid)) {
      // Jika produk sudah dipilih, hapus dari daftar
      newSelectedProductUids.remove(productUid);
    } else {
      // Jika produk belum dipilih, tambahkan ke daftar
      newSelectedProductUids.add(productUid);
    }
    selectedProductUids.value = newSelectedProductUids;

    // Jika tidak ada produk dari store yang sedang dipilih, batalkan pilihan store
    final currentStoreUid = selectedStoreUid.value;
    if (currentStoreUid != null) {
      final adaProdukDiStore = cartItemsNotifier.value.any(
        (item) =>
            item.product.storeUid == currentStoreUid &&
            newSelectedProductUids.contains(item.product.uid),
      );
      if (!adaProdukDiStore) {
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

    // Tidak boleh menambah produk sendiri ke keranjang
    final store = await _storeController.getStoreById(
      cartItem.product.storeUid,
    );
    if (store != null && store.userUid == userUid) {
      throw Exception('Tidak bisa menambahkan produk sendiri ke keranjang');
    }

    // Cek apakah produk sudah ada di cart
    final existingIndex = cartItemsNotifier.value.indexWhere(
      (element) => element.product.uid == cartItem.product.uid,
    );
    if (existingIndex >= 0) {
      // Jika sudah ada, tambahkan jumlahnya
      cartItemsNotifier.value[existingIndex].quantity += cartItem.quantity;
    } else {
      // Jika belum ada, tambahkan ke database dan cart
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
    // Hapus item dari cart secara lokal
    cartItemsNotifier.value = cartItemsNotifier.value
        .where((e) => e.uid != cartUid)
        .toList();
  }

  Future<void> updateCartQuantity(
    String cartUid,
    CartModel cartItem,
    int quantity,
  ) async {
    // Update jumlah item di cart
    cartItem.quantity = quantity;
    await _cartService.updateCart(cartUid, cartItem);
    cartItemsNotifier.value = List.from(cartItemsNotifier.value);
  }

  Future<void> updateRentalDays(
    String cartUid,
    CartModel cartItem,
    int days,
  ) async {
    // Update lama sewa item di cart
    cartItem.rentalDays = days;
    await _cartService.updateCart(cartUid, cartItem);
    cartItemsNotifier.value = List.from(cartItemsNotifier.value);
  }

  void removeMultipleLocally(List<String> cartUids) {
    // Hapus beberapa item dari cart secara lokal
    cartItemsNotifier.value = cartItemsNotifier.value
        .where((e) => !cartUids.contains(e.uid))
        .toList();
  }
}

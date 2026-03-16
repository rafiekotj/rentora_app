import 'package:rentora_app/controllers/store_controller.dart';
import 'package:rentora_app/controllers/user_controller.dart';
import 'package:rentora_app/models/cart_model.dart';
import 'package:rentora_app/models/transaction_model.dart';
import 'package:rentora_app/services/database/sqflite.dart';

class TransactionController {
  final UserController _userController = UserController();
  final StoreController _storeController = StoreController();

  Future<int> createTransaction({
    required List<CartModel> cartItems,
    required String paymentMethod,
    required String paymentLabel,
    required int serviceFee,
  }) async {
    final user = await _userController.getCurrentUser();
    if (user?.id == null) {
      throw Exception('User belum login');
    }

    if (cartItems.isEmpty) {
      throw Exception('Item checkout kosong');
    }

    final storeId = cartItems.first.product.storeId;
    final store = await _storeController.getStoreById(storeId);

    int subtotal = 0;
    int totalProducts = 0;
    for (final item in cartItems) {
      subtotal += item.product.hargaPerHari * item.quantity * item.rentalDays;
      totalProducts += item.quantity;
    }

    final rentalDays = cartItems.first.rentalDays;
    final totalPayment = subtotal + serviceFee;
    final status = paymentMethod == 'cod' ? 'Belum Bayar' : 'Diproses';

    final transaction = TransactionModel(
      userId: user!.id!,
      storeId: storeId,
      storeName: store?.name ?? 'Toko',
      status: status,
      paymentMethod: paymentMethod,
      paymentLabel: paymentLabel,
      items: cartItems,
      totalProducts: totalProducts,
      rentalDays: rentalDays,
      subtotal: subtotal,
      serviceFee: serviceFee,
      totalPayment: totalPayment,
      createdAt: DateTime.now().toIso8601String(),
    );

    for (final item in cartItems) {
      final productId = item.product.id;
      if (productId == null) {
        throw Exception('Produk checkout tidak valid');
      }

      await DBHelper.reduceProductStock(
        productId: productId,
        quantity: item.quantity,
      );
    }

    return DBHelper.insertTransaction(transaction);
  }

  Future<List<TransactionModel>> getCurrentUserTransactions() async {
    final user = await _userController.getCurrentUser();
    if (user?.id == null) {
      return [];
    }

    return DBHelper.getTransactionsByUser(userId: user!.id!);
  }

  Future<int> getPendingShipmentCountForCurrentSeller() async {
    final user = await _userController.getCurrentUser();
    if (user?.id == null) {
      return 0;
    }

    final store = await _storeController.getStoreByUserId(user!.id!);
    if (store?.id == null) {
      return 0;
    }

    final transactions = await DBHelper.getTransactionsByStore(
      storeId: store!.id!,
      statuses: const ['Belum Bayar', 'Diproses'],
    );

    int totalItems = 0;
    for (final transaction in transactions) {
      for (final item in transaction.items) {
        totalItems += item.quantity;
      }
    }

    return totalItems;
  }
}

import 'package:rentora_app/controllers/store_controller.dart';
import 'package:rentora_app/controllers/user_controller.dart';
import 'package:rentora_app/models/cart_model.dart';
import 'package:rentora_app/models/transaction_model.dart';
import 'package:rentora_app/services/database/transaction_service.dart';

class TransactionController {
  final UserController _userController = UserController();
  final StoreController _storeController = StoreController();
  final TransactionService _transactionService = TransactionService();

  Future<String> createTransaction({
    required List<CartModel> cartItems,
    required String paymentMethod,
    required String paymentLabel,
    required int serviceFee,
  }) async {
    final user = await _userController.getCurrentUser();
    if (user?.uid == null) {
      throw Exception('User belum login');
    }

    if (cartItems.isEmpty) {
      throw Exception('Item checkout kosong');
    }

    final storeUid = cartItems.first.product.storeUid;
    final store = await _storeController.getStoreById(storeUid);

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
      uid: '',
      userUid: user!.uid,
      storeUid: storeUid,
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

    return await _transactionService.createTransaction(transaction);
  }

  Future<List<TransactionModel>> getCurrentUserTransactions() async {
    final user = await _userController.getCurrentUser();
    if (user?.uid == null) {
      return [];
    }
    return await _transactionService.getTransactionsByUser(user!.uid);
  }

  Future<int> getPendingShipmentCountForCurrentSeller() async {
    final user = await _userController.getCurrentUser();
    if (user?.uid == null) {
      return 0;
    }

    final store = await _storeController.getStoreByUserId(user!.uid);
    if (store == null) {
      return 0;
    }

    final transactions = await _transactionService.getTransactionsByStore(
      store.uid,
      ['Belum Bayar', 'Diproses'],
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

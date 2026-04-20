import 'package:rentora_app/controllers/store_controller.dart';
import 'package:rentora_app/controllers/user_controller.dart';
import 'package:rentora_app/models/cart_model.dart';
import 'package:rentora_app/models/store_model.dart';
import 'package:rentora_app/models/transaction_model.dart';
import 'package:rentora_app/services/database/transaction_service.dart';

class TransactionController {
  final UserController _userController = UserController();
  final StoreController _storeController = StoreController();
  final TransactionService _transactionService = TransactionService();

  StoreController get storeController => _storeController;
  TransactionService get transactionService => _transactionService;

  Future<String> createTransaction({
    required List<CartModel> cartItems,
    required String paymentMethod,
    required String paymentLabel,
    required int serviceFee,
    String? storeName,
  }) async {
    // Ambil user yang sedang login
    final user = await _userController.getCurrentUser();
    if (user?.uid == null) {
      throw Exception('User belum login');
    }

    // Cek jika cart kosong
    if (cartItems.isEmpty) {
      throw Exception('Item checkout kosong');
    }

    // Ambil store jika perlu
    final storeUid = cartItems.first.product.storeUid;
    StoreModel? store;
    if (storeName == null) {
      store = await _storeController.getStoreById(storeUid);
    }

    // Hitung subtotal dan total produk
    int subtotal = 0;
    int totalProducts = 0;
    for (final item in cartItems) {
      subtotal += item.product.hargaPerHari * item.quantity * item.rentalDays;
      totalProducts += item.quantity;
    }

    final rentalDays = cartItems.first.rentalDays;
    final totalPayment = subtotal + serviceFee;
    final status = paymentMethod == 'cod' ? 'Belum Bayar' : 'Diproses';

    // Buat model transaksi
    final transaction = TransactionModel(
      uid: '',
      userUid: user!.uid,
      storeUid: storeUid,
      storeName: storeName ?? store?.name ?? 'Toko',
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

  Future<String> createTransactionAndClearCarts({
    required List<CartModel> cartItems,
    required String paymentMethod,
    required String paymentLabel,
    required int serviceFee,
    String? userUid,
    String? storeName,
  }) async {
    // Ambil user yang sedang login (atau dari argumen)
    final currentUserUid =
        userUid ?? (await _userController.getCurrentUser())?.uid;
    if (currentUserUid == null) {
      throw Exception('User belum login');
    }

    // Cek jika cart kosong
    if (cartItems.isEmpty) {
      throw Exception('Item checkout kosong');
    }

    // Ambil store jika perlu
    final storeUid = cartItems.first.product.storeUid;
    StoreModel? store;
    if (storeName == null) {
      store = await _storeController.getStoreById(storeUid);
    }

    // Hitung subtotal dan total produk
    int subtotal = 0;
    int totalProducts = 0;
    for (final item in cartItems) {
      subtotal += item.product.hargaPerHari * item.quantity * item.rentalDays;
      totalProducts += item.quantity;
    }

    final rentalDays = cartItems.first.rentalDays;
    final totalPayment = subtotal + serviceFee;
    final status = paymentMethod == 'cod' ? 'Belum Bayar' : 'Diproses';

    // Buat model transaksi
    final transaction = TransactionModel(
      uid: '',
      userUid: currentUserUid,
      storeUid: storeUid,
      storeName: storeName ?? store?.name ?? 'Toko',
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

    // Ambil id cart untuk dihapus
    final cartIds = cartItems.map((e) => e.uid).whereType<String>().toList();
    return await _transactionService.createTransactionAndClearCarts(
      transaction,
      cartIds,
    );
  }

  Future<List<TransactionModel>> getCurrentUserTransactions() async {
    // Ambil transaksi milik user yang sedang login
    final user = await _userController.getCurrentUser();
    if (user?.uid == null) {
      return [];
    }
    return await _transactionService.getTransactionsByUser(user!.uid);
  }

  Future<int> getPendingShipmentCountForCurrentSeller() async {
    // Hitung jumlah item yang belum dikirim untuk seller
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

  Future<int> getRentedItemCountForCurrentSeller() async {
    // Hitung jumlah item yang sedang disewa untuk seller
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
      ['Disewa', 'Sedang Disewa'],
    );

    int totalItems = 0;
    for (final transaction in transactions) {
      for (final item in transaction.items) {
        totalItems += item.quantity;
      }
    }

    return totalItems;
  }

  Future<int> getReturnedItemCountForCurrentSeller() async {
    // Hitung jumlah item yang sudah dikembalikan untuk seller
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
      ['Dikembalikan'],
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

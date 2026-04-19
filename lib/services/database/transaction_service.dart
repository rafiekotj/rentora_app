import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentora_app/models/transaction_model.dart';

class TransactionService {
  final CollectionReference transactionsCollection = FirebaseFirestore.instance
      .collection('transactions');

  final CollectionReference cartsCollection = FirebaseFirestore.instance
      .collection('carts');

  final CollectionReference notificationsCollection = FirebaseFirestore.instance
      .collection('outgoing_notifications');

  Future<String> createTransaction(TransactionModel transaction) async {
    final docRef = transactionsCollection.doc();
    final data = transaction.toMap();
    data['uid'] = docRef.id;
    await docRef.set(data);
    return docRef.id;
  }

  Future<String> createTransactionAndClearCarts(
    TransactionModel transaction,
    List<String> cartIds,
  ) async {
    final batch = FirebaseFirestore.instance.batch();

    final docRef = transactionsCollection.doc();
    final data = transaction.toMap();
    data['uid'] = docRef.id;
    batch.set(docRef, data);

    for (final cartId in cartIds) {
      batch.delete(cartsCollection.doc(cartId));
    }

    try {
      final noteRef = notificationsCollection.doc();
      batch.set(noteRef, {
        'uid': noteRef.id,
        'type': 'transaction_created',
        'transaction_uid': docRef.id,
        'store_uid': transaction.storeUid,
        'buyer_uid': transaction.userUid,
        'title': 'Pesanan Baru',
        'body': 'Pesanan Anda sedang diproses oleh penjual.',
        'created_at': FieldValue.serverTimestamp(),
        'processed': false,
      });
    } catch (_) {}

    await batch.commit();
    return docRef.id;
  }

  Future<List<TransactionModel>> getTransactionsByUser(String userUid) async {
    final snapshot = await transactionsCollection
        .where('user_uid', isEqualTo: userUid)
        .get();
    return snapshot.docs
        .map(
          (doc) => TransactionModel.fromMap(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<TransactionModel>> getTransactionsByStore(
    String storeUid,
    List<String> statuses,
  ) async {
    final snapshot = await transactionsCollection
        .where('store_uid', isEqualTo: storeUid)
        .where('status', whereIn: statuses)
        .get();
    return snapshot.docs
        .map(
          (doc) => TransactionModel.fromMap(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> updateTransactionStatus(String uid, String status) async {
    await transactionsCollection.doc(uid).update({'status': status});
  }
}

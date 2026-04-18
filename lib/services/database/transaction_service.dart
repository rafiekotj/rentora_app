import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentora_app/models/transaction_model.dart';

class TransactionService {
  final CollectionReference transactionsCollection = FirebaseFirestore.instance
      .collection('transactions');

  Future<String> createTransaction(TransactionModel transaction) async {
    final docRef = await transactionsCollection.add(transaction.toMap());
    // Update field uid di dokumen agar sesuai dengan doc id
    await transactionsCollection.doc(docRef.id).update({'uid': docRef.id});
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

import 'dart:convert';

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
    // Buat transaksi baru dan simpan ke database
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
    // Buat transaksi baru, hapus cart, dan update stok produk dalam satu batch
    final batch = FirebaseFirestore.instance.batch();

    final docRef = transactionsCollection.doc();
    final data = transaction.toMap();
    data['uid'] = docRef.id;
    batch.set(docRef, data);

    // Hapus semua cart yang sudah di-checkout
    for (final cartId in cartIds) {
      batch.delete(cartsCollection.doc(cartId));
    }

    // Tambah notifikasi transaksi baru
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

    // Jika status transaksi sudah 'Diproses', stok produk langsung dikurangi
    try {
      if (transaction.status.toLowerCase() == 'diproses') {
        final productsCollection = FirebaseFirestore.instance.collection(
          'products',
        );
        for (final item in transaction.items) {
          try {
            final productUid = item.product.uid;
            final qty = item.quantity;
            batch.update(productsCollection.doc(productUid), {
              'stok': FieldValue.increment(-qty),
            });
          } catch (_) {}
        }
      }
    } catch (_) {}

    await batch.commit();
    return docRef.id;
  }

  Future<List<TransactionModel>> getTransactionsByUser(String userUid) async {
    // Ambil semua transaksi milik user tertentu
    final snapshot = await transactionsCollection
        .where('user_uid', isEqualTo: userUid)
        .get(const GetOptions(source: Source.serverAndCache));
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
    // Ambil semua transaksi milik store tertentu dengan status tertentu
    final snapshot = await transactionsCollection
        .where('store_uid', isEqualTo: storeUid)
        .where('status', whereIn: statuses)
        .get(const GetOptions(source: Source.serverAndCache));
    return snapshot.docs
        .map(
          (doc) => TransactionModel.fromMap(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> updateTransactionStatus(String uid, String status) async {
    // Update status transaksi dan stok produk jika perlu
    final txRef = transactionsCollection.doc(uid);
    final doc = await txRef.get(
      const GetOptions(source: Source.serverAndCache),
    );
    if (!doc.exists) {
      throw Exception('Transaction not found: $uid');
    }
    final data = doc.data() as Map<String, dynamic>;
    final oldStatus = (data['status'] as String?) ?? '';
    if (oldStatus == status) return;

    final batch = FirebaseFirestore.instance.batch();
    batch.update(txRef, {'status': status});

    // Parse items_data (bisa string JSON atau list)
    List<dynamic> items = [];
    try {
      if (data['items_data'] is String) {
        items = jsonDecode(data['items_data'] as String) as List<dynamic>;
      } else if (data['items_data'] is List) {
        items = data['items_data'] as List<dynamic>;
      }
    } catch (_) {
      items = [];
    }

    final productsCollection = FirebaseFirestore.instance.collection(
      'products',
    );

    // Jika status berubah ke 'Diproses', stok produk dikurangi
    if (oldStatus.toLowerCase() != 'diproses' &&
        status.toLowerCase() == 'diproses') {
      for (final raw in items) {
        try {
          String? productUid;
          int qty = 1;
          if (raw is Map<String, dynamic>) {
            if (raw.containsKey('product_uid')) {
              productUid = raw['product_uid']?.toString();
            }
            if (raw.containsKey('product_data')) {
              final prod = raw['product_data'];
              if (productUid == null && prod is String) {
                try {
                  final parsed = jsonDecode(prod) as Map<String, dynamic>;
                  productUid = parsed['uid']?.toString();
                } catch (_) {}
              } else if (productUid == null && prod is Map) {
                productUid = prod['uid']?.toString();
              }
            }
            if (raw.containsKey('quantity')) {
              final q = raw['quantity'];
              qty = (q is int) ? q : int.tryParse(q.toString()) ?? 1;
            }
          }
          if (productUid != null && productUid.isNotEmpty) {
            batch.update(productsCollection.doc(productUid), {
              'stok': FieldValue.increment(-qty),
            });
          }
        } catch (_) {}
      }
    }

    // Jika status berubah ke 'Dikembalikan', stok produk dikembalikan
    if (oldStatus.toLowerCase() != 'dikembalikan' &&
        status.toLowerCase() == 'dikembalikan') {
      for (final raw in items) {
        try {
          String? productUid;
          int qty = 1;
          if (raw is Map<String, dynamic>) {
            if (raw.containsKey('product_uid')) {
              productUid = raw['product_uid']?.toString();
            }
            if (raw.containsKey('product_data')) {
              final prod = raw['product_data'];
              if (productUid == null && prod is String) {
                try {
                  final parsed = jsonDecode(prod) as Map<String, dynamic>;
                  productUid = parsed['uid']?.toString();
                } catch (_) {}
              } else if (productUid == null && prod is Map) {
                productUid = prod['uid']?.toString();
              }
            }
            if (raw.containsKey('quantity')) {
              final q = raw['quantity'];
              qty = (q is int) ? q : int.tryParse(q.toString()) ?? 1;
            }
          }
          if (productUid != null && productUid.isNotEmpty) {
            batch.update(productsCollection.doc(productUid), {
              'stok': FieldValue.increment(qty),
            });
          }
        } catch (_) {}
      }
    }

    await batch.commit();
  }
}

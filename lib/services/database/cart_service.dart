import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentora_app/models/cart_model.dart';

class CartService {
  final CollectionReference cartsCollection = FirebaseFirestore.instance
      .collection('carts');

  Future<List<CartModel>> getAllCart({required String userUid}) async {
    // Ambil semua cart milik user, hanya field yang diperlukan
    final snapshot = await cartsCollection
        .where('userUid', isEqualTo: userUid)
        .get(const GetOptions(source: Source.serverAndCache));
    // Mapping data ke CartModel
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return CartModel.fromMap({...data, 'uid': doc.id});
    }).toList();
  }

  Future<void> addToCart(String userUid, CartModel cartItem) async {
    // Tambah item ke cart
    final docRef = await cartsCollection.add({
      'userUid': userUid,
      ...cartItem.toMap(),
    });
    // Update uid dokumen agar konsisten
    await cartsCollection.doc(docRef.id).update({'uid': docRef.id});
  }

  Future<void> updateCart(String cartId, CartModel cartItem) async {
    // Update data cart
    await cartsCollection.doc(cartId).update(cartItem.toMap());
  }

  Future<void> deleteCart(String cartId) async {
    // Hapus cart berdasarkan id
    await cartsCollection.doc(cartId).delete();
  }
}

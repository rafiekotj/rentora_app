import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentora_app/models/cart_model.dart';

class CartService {
  final CollectionReference cartsCollection = FirebaseFirestore.instance
      .collection('carts');

  Future<List<CartModel>> getAllCart({required String userUid}) async {
    final snapshot = await cartsCollection
        .where('userUid', isEqualTo: userUid)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      // Pastikan uid selalu sama dengan doc.id
      return CartModel.fromMap({...data, 'uid': doc.id});
    }).toList();
  }

  Future<void> addToCart(String userUid, CartModel cartItem) async {
    final docRef = await cartsCollection.add({
      'userUid': userUid,
      ...cartItem.toMap(),
    });
    // Update field uid di Firestore agar sync dengan doc id
    await cartsCollection.doc(docRef.id).update({'uid': docRef.id});
    // JANGAN lupa update juga cartItem.uid di objek lokal jika perlu (di controller)
  }

  Future<void> updateCart(String cartId, CartModel cartItem) async {
    await cartsCollection.doc(cartId).update(cartItem.toMap());
  }

  Future<void> deleteCart(String cartId) async {
    await cartsCollection.doc(cartId).delete();
  }
}

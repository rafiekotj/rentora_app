import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentora_app/models/cart_model.dart';

class CartService {
  final CollectionReference cartsCollection = FirebaseFirestore.instance
      .collection('carts');

  Future<List<CartModel>> getAllCart({required String userUid}) async {
    final snapshot = await cartsCollection
        .where('userUid', isEqualTo: userUid)
        .get();
    return snapshot.docs
        .map((doc) => CartModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addToCart(String userUid, CartModel cartItem) async {
    await cartsCollection.add({'userUid': userUid, ...cartItem.toMap()});
  }

  Future<void> updateCart(String cartId, CartModel cartItem) async {
    await cartsCollection.doc(cartId).update(cartItem.toMap());
  }

  Future<void> deleteCart(String cartId) async {
    await cartsCollection.doc(cartId).delete();
  }
}

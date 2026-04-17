import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentora_app/models/user_model.dart';

class UserFirestoreService {
  static final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance;

  static Future<UserModel?> getUserByEmail(String email) async {
    final query = await _firebaseFirestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      return UserModel.fromMap(query.docs.first.data());
    }
    return null;
  }

  static Future<void> updateUser({
    required String uid,
    String? username,
    String? phone,
    String? image,
  }) async {
    final data = <String, dynamic>{};
    if (username != null) data['username'] = username;
    if (phone != null) data['phone'] = phone;
    if (image != null) data['image'] = image;
    await _firebaseFirestore.collection('users').doc(uid).update(data);
  }

  static Future<UserModel?> getUserByUid(String uid) async {
    final doc = await _firebaseFirestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }
}

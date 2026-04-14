import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rentora_app/models/user_model.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<UserModel> registerUser({
    required String email,
    required String password,
    required String username,
    required String phone,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user!;
    final model = UserModel(
      uid: user.uid,
      email: email,
      phone: phone,
      username: username,
      image: null,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(model.toMap());
    return model;
  }

  static Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }
}

import 'dart:convert';
import 'product_model.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class CartModel {
  final String uid;
  final ProductModel product;
  int quantity;
  int rentalDays;

  CartModel({
    required this.uid,
    required this.product,
    this.quantity = 1,
    this.rentalDays = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'product_uid': product.uid,
      'store_uid': product.storeUid,
      'quantity': quantity,
      'rental_days': rentalDays,
      'product_data': jsonEncode(product.toMap()),
    };
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      uid: map['uid'] as String,
      quantity: map['quantity'] as int,
      rentalDays: map['rental_days'] as int,
      product: ProductModel.fromMap(jsonDecode(map['product_data'] as String)),
    );
  }
}

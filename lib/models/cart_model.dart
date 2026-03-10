import 'dart:convert';
import 'product_model.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class CartModel {
  final int? id;
  final ProductModel product;
  int quantity;
  int rentalDays;

  CartModel({
    this.id,
    required this.product,
    this.quantity = 1,
    this.rentalDays = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': product.id,
      'store_id': product.storeId,
      'quantity': quantity,
      'rental_days': rentalDays,
      'product_data': jsonEncode(product.toMap()),
    };
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      id: map['id'] as int?,
      quantity: map['quantity'] as int,
      rentalDays: map['rental_days'] as int,
      product: ProductModel.fromMap(jsonDecode(map['product_data'] as String)),
    );
  }
}

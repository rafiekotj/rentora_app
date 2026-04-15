import 'dart:convert';

import 'package:rentora_app/models/cart_model.dart';

class TransactionModel {
  final String uid;
  final String userUid;
  final String storeUid;
  final String storeName;
  final String status;
  final String paymentMethod;
  final String paymentLabel;
  final List<CartModel> items;
  final int totalProducts;
  final int rentalDays;
  final int subtotal;
  final int serviceFee;
  final int totalPayment;
  final String createdAt;

  TransactionModel({
    required this.uid,
    required this.userUid,
    required this.storeUid,
    required this.storeName,
    required this.status,
    required this.paymentMethod,
    required this.paymentLabel,
    required this.items,
    required this.totalProducts,
    required this.rentalDays,
    required this.subtotal,
    required this.serviceFee,
    required this.totalPayment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'user_uid': userUid,
      'store_uid': storeUid,
      'store_name': storeName,
      'status': status,
      'payment_method': paymentMethod,
      'payment_label': paymentLabel,
      'items_data': jsonEncode(items.map((e) => e.toMap()).toList()),
      'total_products': totalProducts,
      'rental_days': rentalDays,
      'subtotal': subtotal,
      'service_fee': serviceFee,
      'total_payment': totalPayment,
      'created_at': createdAt,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    final decodedItems =
        jsonDecode(map['items_data'] as String) as List<dynamic>;

    return TransactionModel(
      uid: map['uid'] as String,
      userUid: map['user_uid'] as String,
      storeUid: map['store_uid'] as String,
      storeName: map['store_name'] as String? ?? '-',
      status: map['status'] as String,
      paymentMethod: map['payment_method'] as String,
      paymentLabel: map['payment_label'] as String,
      items: decodedItems
          .map((e) => CartModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      totalProducts: map['total_products'] as int,
      rentalDays: map['rental_days'] as int,
      subtotal: map['subtotal'] as int,
      serviceFee: map['service_fee'] as int,
      totalPayment: map['total_payment'] as int,
      createdAt: map['created_at'] as String,
    );
  }
}

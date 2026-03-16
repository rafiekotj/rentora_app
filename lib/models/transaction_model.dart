import 'dart:convert';

import 'package:rentora_app/models/cart_model.dart';

class TransactionModel {
  final int? id;
  final int userId;
  final int storeId;
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
    this.id,
    required this.userId,
    required this.storeId,
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
      'id': id,
      'user_id': userId,
      'store_id': storeId,
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
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      storeId: map['store_id'] as int,
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

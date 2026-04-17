import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/core/utils/app_formatters.dart';
import 'package:rentora_app/models/cart_model.dart';
import 'package:rentora_app/models/product_model.dart';
import 'package:rentora_app/models/transaction_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final TransactionModel transaction;

  const OrderDetailScreen({super.key, required this.transaction});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('dd-MM-yyyy HH:mm').format(dt);
    } catch (_) {
      return iso;
    }
  }

  Map<String, dynamic> _normalizeItem(dynamic item) {
    if (item is Map<String, dynamic>) {
      final product = item['product_data'];
      Map<String, dynamic> prodMap;
      if (product is String) {
        try {
          prodMap = jsonDecode(product) as Map<String, dynamic>;
        } catch (_) {
          prodMap = {};
        }
      } else if (product is Map<String, dynamic>) {
        prodMap = product;
      } else {
        prodMap = {};
      }
      return {
        'product': prodMap,
        'quantity': item['quantity'] ?? 1,
        'rental_days': item['rental_days'] ?? widget.transaction.rentalDays,
      };
    }

    if (item is CartModel) {
      final ProductModel prod = item.product;
      return {
        'product': {
          'images': prod.images,
          'namaProduk': prod.namaProduk,
          'hargaPerHari': prod.hargaPerHari,
        },
        'quantity': item.quantity,
        'rental_days': item.rentalDays,
      };
    }

    return {
      'product': {},
      'quantity': 1,
      'rental_days': widget.transaction.rentalDays,
    };
  }

  Widget _buildProductRow(dynamic rawItem) {
    final item = _normalizeItem(rawItem);
    final product = item['product'] as Map<String, dynamic>;

    List<String> images = [];
    final rawImages = product['images'];
    if (rawImages is String) {
      try {
        final parsed = jsonDecode(rawImages);
        if (parsed is List) images = parsed.map((e) => e.toString()).toList();
      } catch (_) {}
    } else if (rawImages is List) {
      images = List<String>.from(rawImages);
    }

    final firstImage = images.isNotEmpty ? images[0] : null;
    final nama = product['namaProduk'] ?? product['nama'] ?? '-';
    final hargaPerHari = product['hargaPerHari'] ?? 0;
    final quantity = item['quantity'] ?? 1;
    final rentalDays = item['rental_days'] ?? widget.transaction.rentalDays;
    final itemTotal =
        (int.tryParse(hargaPerHari.toString()) ?? 0) *
        (int.tryParse(quantity.toString()) ?? 0) *
        (int.tryParse(rentalDays.toString()) ?? 0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: firstImage != null
                ? Image.network(
                    firstImage,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 72,
                    height: 72,
                    color: AppColor.border,
                    child: const Icon(Icons.image, color: AppColor.textHint),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(
                  'Rp ${AppFormatters.formatRupiah(hargaPerHari)} • x$quantity',
                  style: const TextStyle(color: AppColor.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Rp ${AppFormatters.formatRupiah(itemTotal)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Rincian Pesanan',
          style: TextStyle(color: Colors.black),
        ),
        leading: BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Products
                  Column(
                    children: tx.items.map((e) => _buildProductRow(e)).toList(),
                  ),
                  const Divider(height: 24),
                  // Summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal Produk'),
                      Text('Rp${AppFormatters.formatRupiah(tx.subtotal)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Biaya Layanan'),
                      Text('Rp${AppFormatters.formatRupiah(tx.serviceFee)}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Total Pesanan:',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rp${AppFormatters.formatRupiah(tx.totalPayment)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(child: Text('No. Pesanan')),
                      Text(tx.uid),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Metode Pembayaran'),
                      Text(tx.paymentLabel),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Waktu Pemesanan'),
                      Text(_formatDate(tx.createdAt)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // additional meta rows could go here
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

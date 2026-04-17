import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/core/utils/app_formatters.dart';
import 'package:rentora_app/models/cart_model.dart';
import 'package:rentora_app/models/product_model.dart';

class OrderProductsCard extends StatefulWidget {
  final String storeName;
  final List<dynamic> items;
  final int rentalDays;

  const OrderProductsCard({
    super.key,
    required this.storeName,
    required this.items,
    this.rentalDays = 1,
  });

  @override
  State<OrderProductsCard> createState() => _OrderProductsCardState();
}

class _OrderProductsCardState extends State<OrderProductsCard> {
  bool _expanded = false;

  int _computeTotal() {
    int total = 0;
    for (final item in widget.items) {
      final normalized = _normalizeItem(item);
      final harga = normalized['hargaPerHari'] ?? 0;
      final qty = normalized['quantity'] ?? 0;
      final days = normalized['rental_days'] ?? widget.rentalDays;
      total +=
          (harga is int ? harga : int.tryParse(harga.toString()) ?? 0) *
          (qty is int ? qty : int.tryParse(qty.toString()) ?? 0) *
          (days is int ? days : int.tryParse(days.toString()) ?? 0);
    }
    return total;
  }

  Map<String, dynamic> _normalizeItem(dynamic item) {
    // Return a map with keys: product (Map), quantity, rental_days
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
        'rental_days': item['rental_days'] ?? widget.rentalDays,
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

    // Fallback empty
    return {'product': {}, 'quantity': 1, 'rental_days': widget.rentalDays};
  }

  Widget _buildItem(dynamic rawItem) {
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
    final rentalDays = item['rental_days'] ?? widget.rentalDays;
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
                  'Rp ${AppFormatters.formatRupiah(hargaPerHari)} /hari • ${rentalDays} hari',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColor.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Subtotal: Rp ${AppFormatters.formatRupiah(itemTotal)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'x$quantity',
            style: const TextStyle(color: AppColor.textSecondary),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _computeTotal();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.storeName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              const Text('Selesai', style: TextStyle(color: AppColor.primary)),
            ],
          ),
          const SizedBox(height: 12),
          _buildItem(widget.items[0]),
          if (_expanded)
            Column(
              children: widget.items
                  .sublist(1)
                  .map(
                    (e) => Column(
                      children: [const Divider(height: 1), _buildItem(e)],
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.items.length > 1)
                InkWell(
                  onTap: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Text(
                          _expanded ? 'Sembunyikan' : 'Lihat Lainnya',
                          style: const TextStyle(
                            color: AppColor.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColor.primary,
                        ),
                      ],
                    ),
                  ),
                )
              else
                const SizedBox(),
              Text(
                'Total ${widget.items.length} produk: Rp ${AppFormatters.formatRupiah(total)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

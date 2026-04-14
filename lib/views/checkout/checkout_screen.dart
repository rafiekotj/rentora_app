import 'dart:io';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/controllers/cart_controller.dart';
import 'package:rentora_app/controllers/transaction_controller.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/core/utils/app_formatters.dart';
import 'package:rentora_app/models/cart_model.dart';
import 'package:rentora_app/views/checkout/payment_method_screen.dart';
import 'package:rentora_app/views/checkout/payment_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartModel> cartItems;

  const CheckoutScreen({super.key, required this.cartItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TransactionController _transactionController = TransactionController();
  final CartController _cartController = CartController();

  String selectedMethod = "bank";
  String selectedBankCode = 'bca';
  String selectedBankLabel = 'BCA';
  bool _isPaying = false;
  static const int _serviceFee = 1000;

  bool _isBankMethodCode(String methodCode) {
    return methodCode == 'bca' ||
        methodCode == 'mandiri' ||
        methodCode == 'bni' ||
        methodCode == 'bri';
  }

  String _bankLabelFromCode(String methodCode) {
    switch (methodCode) {
      case 'mandiri':
        return 'Mandiri';
      case 'bca':
        return 'BCA';
      case 'bni':
        return 'BNI';
      case 'bri':
        return 'BRI';
      default:
        return methodCode;
    }
  }

  void _applyPaymentSelection(String methodCode) {
    if (_isBankMethodCode(methodCode)) {
      setState(() {
        selectedMethod = 'bank';
        selectedBankCode = methodCode;
        selectedBankLabel = _bankLabelFromCode(methodCode);
      });
      return;
    }

    if (methodCode == 'qris' || methodCode == 'cod') {
      setState(() {
        selectedMethod = methodCode;
      });
    }
  }

  int get _subtotal {
    int total = 0;
    for (final item in widget.cartItems) {
      total += item.product.hargaPerHari * item.quantity * item.rentalDays;
    }
    return total;
  }

  int get _totalProducts {
    int total = 0;
    for (final item in widget.cartItems) {
      total += item.quantity;
    }
    return total;
  }

  int get _rentalDays {
    if (widget.cartItems.isEmpty) return 0;
    return widget.cartItems.first.rentalDays;
  }

  int get _totalPayment => _subtotal + _serviceFee;

  String get _effectivePaymentMethod {
    return selectedMethod == 'bank' ? selectedBankCode : selectedMethod;
  }

  String get _effectivePaymentLabel {
    switch (_effectivePaymentMethod) {
      case 'bca':
        return 'Transfer Bank - BCA';
      case 'mandiri':
        return 'Transfer Bank - Mandiri';
      case 'bni':
        return 'Transfer Bank - BNI';
      case 'bri':
        return 'Transfer Bank - BRI';
      case 'qris':
        return 'QRIS';
      case 'cod':
        return 'COD';
      default:
        return _effectivePaymentMethod;
    }
  }

  Future<void> _processPayment() async {
    if (_isPaying) return;

    setState(() {
      _isPaying = true;
    });

    try {
      await _transactionController.createTransaction(
        cartItems: widget.cartItems,
        paymentMethod: _effectivePaymentMethod,
        paymentLabel: _effectivePaymentLabel,
        serviceFee: _serviceFee,
      );

      for (final item in widget.cartItems) {
        await _cartController.removeFromCart(item);
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PaymentSuccessScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPaying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.surface,
        title: Text(
          "Pembayaran",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            // ----- PICKUP LOCATION -----
            Container(
              padding: EdgeInsets.all(8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Lokasi Pengambilan",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 162,
                    decoration: BoxDecoration(color: AppColor.textHint),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Symbols.location_pin,
                                  size: 16,
                                  color: AppColor.textHint,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Rafie",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "(+62) 888-8888-8888",
                                  style: TextStyle(
                                    color: AppColor.textHint,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 24),
                                Expanded(
                                  child: Text(
                                    "Jl. Jalan Ks Tubun II C, RW 01, Slipi, Palmerah, West Jakarta, Special Capital Region of Jakarta, Java, 10260, Indonesia",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ----- CHECKOUT DETAILS -----
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...widget.cartItems.map((item) {
                          final imagePath = item.product.images.isNotEmpty
                              ? item.product.images.first
                              : null;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: AppColor.textHint,
                                  ),
                                  child: imagePath != null
                                      ? Image.file(
                                          File(imagePath),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: SizedBox(
                                    height: 80,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item.product.namaProduk,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Rp ${AppFormatters.formatRupiah(item.product.hargaPerHari)}',
                                              style: TextStyle(
                                                color: AppColor.secondary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'x${item.quantity}',
                                              style: TextStyle(
                                                color: AppColor.textHint,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: AppColor.divider),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Lama Peminjaman",
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(
                          child: Text(
                            '$_rentalDays hari',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: AppColor.divider),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total $_totalProducts Produk',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Rp ${AppFormatters.formatRupiah(_subtotal)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ----- PAYMENT METHOD -----
            Container(
              padding: EdgeInsets.all(8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Metode Pembayaran",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final currentMethod = selectedMethod == 'bank'
                              ? selectedBankCode
                              : selectedMethod;

                          final selected = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentMethodScreen(
                                initialSelectedMethod: currentMethod,
                              ),
                            ),
                          );

                          if (selected == null) return;
                          _applyPaymentSelection(selected);
                        },
                        child: Row(
                          children: [
                            Text(
                              "Lihat Semua",
                              style: TextStyle(
                                color: AppColor.textHint,
                                fontSize: 12,
                              ),
                            ),
                            Icon(
                              Symbols.chevron_right,
                              color: AppColor.textHint,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  GestureDetector(
                    onTap: () => setState(() => selectedMethod = "bank"),
                    child: Row(
                      children: [
                        const Icon(Symbols.export_notes),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Transfer Bank",
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              selectedBankLabel,
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Radio<String>(
                          value: "bank",
                          activeColor: AppColor.primary,
                          groupValue: selectedMethod,
                          onChanged: (value) =>
                              setState(() => selectedMethod = value!),
                        ),
                      ],
                    ),
                  ),

                  // GestureDetector(
                  //   onTap: () => setState(() => selectedMethod = "debit"),
                  //   child: Row(
                  //     children: [
                  //       const Icon(Symbols.credit_card),
                  //       const SizedBox(width: 12),
                  //       const Text(
                  //         "Kartu Debit",
                  //         style: TextStyle(fontSize: 12),
                  //       ),
                  //       const Spacer(),
                  //       Radio<String>(
                  //         value: "debit",
                  //         activeColor: AppColor.primary,
                  //         groupValue: selectedMethod,
                  //         onChanged: (value) =>
                  //             setState(() => selectedMethod = value!),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  GestureDetector(
                    onTap: () => setState(() => selectedMethod = "qris"),
                    child: Row(
                      children: [
                        const Icon(Symbols.qr_code_2),
                        const SizedBox(width: 12),
                        const Text("QRIS", style: TextStyle(fontSize: 12)),
                        const Spacer(),
                        Radio<String>(
                          value: "qris",
                          activeColor: AppColor.primary,
                          groupValue: selectedMethod,
                          onChanged: (value) =>
                              setState(() => selectedMethod = value!),
                        ),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: () => setState(() => selectedMethod = 'cod'),
                    child: Row(
                      children: [
                        const Icon(Symbols.quick_reorder),
                        const SizedBox(width: 12),
                        Text('COD', style: TextStyle(fontSize: 12)),
                        const Spacer(),
                        Radio<String>(
                          value: 'cod',
                          activeColor: AppColor.primary,
                          groupValue: selectedMethod,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => selectedMethod = value);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ----- PAYMENT SUMMARY -----
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Rincian Pembayaran",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Subtotal Penyewaan",
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'Rp ${AppFormatters.formatRupiah(_subtotal)}',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Biaya Layanan",
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'Rp ${AppFormatters.formatRupiah(_serviceFee)}',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 8, color: AppColor.divider),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Pembayaran",
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Rp ${AppFormatters.formatRupiah(_totalPayment)}',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColor.surface,
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowLight,
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: kBottomNavigationBarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Rp ${AppFormatters.formatRupiah(_totalPayment)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _processPayment,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColor.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      width: 120,
                      height: double.infinity,
                      alignment: Alignment.center,
                      child: _isPaying
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: AppColor.surface,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Bayar",
                              style: TextStyle(
                                color: AppColor.surface,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

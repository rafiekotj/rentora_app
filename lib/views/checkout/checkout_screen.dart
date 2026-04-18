import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentora_app/config/onesignal_secrets.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/controllers/cart_controller.dart';
import 'package:rentora_app/controllers/store_controller.dart';
import 'package:rentora_app/controllers/user_controller.dart';
import 'package:rentora_app/models/store_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rentora_app/controllers/transaction_controller.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/core/utils/app_formatters.dart';
import 'package:rentora_app/models/cart_model.dart';
import 'package:rentora_app/views/checkout/payment_method_screen.dart';
import 'package:rentora_app/views/checkout/payment_success_screen.dart';
import 'package:rentora_app/services/local_storage/preference_handler.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartModel> cartItems;

  const CheckoutScreen({super.key, required this.cartItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TransactionController _transactionController = TransactionController();
  final CartController _cartController = CartController();

  final StoreController _storeController = StoreController();
  final UserController _userController = UserController();
  StoreModel? _store;
  bool _isLoadingStore = true;

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
      final txnId = await _transactionController.createTransaction(
        cartItems: widget.cartItems,
        paymentMethod: _effectivePaymentMethod,
        paymentLabel: _effectivePaymentLabel,
        serviceFee: _serviceFee,
      );

      for (final item in widget.cartItems) {
        await _cartController.removeFromCart(item.uid);
      }

      // Prepare notification content
      const title = 'Pesanan Sedang Diproses';
      const body = 'Pesanan Anda sedang diproses oleh penjual.';

      // Save notification record locally so it appears on Notification screen.
      // The system notification itself will be sent via OneSignal (remote push).
      await PreferenceHandler().addNotification(
        title: title,
        body: body,
        data: {'transactionId': txnId},
      );

      // Send push to the store owner and buyer via OneSignal REST API.
      // NOTE: This uses a local REST API key (insecure for production).
      try {
        final sellerExternalId = _store?.userUid;
        // Resolve buyer external id (current logged in user)
        final buyerUser = await _userController.getCurrentUser();
        final buyerExternalId = buyerUser?.uid;
        if (sellerExternalId != null && sellerExternalId.isNotEmpty) {
          // Build targets list (seller + buyer if available)
          final targets = <String>[sellerExternalId];
          if (buyerExternalId != null &&
              buyerExternalId.isNotEmpty &&
              buyerExternalId != sellerExternalId) {
            targets.add(buyerExternalId);
          }

          if (kDebugMode) print('OneSignal target external_ids: $targets');

          final uri = Uri.parse('https://onesignal.com/api/v1/notifications');

          Future<http.Response> doPost() {
            return http.post(
              uri,
              headers: {
                'Content-Type': 'application/json; charset=utf-8',
                'Authorization':
                    'Basic ${OneSignalSecrets.onesignalRestApiKey}',
              },
              body: jsonEncode({
                'app_id': OneSignalSecrets.onesignalAppId,
                'include_external_user_ids': targets,
                'headings': {'en': title},
                'contents': {'en': body},
                'data': {'transactionId': txnId},
              }),
            );
          }

          http.Response resp = await doPost();

          // Always log response for debugging
          if (kDebugMode) {
            print('OneSignal REST status: ${resp.statusCode}');
            print('OneSignal REST body: ${resp.body}');
          }

          int recipients = -1;
          String? errorMsg;
          try {
            final Map<String, dynamic> jsonResp = jsonDecode(resp.body);
            if (jsonResp.containsKey('recipients')) {
              recipients = (jsonResp['recipients'] is int)
                  ? jsonResp['recipients'] as int
                  : -1;
            }
            if (jsonResp.containsKey('errors')) {
              final e = jsonResp['errors'];
              if (e is List && e.isNotEmpty)
                errorMsg = e.first.toString();
              else if (e is String)
                errorMsg = e;
            }
          } catch (e) {
            if (kDebugMode) print('Failed parsing OneSignal response: $e');
          }

          // If no recipients or explicit not-subscribed error, retry once after short delay
          if ((recipients == 0) ||
              (errorMsg != null && errorMsg.contains('not subscribed'))) {
            if (kDebugMode)
              print(
                'OneSignal: recipients==0 or not subscribed — retrying once after delay',
              );
            await Future.delayed(const Duration(milliseconds: 900));
            resp = await doPost();
            if (kDebugMode) {
              print('OneSignal REST retry status: ${resp.statusCode}');
              print('OneSignal REST retry body: ${resp.body}');
            }
            try {
              final Map<String, dynamic> jsonResp2 = jsonDecode(resp.body);
              if (jsonResp2.containsKey('recipients')) {
                recipients = (jsonResp2['recipients'] is int)
                    ? jsonResp2['recipients'] as int
                    : recipients;
              }
              if (jsonResp2.containsKey('errors')) {
                final e2 = jsonResp2['errors'];
                if (e2 is List && e2.isNotEmpty)
                  errorMsg = e2.first.toString();
                else if (e2 is String)
                  errorMsg = e2;
              }
            } catch (e) {
              if (kDebugMode)
                print('Failed parsing OneSignal retry response: $e');
            }
          }

          if (recipients == 0 ||
              (errorMsg != null && errorMsg.contains('not subscribed'))) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Push dikirim, tapi tidak ada penerima (recipient=0).',
                  ),
                ),
              );
            }
          }

          if (resp.statusCode != 200 && resp.statusCode != 201) {
            // ignore: avoid_print
            print(
              'OneSignal REST send failed: ${resp.statusCode} ${resp.body}',
            );
          }
        } else {
          if (kDebugMode)
            print('No sellerExternalId available; skipping OneSignal send');
        }
      } catch (e) {
        // ignore: avoid_print
        print('OneSignal send error: $e');
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
  void initState() {
    super.initState();
    _fetchStore();
  }

  Future<void> _fetchStore() async {
    if (widget.cartItems.isEmpty) return;
    final storeUid = widget.cartItems.first.product.storeUid;
    final store = await _storeController.getStoreById(storeUid);
    setState(() {
      _store = store;
      _isLoadingStore = false;
    });
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
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  _isLoadingStore
                      ? SizedBox(
                          height: 162,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : (_store != null &&
                            _store!.latitude != null &&
                            _store!.longitude != null)
                      ? SizedBox(
                          height: 162,
                          child: AbsorbPointer(
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                  _store!.latitude!,
                                  _store!.longitude!,
                                ),
                                zoom: 16,
                              ),
                              markers: {
                                Marker(
                                  markerId: MarkerId('store'),
                                  position: LatLng(
                                    _store!.latitude!,
                                    _store!.longitude!,
                                  ),
                                  infoWindow: InfoWindow(title: _store!.name),
                                ),
                              },
                              onMapCreated: (_) {},
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                              scrollGesturesEnabled: false,
                              zoomGesturesEnabled: false,
                              rotateGesturesEnabled: false,
                              tiltGesturesEnabled: false,
                              mapToolbarEnabled: true,
                            ),
                          ),
                        )
                      : Container(
                          height: 162,
                          decoration: BoxDecoration(color: AppColor.textHint),
                          child: Center(child: Text('Lokasi tidak tersedia')),
                        ),
                  const SizedBox(height: 8),
                  _isLoadingStore
                      ? SizedBox(
                          height: 24,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Symbols.location_pin,
                                  size: 16,
                                  color: AppColor.textHint,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _store?.name ?? '-',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (_store?.fullAddress != null)
                                        Text(
                                          _store!.fullAddress!,
                                          style: TextStyle(fontSize: 12),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (_store != null &&
                                _store!.latitude != null &&
                                _store!.longitude != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColor.primary,
                                      foregroundColor: AppColor.surface,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: const Icon(Icons.directions),
                                    label: const Text('Lihat di Google Maps'),
                                    onPressed: () async {
                                      final lat = _store!.latitude!;
                                      final lng = _store!.longitude!;
                                      final url =
                                          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
                                      final uri = Uri.parse(url);
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(
                                          uri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Tidak dapat membuka Google Maps',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
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
                    padding: const EdgeInsets.only(
                      left: 12,
                      top: 12,
                      right: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...widget.cartItems.map((item) {
                          final imagePath = item.product.images.isNotEmpty
                              ? item.product.images.first.trim()
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
                                      ? (imagePath.startsWith('http')
                                            ? Image.network(
                                                imagePath,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.file(
                                                File(imagePath),
                                                fit: BoxFit.cover,
                                              ))
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

                        const SizedBox(height: 6),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: AppColor.divider),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
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
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        child: Text(
                          "Rincian Pembayaran",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
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
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
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

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/widgets/custom_button.dart';

class PaymentMethodScreen extends StatefulWidget {
  final String initialSelectedMethod;

  const PaymentMethodScreen({super.key, required this.initialSelectedMethod});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  late String selectedMethod;

  @override
  void initState() {
    super.initState();
    // Set metode awal dari parent
    selectedMethod = widget.initialSelectedMethod;
  }

  // Cek apakah ada perubahan metode
  bool get _hasChanged => selectedMethod != widget.initialSelectedMethod;

  // Tampilkan dialog simpan jika ada perubahan
  Future<bool?> _showSaveDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simpan Perubahan?'),
        content: const Text(
          'Anda belum menyimpan perubahan metode pembayaran. Apakah ingin menyimpan sebelum keluar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text(
              'Batal Simpan',
              style: TextStyle(color: AppColor.error),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Simpan',
              style: TextStyle(color: AppColor.primary),
            ),
          ),
        ],
      ),
    );
  }

  // Handler saat user ingin keluar
  Future<bool> _onWillPop() async {
    if (!_hasChanged) return true;
    await _showSaveDialog();
    return false;
  }

  // Pilih metode dan update state
  void _selectAndClose(String method) {
    setState(() {
      selectedMethod = method;
    });
  }

  // Konfirmasi pilihan dan tutup layar
  void _confirmSelection() {
    Navigator.pop(context, selectedMethod);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onWillPop();
      },
      child: Scaffold(
        backgroundColor: AppColor.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppColor.primary,
          foregroundColor: AppColor.surface,
          title: const Text(
            "Pilih Metode Pembayaran",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: BackButton(
            onPressed: () async {
              final canPop = await _onWillPop();
              if (canPop) Navigator.of(context).maybePop();
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColor.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                    childrenPadding: const EdgeInsets.only(bottom: 8),
                    shape: const Border(),
                    collapsedShape: const Border(),
                    iconColor: AppColor.textHint,
                    collapsedIconColor: AppColor.textHint,
                    title: const Text(
                      'Transfer Bank',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    children: [
                      GestureDetector(
                        onTap: () => _selectAndClose('bca'),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Row(
                            children: [
                              const Icon(Symbols.account_balance),
                              const SizedBox(width: 12),
                              Text('BCA', style: TextStyle(fontSize: 12)),
                              const Spacer(),
                              Radio<String>(
                                value: 'bca',
                                activeColor: AppColor.primary,
                                groupValue: selectedMethod,
                                onChanged: (value) {
                                  if (value == null) return;
                                  _selectAndClose(value);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () => _selectAndClose('mandiri'),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Row(
                            children: [
                              const Icon(Symbols.account_balance),
                              const SizedBox(width: 12),
                              Text('Mandiri', style: TextStyle(fontSize: 12)),
                              const Spacer(),
                              Radio<String>(
                                value: 'mandiri',
                                activeColor: AppColor.primary,
                                groupValue: selectedMethod,
                                onChanged: (value) {
                                  if (value == null) return;
                                  _selectAndClose(value);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () => _selectAndClose('bni'),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Row(
                            children: [
                              const Icon(Symbols.account_balance),
                              const SizedBox(width: 12),
                              Text('BNI', style: TextStyle(fontSize: 12)),
                              const Spacer(),
                              Radio<String>(
                                value: 'bni',
                                activeColor: AppColor.primary,
                                groupValue: selectedMethod,
                                onChanged: (value) {
                                  if (value == null) return;
                                  _selectAndClose(value);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () => _selectAndClose('bri'),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Row(
                            children: [
                              const Icon(Symbols.account_balance),
                              const SizedBox(width: 12),
                              Text('BRI', style: TextStyle(fontSize: 12)),
                              const Spacer(),
                              Radio<String>(
                                value: 'bri',
                                activeColor: AppColor.primary,
                                groupValue: selectedMethod,
                                onChanged: (value) {
                                  if (value == null) return;
                                  _selectAndClose(value);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                Container(
                  decoration: BoxDecoration(
                    color: AppColor.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GestureDetector(
                    onTap: () => _selectAndClose('qris'),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Row(
                        children: [
                          const Icon(Symbols.qr_code_2),
                          const SizedBox(width: 12),
                          Text('QRIS', style: TextStyle(fontSize: 12)),
                          const Spacer(),
                          Radio<String>(
                            value: 'qris',
                            activeColor: AppColor.primary,
                            groupValue: selectedMethod,
                            onChanged: (value) {
                              if (value == null) return;
                              _selectAndClose(value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                Container(
                  decoration: BoxDecoration(
                    color: AppColor.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GestureDetector(
                    onTap: () => _selectAndClose('cod'),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
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
                              _selectAndClose(value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          color: AppColor.surface,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: SafeArea(
            top: false,
            child: CustomButton(
              text: 'Konfirmasi',
              onPressed: _confirmSelection,
              backgroundColor: AppColor.primary,
              textColor: AppColor.surface,
            ),
          ),
        ),
      ),
    );
  }
}

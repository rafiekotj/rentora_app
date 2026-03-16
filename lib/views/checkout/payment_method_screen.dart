import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/core/constants/app_color.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String selectedMethod = 'bca';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.surface,
        title: Text(
          "Pilih Metode Pembayaran",
          style: TextStyle(fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => selectedMethod = 'bca'),
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
                                setState(() => selectedMethod = value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () => setState(() => selectedMethod = 'mandiri'),
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
                                setState(() => selectedMethod = value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () => setState(() => selectedMethod = 'bni'),
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
                                setState(() => selectedMethod = value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () => setState(() => selectedMethod = 'bri'),
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
                                setState(() => selectedMethod = value);
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
                  onTap: () => setState(() => selectedMethod = 'qris'),
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
                            setState(() => selectedMethod = value);
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
                  onTap: () => setState(() => selectedMethod = 'cod'),
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
                            setState(() => selectedMethod = value);
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
    );
  }
}

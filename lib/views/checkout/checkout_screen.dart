import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/core/constants/app_color.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedMethod = "bank";

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
                        Row(
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                color: AppColor.textHint,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 80,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Kamera Canon",
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
                                          "Rp60.000",
                                          style: TextStyle(
                                            color: AppColor.secondary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "x2",
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

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                color: AppColor.textHint,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 80,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Kamera Sony",
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
                                          "Rp60.000",
                                          style: TextStyle(
                                            color: AppColor.secondary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "x2",
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
                          child: const Text(
                            "3 hari",
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
                        Text("Total 4 Produk", style: TextStyle(fontSize: 12)),
                        Text(
                          "Rp440.000",
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
                        onTap: () {},
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
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Transfer Bank",
                              style: TextStyle(fontSize: 12),
                            ),
                            Text("BCA", style: TextStyle(fontSize: 10)),
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
                    onTap: () => setState(() => selectedMethod = "debit"),
                    child: Row(
                      children: [
                        const Icon(Symbols.credit_card),
                        const SizedBox(width: 12),
                        const Text(
                          "Kartu Debit",
                          style: TextStyle(fontSize: 12),
                        ),
                        const Spacer(),
                        Radio<String>(
                          value: "debit",
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
                        const Icon(Symbols.qr_code),
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
                                  "Rp440.000",
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
                                Text("Rp1.000", style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 8),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Pembayaran",
                          style: TextStyle(fontSize: 12),
                        ),
                        Text("Rp441.000", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // ----- CHECKOUT BUTTON -----
      bottomNavigationBar: Container(),
    );
  }
}

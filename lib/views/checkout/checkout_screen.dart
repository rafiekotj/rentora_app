import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/core/constants/app_color.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
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
                                  style: TextStyle(fontWeight: FontWeight.w700),
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
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(
                          child: const Text(
                            "3 hari",
                            style: TextStyle(fontSize: 14),
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
                        Text("Total 4 Produk", style: TextStyle(fontSize: 14)),
                        Text(
                          "Rp440.000",
                          style: TextStyle(
                            fontSize: 14,
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
                      Text("Metode Pembayaran"),
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
                ],
              ),
            ),

            // ----- PAYMENT SUMMARY -----

            // ----- CHECKOUT BUTTON -----
          ],
        ),
      ),
    );
  }
}

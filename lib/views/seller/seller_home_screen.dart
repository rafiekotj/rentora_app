import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/views/seller/seller_product_screen.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: AppBar(
        toolbarHeight: 58,
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.textOnPrimary,
        title: Text("Toko Saya", style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Symbols.chat, weight: 600),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Symbols.notifications, weight: 600),
          ),

          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(color: AppColor.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 30),
                      ),

                      const SizedBox(width: 16),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "rafie@gmail.com",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColor.textOnPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                "0",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Perlu Dikirim",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColor.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                "0",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Pembatalan",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColor.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                "0",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Pengembalian",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColor.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                "0",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Penilaian Perlu\nDibalas",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColor.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 8),

                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Menu Seller",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SellerProductScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColor.border),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Symbols.inventory_2,
                                      size: 24,
                                      weight: 600,
                                      color: Color(0xFF5C6BC0),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Produk",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Symbols.chevron_right,
                                      size: 20,
                                      weight: 600,
                                      color: AppColor.textHint,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColor.border),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Symbols.receipt_long,
                                      size: 24,
                                      weight: 600,
                                      color: Color(0xFFFFA000),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Pesanan",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Symbols.chevron_right,
                                      size: 20,
                                      weight: 600,
                                      color: AppColor.textHint,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColor.border),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Symbols.account_balance_wallet,
                                      size: 24,
                                      weight: 600,
                                      color: Color(0xFF00A86B),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Keuangan",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Symbols.chevron_right,
                                      size: 20,
                                      weight: 600,
                                      color: AppColor.textHint,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColor.border),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Symbols.insights,
                                      size: 24,
                                      weight: 600,
                                      color: Color(0xFF3949AB),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Performa",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Symbols.chevron_right,
                                      size: 20,
                                      weight: 600,
                                      color: AppColor.textHint,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColor.border),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Symbols.percent_discount,
                                      size: 24,
                                      weight: 600,
                                      color: Color(0xFFFF6F61),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Promosi Toko",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Symbols.chevron_right,
                                      size: 20,
                                      weight: 600,
                                      color: AppColor.textHint,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColor.border),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Symbols.help,
                                      size: 24,
                                      weight: 600,
                                      color: Color(0xFF0097A7),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Pusat Bantuan",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Symbols.chevron_right,
                                      size: 20,
                                      weight: 600,
                                      color: AppColor.textHint,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}

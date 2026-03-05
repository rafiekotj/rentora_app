import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/views/seller/seller_home_screen.dart';
import 'package:rentora_app/views/settings/settings_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: AppBar(
        toolbarHeight: 58,
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.textOnPrimary,
        title: Text("Account", style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            icon: const Icon(Symbols.settings, weight: 600),
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
                          SizedBox(height: 8),
                          Text(
                            "12 Pengikut • 72 Mengikuti",
                            style: TextStyle(
                              fontSize: 12,
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
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Pesanan Saya",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Row(
                                children: [
                                  Text(
                                    "Riwayat Pesanan",
                                    style: TextStyle(
                                      color: AppColor.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Icon(
                                    Symbols.chevron_right,
                                    size: 16,
                                    weight: 600,
                                    color: AppColor.textHint,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {},
                                child: Column(
                                  children: const [
                                    Icon(
                                      Symbols.receipt_long,
                                      size: 28,
                                      weight: 600,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      "Belum Bayar",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Expanded(
                              child: GestureDetector(
                                onTap: () {},
                                child: Column(
                                  children: const [
                                    Icon(
                                      Symbols.inventory_2,
                                      size: 28,
                                      weight: 600,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      "Diambil",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Expanded(
                              child: GestureDetector(
                                onTap: () {},
                                child: Column(
                                  children: const [
                                    Icon(
                                      Symbols.assignment_return,
                                      size: 28,
                                      weight: 600,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      "Pengembalian",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Expanded(
                              child: GestureDetector(
                                onTap: () {},
                                child: Column(
                                  children: const [
                                    Icon(Symbols.star, size: 28, weight: 600),
                                    SizedBox(height: 6),
                                    Text(
                                      "Ulasan",
                                      style: TextStyle(fontSize: 12),
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

                  const SizedBox(height: 8),

                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Aktivitas",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Column(
                          children: [
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
                                      Symbols.favorite,
                                      size: 24,
                                      weight: 600,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Favorit Saya",
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
                                      Symbols.history,
                                      size: 24,
                                      weight: 600,
                                      color: Colors.orange,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Terakhir Dilihat",
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
                                      Symbols.shopping_bag,
                                      size: 24,
                                      weight: 600,
                                      color: Colors.teal,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Beli Lagi",
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
                                      Symbols.workspace_premium,
                                      size: 24,
                                      weight: 600,
                                      color: Colors.indigo,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Member Rentora",
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

                  const SizedBox(height: 8),

                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Seller",
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
                                        const SellerHomeScreen(),
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
                                      Symbols.storefront,
                                      size: 24,
                                      weight: 600,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Toko Saya",
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

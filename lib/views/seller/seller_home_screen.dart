import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/views/seller/seller_product_screen.dart';
import 'package:rentora_app/views/settings/settings_screen.dart';

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
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              height: 104,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                gradient: LinearGradient(
                  colors: [Color(0xff3B82F6), Color(0xff1E40AF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Symbols.person,
                      size: 32,
                      color: AppColor.primary,
                    ),
                  ),

                  SizedBox(width: 24),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "rafie@gmail.com",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColor.textOnPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Symbols.inventory_2,
                        color: AppColor.primary,
                      ),
                      title: const Text(
                        "Produk",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(
                        Symbols.chevron_right,
                        color: AppColor.textHint,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SellerProductScreen(),
                          ),
                        );
                      },
                    ),

                    const Divider(
                      height: 1,
                      color: AppColor.divider,
                      indent: 16,
                      endIndent: 16,
                    ),

                    ListTile(
                      leading: const Icon(
                        Symbols.receipt_long,
                        color: AppColor.primary,
                      ),
                      title: const Text(
                        "Pesanan",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(
                        Symbols.chevron_right,
                        color: AppColor.textHint,
                      ),
                      onTap: () {},
                    ),

                    const Divider(
                      height: 1,
                      color: AppColor.divider,
                      indent: 16,
                      endIndent: 16,
                    ),

                    ListTile(
                      leading: const Icon(
                        Symbols.account_balance_wallet,
                        color: AppColor.primary,
                      ),
                      title: const Text(
                        "Keuangan",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(
                        Symbols.chevron_right,
                        color: AppColor.textHint,
                      ),
                      onTap: () {},
                    ),

                    const Divider(
                      height: 1,
                      color: AppColor.divider,
                      indent: 16,
                      endIndent: 16,
                    ),

                    ListTile(
                      leading: const Icon(
                        Symbols.insights,
                        color: AppColor.primary,
                      ),
                      title: const Text(
                        "Performa",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(
                        Symbols.chevron_right,
                        color: AppColor.textHint,
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

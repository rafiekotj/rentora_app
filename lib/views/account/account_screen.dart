import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/services/local_storage/preference_handler.dart';
import 'package:rentora_app/views/seller/seller_home_screen.dart';
import 'package:rentora_app/views/settings/settings_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final email = await PreferenceHandler.getUserEmail();
    setState(() {
      _email = email ?? 'user@example.com';
    });
  }

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
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
            icon: Icon(Symbols.settings, weight: 600),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // PROFIL AKUN
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(color: AppColor.primary),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 30),
                  ),

                  SizedBox(width: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _email,
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
            ),

            // PEMINJAMAN SAYA SECTION
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  SectionCard(
                    title: "Peminjaman Saya",
                    child: Column(
                      children: [
                        Row(
                          children: [
                            OrderStatusItem(
                              icon: Symbols.receipt_long,
                              label: "Belum Bayar",
                              onTap: () {},
                            ),

                            OrderStatusItem(
                              icon: Symbols.inventory_2,
                              label: "Diambil",
                              onTap: () {},
                            ),

                            OrderStatusItem(
                              icon: Symbols.assignment_return,
                              label: "Pengembalian",
                              onTap: () {},
                            ),

                            OrderStatusItem(
                              icon: Symbols.star,
                              label: "Ulasan",
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // AKTIVITAS SECTION
                  SectionCard(
                    title: "Aktivitas",
                    child: Column(
                      children: [
                        MenuItemCard(
                          icon: Symbols.receipt_long,
                          text: "Riwayat Pesanan",
                          iconColor: Colors.blue,
                          onTap: () {},
                        ),

                        SizedBox(height: 8),

                        MenuItemCard(
                          icon: Symbols.favorite,
                          text: "Favorit Saya",
                          iconColor: Colors.red,
                          onTap: () {},
                        ),

                        SizedBox(height: 8),

                        MenuItemCard(
                          icon: Symbols.history,
                          text: "Terakhir Dilihat",
                          iconColor: Colors.orange,
                          onTap: () {},
                        ),

                        SizedBox(height: 8),

                        MenuItemCard(
                          icon: Symbols.shopping_bag,
                          text: "Beli Lagi",
                          iconColor: Colors.teal,
                          onTap: () {},
                        ),

                        SizedBox(height: 8),

                        MenuItemCard(
                          icon: Symbols.workspace_premium,
                          text: "Member Rentora",
                          iconColor: Colors.indigo,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  // SELLER SECTION
                  SectionCard(
                    title: "Seller",
                    child: Column(
                      children: [
                        MenuItemCard(
                          icon: Symbols.storefront,
                          text: "Toko Saya",
                          iconColor: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SellerHomeScreen(),
                              ),
                            );
                          },
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

class OrderStatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const OrderStatusItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, size: 28, weight: 600),
            SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const SectionCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class MenuItemCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final VoidCallback onTap;

  const MenuItemCard({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor = Colors.black,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.border),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: iconColor),
            SizedBox(width: 12),
            Expanded(
              child: Text(text, style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            Icon(Symbols.chevron_right, size: 20, color: AppColor.textHint),
          ],
        ),
      ),
    );
  }
}

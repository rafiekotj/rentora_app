import 'dart:io';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/controllers/store_controller.dart';
import 'package:rentora_app/controllers/user_controller.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/models/store_model.dart';
import 'package:rentora_app/models/user_model.dart';
import 'package:rentora_app/views/seller/seller_product_screen.dart';
import 'package:rentora_app/views/seller/seller_settings_screen.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  final StoreController _storeController = StoreController();
  final UserController _userController = UserController();

  StoreModel? _store;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Memuat data pengguna dan toko
  Future<void> _loadData() async {
    final user = await _userController.getCurrentUser();

    if (user != null) {
      final store = await _storeController.getStoreByUserId(user.id!);

      if (!mounted) return;

      setState(() {
        _user = user;
        _store = store;
      });

      _checkStoreProfile();
    }
  }

  // Memeriksa apakah profil toko sudah lengkap
  Future<void> _checkStoreProfile() async {
    final store = _store;

    if (store == null ||
        store.name.isEmpty ||
        store.location == null ||
        store.location!.isEmpty ||
        store.image == null ||
        store.image!.isEmpty) {
      _showProfileSetupAlert();
    }
  }

  // Menampilkan dialog untuk mengingatkan penjual melengkapi profil tokonya.
  void _showProfileSetupAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColor.backgroundLight,
          title: const Text('Lengkapi Profil Toko'),
          content: const Text(
            'Anda perlu melengkapi nama, lokasi, dan gambar profil toko Anda untuk dapat menambahkan produk.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Nanti'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Ke Pengaturan'),
              onPressed: () async {
                Navigator.of(context).pop();
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SellerSettingsScreen(),
                  ),
                );

                _loadData();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: AppBar(
        toolbarHeight: 58,
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.textOnPrimary,
        title: const Text(
          "Toko Saya",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- HEADER PROFIL TOKO ---
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: const BoxDecoration(color: AppColor.primary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if ((_store?.image ?? '').isNotEmpty)
                          ClipOval(
                            child: Image.file(
                              File(_store!.image!),
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          const CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColor.surface,
                            child: Icon(Icons.person, size: 30),
                          ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _store?.name ?? _user?.email ?? "",
                              style: const TextStyle(
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
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    // --- SECTION STATISTIK TOKO ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColor.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StatItem(count: 0, label: "Perlu Dikirim"),
                          StatItem(count: 0, label: "Pembatalan"),
                          StatItem(count: 0, label: "Pengembalian"),
                          StatItem(count: 0, label: "Penilaian Perlu\nDibalas"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // --- SECTION MENU TOKO ---
                    SectionCard(
                      title: "Menu Seller",
                      child: Column(
                        children: [
                          MenuItemCard(
                            icon: Symbols.inventory_2,
                            text: "Produk",
                            iconColor: Colors.blueAccent,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SellerProductScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          MenuItemCard(
                            icon: Symbols.receipt_long,
                            text: "Pesanan",
                            iconColor: Colors.orangeAccent,
                            onTap: () {},
                          ),
                          const SizedBox(height: 8),
                          MenuItemCard(
                            icon: Symbols.account_balance_wallet,
                            text: "Keuangan",
                            iconColor: Colors.green,
                            onTap: () {},
                          ),
                          const SizedBox(height: 8),
                          MenuItemCard(
                            icon: Symbols.insights,
                            text: "Performa",
                            iconColor: Colors.indigo,
                            onTap: () {},
                          ),
                          const SizedBox(height: 8),
                          MenuItemCard(
                            icon: Symbols.percent_discount,
                            text: "Promosi Toko",
                            iconColor: Colors.redAccent,
                            onTap: () {},
                          ),
                          const SizedBox(height: 8),
                          MenuItemCard(
                            icon: Symbols.settings,
                            text: "Pengaturan Toko",
                            iconColor: Colors.blueGrey,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SellerSettingsScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          MenuItemCard(
                            icon: Symbols.help,
                            text: "Pusat Bantuan",
                            iconColor: Colors.teal,
                            onTap: () {},
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
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final int count;
  final String label;

  const StatItem({super.key, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: AppColor.textSecondary),
          ),
        ],
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
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
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
    this.iconColor = AppColor.textPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.border),
          borderRadius: BorderRadius.circular(8),
          color: AppColor.surface,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(
              Symbols.chevron_right,
              size: 20,
              color: AppColor.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

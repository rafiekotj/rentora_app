import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/controllers/user_controller.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/views/seller/seller_home_screen.dart';
import 'package:rentora_app/views/settings/settings_screen.dart';
import 'package:rentora_app/views/transaction_history/transaction_history_screen.dart';

class UserAccountScreen extends StatefulWidget {
  const UserAccountScreen({super.key});

  @override
  State<UserAccountScreen> createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen> {
  final UserController _userController = UserController();
  String _email = '';
  String? _username;
  String? _imagePath;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Mengambil data user lengkap
  Future<void> _loadUserData() async {
    setState(() {
      _isLoadingUser = true;
    });
    final user = await _userController.getCurrentUser();

    if (!mounted) return;

    setState(() {
      if (user != null) {
        _email = user.email;
        _username = user.username;
        _imagePath = user.image;
      } else {
        _email = 'user@example.com';
        _username = null;
        _imagePath = null;
      }
      _isLoadingUser = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayName = (_username ?? '').isNotEmpty ? _username! : _email;

    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: AppBar(
        toolbarHeight: 58,
        elevation: 0,
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.textOnPrimary,
        title: const Text(
          "Akun",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              if (mounted) {
                _loadUserData();
              }
            },
            icon: const Icon(Symbols.settings, weight: 600),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 190,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 68,
                    width: double.infinity,
                    decoration: const BoxDecoration(color: AppColor.primary),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColor.border),
                        color: AppColor.surface,
                        boxShadow: const [
                          BoxShadow(
                            color: AppColor.shadowLight,
                            blurRadius: 14,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColor.primarySoft,
                                backgroundImage: (_imagePath ?? '').isNotEmpty
                                    ? NetworkImage(_imagePath!)
                                          as ImageProvider<Object>?
                                    : null,
                                child:
                                    (_imagePath == null || _imagePath!.isEmpty)
                                    ? const Icon(
                                        Symbols.person,
                                        size: 28,
                                        color: AppColor.primary,
                                        weight: 600,
                                        fill: 1,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_isLoadingUser) ...[
                                      Container(
                                        height: 18,
                                        width: 140,
                                        decoration: BoxDecoration(
                                          color: AppColor.textHint.withOpacity(
                                            0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 12,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: AppColor.textHint.withOpacity(
                                            0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                    ] else ...[
                                      Text(
                                        displayName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColor.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        _email,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColor.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Divider(color: AppColor.divider, height: 1),
                          const SizedBox(height: 12),
                          const Row(
                            children: [
                              _ProfileStatItem(label: 'Transaksi', value: '40'),
                              _ProfileStatItem(label: 'Pengikut', value: '10'),
                              _ProfileStatItem(label: 'Mengikuti', value: '10'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  SectionCard(
                    title: "Peminjaman Saya",
                    actionLabel: "Lihat Semua",
                    onActionTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const TransactionHistoryScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        OrderStatusItem(
                          icon: Symbols.receipt_long,
                          label: "Belum Bayar",
                          badge: '0',
                          onTap: () {},
                        ),
                        OrderStatusItem(
                          icon: Symbols.inventory_2,
                          label: "Diambil",
                          badge: '0',
                          onTap: () {},
                        ),
                        OrderStatusItem(
                          icon: Symbols.assignment_return,
                          label: "Pengembalian",
                          badge: '0',
                          onTap: () {},
                        ),
                        OrderStatusItem(
                          icon: Symbols.star,
                          label: "Ulasan",
                          badge: '0',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  SectionCard(
                    title: "Aktivitas",
                    subtitle: "Semua jejak belanja dan sewa ada di sini",
                    child: Column(
                      children: [
                        MenuItemCard(
                          icon: Symbols.favorite,
                          text: "Favorit Saya",
                          subtitle: "Simpan dulu, checkout kapan pun kamu siap",
                          fill: 1,
                          iconColor: Colors.red,
                          onTap: () {},
                        ),
                        const SizedBox(height: 8),
                        MenuItemCard(
                          icon: Symbols.workspace_premium,
                          text: "Member Rentora",
                          subtitle: "Unlock promo spesial dan benefit member",
                          iconColor: Colors.indigo,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  SectionCard(
                    title: "Seller",
                    subtitle: "Pantau performa toko langsung dari dashboard",
                    child: Column(
                      children: [
                        MenuItemCard(
                          icon: Symbols.storefront,
                          text: "Toko Saya",
                          subtitle: "Atur produk, pesanan, dan insight toko",
                          // badge: 'Pro',
                          iconColor: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SellerHomeScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  SectionCard(
                    title: "Bantuan & Akun",
                    subtitle: "Butuh bantuan? Semua solusi ada di sini",
                    child: Column(
                      children: [
                        MenuItemCard(
                          icon: Symbols.support_agent,
                          text: "Pusat Bantuan",
                          subtitle: "FAQ, komplain, dan respon cepat 24/7",
                          iconColor: AppColor.info,
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
    );
  }
}

class OrderStatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;

  const OrderStatusItem({
    super.key,
    required this.icon,
    required this.label,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColor.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    weight: 650,
                    color: AppColor.primary,
                  ),
                ),
                if (badge != null && badge != '0')
                  Positioned(
                    right: -4,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.error,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColor.surface, width: 1),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColor.textOnPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final Widget child;

  const SectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.border),
        boxShadow: const [
          BoxShadow(
            color: AppColor.shadowLight,
            blurRadius: 14,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColor.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (actionLabel != null)
                InkWell(
                  onTap: onActionTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 2,
                    ),
                    child: Row(
                      children: [
                        Text(
                          actionLabel!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Symbols.chevron_right,
                          size: 18,
                          color: AppColor.textHint,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
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
  final String? subtitle;
  final String? badge;
  final Color iconColor;
  final double? fill;
  final VoidCallback onTap;

  const MenuItemCard({
    super.key,
    required this.icon,
    required this.text,
    this.subtitle,
    this.badge,
    this.iconColor = AppColor.textPrimary,
    this.fill,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.border),
          borderRadius: BorderRadius.circular(14),
          color: AppColor.surface,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(28),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: iconColor, fill: fill),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (badge != null && badge != '0')
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.primarySoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColor.secondary,
                  ),
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

class _ProfileStatItem extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColor.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColor.textSecondary),
          ),
        ],
      ),
    );
  }
}

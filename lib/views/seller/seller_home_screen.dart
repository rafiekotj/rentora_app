import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/controllers/store_controller.dart';
import 'package:rentora_app/controllers/transaction_controller.dart';
import 'package:rentora_app/controllers/user_controller.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/models/store_model.dart';
import 'package:rentora_app/models/user_model.dart';
import 'package:rentora_app/views/seller/seller_order_screen.dart';
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
  final TransactionController _transactionController = TransactionController();

  StoreModel? _store;
  UserModel? _user;
  int _pendingShipmentCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Memuat data pengguna dan toko
  Future<void> _loadData() async {
    final user = await _userController.getCurrentUser();

    if (user != null) {
      final store = await _storeController.getStoreByUserId(user.uid);

      if (!mounted) return;

      setState(() {
        _user = user;
        _store = store;
      });

      await _loadSellerStats();
      _checkStoreProfile();
    }
  }

  Future<void> _loadSellerStats() async {
    final pendingCount = await _transactionController
        .getPendingShipmentCountForCurrentSeller();

    if (!mounted) return;
    setState(() {
      _pendingShipmentCount = pendingCount;
    });
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

  // Menampilkan dialog untuk mengingatkan penjual melengkapi profil tokonya
  void _showProfileSetupAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
          },
          child: Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(18),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColor.warningSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Symbols.store,
                      size: 28,
                      color: AppColor.warning,
                      weight: 700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Lengkapi Profil Toko',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Anda perlu melengkapi nama, lokasi, dan gambar profil toko Anda untuk dapat menambahkan produk.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColor.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: const BorderSide(
                              color: AppColor.border,
                              width: 1,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColor.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SellerSettingsScreen(),
                              ),
                            );

                            if (mounted) {
                              _loadData();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            foregroundColor: AppColor.textOnPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Ke Pengaturan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String displayName = (_store?.name ?? '').isNotEmpty
        ? _store!.name
        : _user?.email ?? 'Toko Saya';
    final String storeLocation = (_store?.district ?? '').isNotEmpty
        ? _store!.district!
        : 'Lokasi belum diatur';

    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: AppBar(
        toolbarHeight: 58,
        elevation: 0,
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.textOnPrimary,
        title: const Text(
          "Toko Saya",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Symbols.chat, weight: 650),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Symbols.notifications, weight: 650),
              ),
              if (_pendingShipmentCount > 0)
                Positioned(
                  top: 8,
                  right: 7,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColor.error,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColor.primary, width: 1),
                    ),
                    child: Text(
                      _pendingShipmentCount > 99
                          ? '99+'
                          : _pendingShipmentCount.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColor.textOnPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 213,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 78,
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 34,
                                  backgroundColor: AppColor.primarySoft,
                                  backgroundImage:
                                      (_store?.image ?? '').isNotEmpty
                                      ? NetworkImage(_store!.image!)
                                            as ImageProvider
                                      : null,
                                  child: (_store?.image ?? '').isEmpty
                                      ? const Icon(
                                          Symbols.storefront,
                                          size: 30,
                                          color: AppColor.secondary,
                                          weight: 650,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
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
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColor.infoSoft,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Symbols.location_on,
                                              size: 13,
                                              color: AppColor.info,
                                              weight: 700,
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                storeLocation,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColor.info,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const Divider(color: AppColor.divider, height: 1),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                StatItem(
                                  icon: Symbols.local_shipping,
                                  count: _pendingShipmentCount,
                                  label: "Perlu Dikirim",
                                  iconColor: AppColor.warning,
                                  isUrgent: _pendingShipmentCount > 0,
                                ),
                                const _StatDivider(),
                                const StatItem(
                                  icon: Symbols.cancel,
                                  count: 0,
                                  label: "Pembatalan",
                                  iconColor: AppColor.error,
                                ),
                                const _StatDivider(),
                                const StatItem(
                                  icon: Symbols.assignment_return,
                                  count: 0,
                                  label: "Pengembalian",
                                  iconColor: AppColor.info,
                                ),
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
                      title: "Ringkasan Operasional",
                      subtitle: "Status pesanan dan performa toko hari ini",
                      child: Row(
                        children: [
                          SellerStatusTile(
                            icon: Symbols.package_2,
                            title: "Pesanan Masuk",
                            value: _pendingShipmentCount,
                            valueColor: _pendingShipmentCount > 0
                                ? AppColor.warning
                                : AppColor.textPrimary,
                          ),
                          const SizedBox(width: 8),
                          const SellerStatusTile(
                            icon: Symbols.percent_discount,
                            title: "Promo Aktif",
                            value: 0,
                            valueColor: AppColor.textPrimary,
                          ),
                          const SizedBox(width: 8),
                          const SellerStatusTile(
                            icon: Symbols.chat,
                            title: "Ulasan Baru",
                            value: 0,
                            valueColor: AppColor.textPrimary,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    SectionCard(
                      title: "Menu Seller",
                      subtitle: "Kelola produk, transaksi, dan pengaturan toko",
                      child: Column(
                        children: [
                          MenuItemCard(
                            icon: Symbols.inventory_2,
                            text: "Produk",
                            subtitle:
                                "Tambah, edit, dan atur stok katalog sewa",
                            iconColor: AppColor.primary,
                            isHighlighted: true,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SellerProductScreen(),
                                ),
                              );
                              if (mounted) {
                                _loadData();
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          MenuItemCard(
                            icon: Symbols.receipt_long,
                            text: "Pesanan",
                            subtitle:
                                "Pantau order baru, proses kirim, dan status",
                            badge: _pendingShipmentCount > 0
                                ? _pendingShipmentCount > 99
                                      ? '99+'
                                      : _pendingShipmentCount.toString()
                                : null,
                            iconColor: AppColor.warning,
                            isHighlighted: _pendingShipmentCount > 0,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SellerOrderScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          MenuItemCard(
                            icon: Symbols.account_balance_wallet,
                            text: "Keuangan",
                            subtitle:
                                "Lihat saldo masuk, histori pencairan, dan ringkasan",
                            iconColor: AppColor.success,
                            onTap: () {},
                          ),
                          const SizedBox(height: 8),
                          MenuItemCard(
                            icon: Symbols.insights,
                            text: "Performa",
                            subtitle:
                                "Analisis penjualan, traffic, dan produk unggulan",
                            iconColor: AppColor.info,
                            onTap: () {},
                          ),
                          const SizedBox(height: 8),
                          MenuItemCard(
                            icon: Symbols.settings,
                            text: "Pengaturan Toko",
                            subtitle:
                                "Lengkapi profil toko, alamat, dan informasi operasional",
                            iconColor: AppColor.secondary,
                            isHighlighted: false,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SellerSettingsScreen(),
                                ),
                              );
                              if (mounted) {
                                _loadData();
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          MenuItemCard(
                            icon: Symbols.help,
                            text: "Pusat Bantuan",
                            subtitle:
                                "Temukan FAQ dan bantuan cepat untuk seller",
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
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color iconColor;
  final bool isUrgent;

  const StatItem({
    super.key,
    required this.icon,
    required this.count,
    required this.label,
    required this.iconColor,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor, weight: 650),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isUrgent ? AppColor.warning : AppColor.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColor.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 42, color: AppColor.divider);
  }
}

class SellerStatusTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final int value;
  final Color valueColor;

  const SellerStatusTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColor.backgroundLight,
          border: Border.all(color: AppColor.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColor.primary, weight: 700),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 18,
                color: valueColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppColor.textSecondary,
                fontWeight: FontWeight.w500,
              ),
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
  final Widget child;

  const SectionCard({
    super.key,
    required this.title,
    this.subtitle,
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
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
  final bool isHighlighted;
  final VoidCallback onTap;

  const MenuItemCard({
    super.key,
    required this.icon,
    required this.text,
    this.subtitle,
    this.badge,
    this.iconColor = AppColor.textPrimary,
    this.isHighlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: AppColor.primary.withAlpha(22),
        highlightColor: AppColor.primary.withAlpha(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: isHighlighted ? AppColor.primarySoft : AppColor.border,
            ),
            borderRadius: BorderRadius.circular(14),
            color: isHighlighted ? AppColor.primarySoft.withAlpha(70) : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: iconColor),
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
              if (badge != null)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.errorSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColor.error,
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
      ),
    );
  }
}

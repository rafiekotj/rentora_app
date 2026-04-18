import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/controllers/cart_controller.dart';
import 'package:rentora_app/controllers/store_controller.dart';
import 'package:rentora_app/controllers/user_controller.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/core/utils/app_formatters.dart';
import 'package:rentora_app/models/cart_model.dart';
import 'package:rentora_app/models/product_model.dart';
import 'package:rentora_app/models/store_model.dart';
import 'package:rentora_app/views/cart/cart_screen.dart';

class DetailProductScreen extends StatefulWidget {
  final ProductModel produk;
  final String storeUid;

  const DetailProductScreen({
    super.key,
    required this.produk,
    required this.storeUid,
  });

  @override
  State<DetailProductScreen> createState() => _DetailProductScreenState();
}

class _DetailProductScreenState extends State<DetailProductScreen> {
  late PageController _pageController;
  int _currentImageIndex = 0;

  final StoreController _storeController = StoreController();
  final CartController _cartController = CartController();
  final UserController _userController = UserController();

  StoreModel? _store;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadStore();
  }

  void _loadStore() async {
    try {
      final store = await _storeController.getStoreById(widget.produk.storeUid);
      setState(() {
        _store = store;
      });
    } catch (_) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _store == null
        ? const Center(
            child: CircularProgressIndicator(color: AppColor.primary),
          )
        : Scaffold(
            backgroundColor: AppColor.backgroundLight,
            appBar: AppBar(
              toolbarHeight: 58,
              backgroundColor: AppColor.primary,
              foregroundColor: AppColor.textOnPrimary,
              titleSpacing: 0,
              title: Container(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColor.textOnPrimary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          cursorColor: AppColor.textSecondary,
                          textAlignVertical: TextAlignVertical.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColor.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: "Search",
                            hintStyle: TextStyle(
                              color: AppColor.textSecondary,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            prefixIcon: Icon(
                              Symbols.search,
                              weight: 600,
                              color: AppColor.textSecondary,
                              size: 20,
                            ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 42,
                              minHeight: 42,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Symbols.forward,
                        color: AppColor.textOnPrimary,
                        size: 24,
                        weight: 600,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartScreen(),
                          ),
                        );
                      },
                      icon: Icon(
                        Symbols.shopping_cart,
                        color: AppColor.textOnPrimary,
                        size: 24,
                        weight: 600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ----- BAGIAN GAMBAR PRODUK -----
                    AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: widget.produk.images.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  image: widget.produk.images.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(
                                            widget.produk.images[index].trim(),
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  color: widget.produk.images.isEmpty
                                      ? AppColor.border
                                      : null,
                                ),
                                child: widget.produk.images.isEmpty
                                    ? const Icon(
                                        Icons.image,
                                        color: AppColor.textHint,
                                      )
                                    : null,
                              );
                            },
                          ),
                          if (widget.produk.images.length > 1)
                            Positioned(
                              bottom: 8,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  widget.produk.images.length,
                                  (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: _currentImageIndex == index ? 24 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _currentImageIndex == index
                                          ? AppColor.primary
                                          : AppColor.surface.withAlpha(150),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // ----- BAGIAN INFORMASI PRODUK (Harga dan Nama) -----
                    ProductInfoSection(produk: widget.produk),

                    const SizedBox(height: 8),

                    // ----- BAGIAN DESKRIPSI PRODUK -----
                    DescriptionSection(
                      description: widget.produk.deskripsiProduk,
                    ),

                    const SizedBox(height: 8),

                    // ----- BAGIAN ULASAN PRODUK -----
                    const ReviewsSection(),

                    const SizedBox(height: 8),

                    // ----- BAGIAN INFORMASI TOKO -----
                    StoreInfoSection(store: _store!),

                    const SizedBox(height: 8),

                    // ----- BAGIAN LOKASI PENGAMBILAN -----
                    const PickupLocationSection(),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: AppColor.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppColor.shadowMedium,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: kBottomNavigationBarHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: Icon(Symbols.chat, color: AppColor.primary),
                          ),
                        ),
                      ),

                      Container(width: 1, height: 24, color: AppColor.divider),

                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            try {
                              final currentUser = await _userController
                                  .getCurrentUser();

                              if (currentUser != null &&
                                  _store != null &&
                                  _store!.uid == widget.produk.storeUid &&
                                  _store!.userUid == currentUser.uid) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Tidak bisa menambahkan produk sendiri ke keranjang',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              await _cartController.addToCart(
                                CartModel(uid: '', product: widget.produk),
                              );

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Produk ditambahkan ke keranjang',
                                  ),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceFirst(
                                      'Exception: ',
                                      '',
                                    ),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: Icon(
                              Symbols.add_shopping_cart,
                              color: AppColor.primary,
                            ),
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 200,
                          height: double.infinity,
                          alignment: Alignment.center,
                          color: AppColor.primary,
                          child: const Text(
                            "Sewa",
                            style: TextStyle(
                              color: AppColor.surface,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}

// Menampilkan bagian informasi produk (harga, nama)
class ProductInfoSection extends StatelessWidget {
  const ProductInfoSection({super.key, required this.produk});

  final ProductModel produk;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: double.infinity,
      decoration: const BoxDecoration(color: AppColor.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Rp",
                    style: TextStyle(
                      color: AppColor.secondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    AppFormatters.formatRupiah(produk.hargaPerHari),
                    style: const TextStyle(
                      color: AppColor.secondary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    "/hari",
                    style: TextStyle(color: AppColor.textHint, fontSize: 16),
                  ),
                ],
              ),
              const Text("2x Disewa"),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            produk.namaProduk,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// Menampilkan bagian ulasan produk (dummy)
class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(color: AppColor.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Ulasan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                child: Text(
                  "Lihat Semua",
                  style: TextStyle(
                    color: AppColor.textHint,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Symbols.star, fill: 1, size: 20, color: Colors.amber),
              SizedBox(width: 4),
              Text(
                "5.0",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 4),
              Text(
                "Penilaian Produk ",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Text("(60)", style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColor.primarySoft,
                child: Icon(Icons.person, size: 16, color: AppColor.primary),
              ),
              SizedBox(width: 12),
              Text(
                "user1234",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Symbols.star, fill: 1, size: 16, color: Colors.amber),
              Icon(Symbols.star, fill: 1, size: 16, color: Colors.amber),
              Icon(Symbols.star, fill: 1, size: 16, color: Colors.amber),
              Icon(Symbols.star, fill: 1, size: 16, color: Colors.amber),
              Icon(Symbols.star, fill: 1, size: 16, color: Colors.amber),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Menampilkan informasi toko (nama, lokasi, rating, dll)
class StoreInfoSection extends StatelessWidget {
  const StoreInfoSection({super.key, required this.store});

  final StoreModel store;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(color: AppColor.surface),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  store.image != null
                      ? ClipOval(
                          child: Image.network(
                            store.image!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColor.primarySoft,
                          child: Icon(
                            Icons.person,
                            size: 32,
                            color: AppColor.primary,
                          ),
                        ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        "Aktif 2 menit lalu",
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        store.location?.toUpperCase() ?? "Lokasi tidak ada",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 28),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  side: const BorderSide(color: AppColor.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Kunjungi",
                  style: TextStyle(color: AppColor.primary, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                child: Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "4.8",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Symbols.star,
                            fill: 1,
                            size: 16,
                            color: Colors.amber,
                          ),
                        ],
                      ),
                      Text(
                        "Penilaian",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(width: 1, height: 24, color: AppColor.divider),
              const Expanded(
                child: Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "16",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Symbols.box, size: 16, color: Colors.brown),
                        ],
                      ),
                      Text(
                        "Produk",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Menampilkan lokasi pengambilan barang (dummy)
class PickupLocationSection extends StatelessWidget {
  const PickupLocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(color: AppColor.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Lokasi Pengambilan",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(height: 132, color: AppColor.border),
          const SizedBox(height: 8),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Symbols.location_pin, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
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
                    Text(
                      "Jl. Jalan Ks Tubun II C, RW 01, Slipi, Palmerah, West Jakarta, Special Capital Region of Jakarta, Java, 10260, Indonesia",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Menampilkan deskripsi produk
class DescriptionSection extends StatelessWidget {
  const DescriptionSection({super.key, required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(color: AppColor.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Deskripsi",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(children: [Text(description)]),
        ],
      ),
    );
  }
}

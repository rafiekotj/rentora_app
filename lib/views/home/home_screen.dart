import 'dart:async';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/controllers/cart_controller.dart';
import 'package:rentora_app/controllers/product_controller.dart';
import 'package:rentora_app/controllers/store_controller.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/core/utils/app_formatters.dart';
import 'package:rentora_app/models/cart_model.dart';
import 'package:rentora_app/models/product_model.dart';
import 'package:rentora_app/views/cart/cart_screen.dart';
import 'package:rentora_app/views/detail_product/detail_product_screen.dart';
import 'package:rentora_app/views/home/category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentBannerIndex = 0;
  late PageController _pageController;
  Timer? _bannerTimer;
  Timer? _countdownTimer;

  final ProductController _produkController = ProductController();
  final CartController _cartController = CartController();
  List<ProductModel> produkList = [];
  bool isLoading = true;
  Duration _flashCountdown = const Duration(hours: 6);

  Map<String, String> storeMap = {};

  // Daftar gambar untuk banner.
  final List<String> bannerImages = [
    "assets/images/banner1.jpg",
    "assets/images/banner2.jpg",
    "assets/images/banner3.jpg",
    "assets/images/banner4.jpg",
    "assets/images/banner5.jpg",
  ];

  // Daftar kategori.
  final List<CategoryItem> categoryItems = const [
    CategoryItem(
      label: "Elektronik",
      value: "Elektronik & Gadget",
      icon: Symbols.speaker,
      color: Color(0xff98A1BC),
    ),
    CategoryItem(
      label: "Pakaian",
      value: "Pakaian & Kostum",
      icon: Symbols.apparel,
      color: Color(0xffFF9B51),
    ),
    CategoryItem(
      label: "Sepatu",
      value: "Sepatu & Alas Kaki",
      icon: Symbols.shoe_cleats,
      color: Color(0xff578FCA),
    ),
    CategoryItem(
      label: "Tas",
      value: "Tas & Koper",
      icon: Symbols.backpack,
      color: Color(0xffF16727),
    ),
    CategoryItem(
      label: "Furniture",
      value: "Furniture & Rumah Tangga",
      icon: Symbols.chair,
      color: Color(0xffFACC15),
    ),
    CategoryItem(
      label: "Buku",
      value: "Buku & Mainan",
      icon: Symbols.book_2,
      color: Color(0xffE2B59A),
    ),
    CategoryItem(
      label: "Hobi",
      value: "Hobi & Alat Musik",
      icon: Symbols.stadia_controller,
      color: Color(0xff758A93),
    ),
    CategoryItem(
      label: "Otomotif",
      value: "Otomotif & Transportasi",
      icon: Symbols.search_hands_free,
      color: Color(0xffBBDCE5),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoPlay();
    _startFlashCountdown();
    _loadProduk();
  }

  // Pre-cache gambar banner
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final image in bannerImages) {
      precacheImage(AssetImage(image), context);
    }
  }

  // Membersihkan controller dan timer
  @override
  void dispose() {
    _bannerTimer?.cancel();
    _countdownTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Memuat data semua produk
  Future<void> _loadProduk() async {
    setState(() {
      isLoading = true;
    });

    final products = await _produkController.getAllProduct();
    final storeController = StoreController();

    // Ambil semua store unik
    final storeUids = products.map((p) => p.storeUid).toList();

    Map<String, String> tempStoreMap = {};

    final storesList = await storeController.getStoresByIds(storeUids);
    final storesMap = {for (var s in storesList) s.uid: s};

    for (var storeUid in storeUids) {
      final store = storesMap[storeUid];
      tempStoreMap[storeUid] =
          store?.location?.toUpperCase() ?? "LOKASI TIDAK ADA";
    }

    if (!mounted) return;

    setState(() {
      produkList = products;
      storeMap = tempStoreMap;
      isLoading = false;
    });
  }

  // Memulai timer yang mengganti halaman banner
  void _startAutoPlay() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentBannerIndex < bannerImages.length - 1) {
        _currentBannerIndex++;
      } else {
        _currentBannerIndex = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _startFlashCountdown() {
    _updateFlashCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateFlashCountdown();
    });
  }

  void _updateFlashCountdown() {
    if (!mounted) return;
    setState(() {
      _flashCountdown = _timeUntilNextReset(DateTime.now());
    });
  }

  Duration _timeUntilNextReset(DateTime now) {
    final int nextBoundaryHour = ((now.hour ~/ 6) + 1) * 6;
    final DateTime nextReset = nextBoundaryHour < 24
        ? DateTime(now.year, now.month, now.day, nextBoundaryHour)
        : DateTime(now.year, now.month, now.day + 1);
    return nextReset.difference(now);
  }

  String _formatCountdown(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);

    final String h = hours.toString().padLeft(2, '0');
    final String m = minutes.toString().padLeft(2, '0');
    final String s = seconds.toString().padLeft(2, '0');

    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final String flashCountdownText = _formatCountdown(_flashCountdown);

    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: AppBar(
        toolbarHeight: 58,
        backgroundColor: AppColor.primary,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Container(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColor.textOnPrimary,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.shadowLight,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const TextField(
                    cursorColor: AppColor.textSecondary,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "Cari produk sewaan...",
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
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                visualDensity: VisualDensity.compact,
                splashRadius: 28,
                icon: Icon(
                  Symbols.chat,
                  color: AppColor.textOnPrimary,
                  size: 24,
                  weight: 700,
                ),
              ),
              ValueListenableBuilder<List<CartModel>>(
                valueListenable: _cartController.cartItemsNotifier,
                builder: (context, cartItems, child) {
                  final Set<String> uniqueProductUids = cartItems
                      .map((item) => item.product.uid)
                      .whereType<String>()
                      .toSet();
                  final int cartCount = uniqueProductUids.length;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CartScreen(),
                            ),
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        visualDensity: VisualDensity.compact,
                        splashRadius: 28,
                        icon: Icon(
                          Symbols.shopping_cart,
                          color: AppColor.textOnPrimary,
                          size: 24,
                          weight: 700,
                        ),
                      ),
                      if (cartCount > 0)
                        Positioned(
                          top: -2,
                          right: -1,
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.error,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppColor.primary,
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              cartCount > 99 ? '99+' : '$cartCount',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColor.textOnPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 10, bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Flash Rent Week",
                            style: TextStyle(
                              color: AppColor.textOnPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Diskon biaya sewa hingga 20%",
                            style: TextStyle(
                              color: AppColor.textOnPrimary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.textOnPrimary.withAlpha(40),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Symbols.bolt,
                            size: 14,
                            weight: 700,
                            color: AppColor.textOnPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            flashCountdownText,
                            style: const TextStyle(
                              color: AppColor.textOnPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Kategori Pilihan",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(48, 24),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      "Lihat semua",
                      style: TextStyle(
                        color: AppColor.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 102,
              width: double.infinity,
              child: ListView.separated(
                padding: const EdgeInsets.only(left: 16),
                scrollDirection: Axis.horizontal,
                itemCount: categoryItems.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = categoryItems[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryScreen(
                            title: item.label,
                            categoryValue: item.value,
                          ),
                        ),
                      );
                    },
                    child: item,
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentBannerIndex = index;
                          });
                        },
                        itemCount: bannerImages.length,
                        itemBuilder: (context, index) {
                          return Image.asset(
                            bannerImages[index],
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                          );
                        },
                      ),
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            bannerImages.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentBannerIndex == index ? 20 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentBannerIndex == index
                                    ? AppColor.textOnPrimary
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
              ),
            ),

            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Flash Sale",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColor.error,
                    ),
                  ),
                  Text(
                    "Berakhir $flashCountdownText",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColor.error,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: SizedBox(
                height: 290,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: produkList.length > 6 ? 6 : produkList.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final produk = produkList[index];
                    final location = storeMap[produk.storeUid] ?? "...";

                    return SizedBox(
                      width: 168,
                      height: double.infinity,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailProductScreen(
                                produk: produk,
                                storeUid: produk.storeUid,
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ProductCard(
                                produk: produk,
                                location: location,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.error,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "-20%",
                                  style: TextStyle(
                                    color: AppColor.textOnPrimary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 14),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Rekomendasi Untukmu",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColor.primary),
                    )
                  : Builder(
                      builder: (context) {
                        final leftProducts = <ProductModel>[];
                        final rightProducts = <ProductModel>[];

                        for (int i = 0; i < produkList.length; i++) {
                          if (i.isEven) {
                            leftProducts.add(produkList[i]);
                          } else {
                            rightProducts.add(produkList[i]);
                          }
                        }

                        Widget buildColumn(List<ProductModel> items) {
                          return Column(
                            children: items.asMap().entries.map((entry) {
                              final index = entry.key;
                              final produk = entry.value;
                              final location =
                                  storeMap[produk.storeUid] ?? "...";

                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index == items.length - 1 ? 0 : 8,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetailProductScreen(
                                              produk: produk,
                                              storeUid: produk.storeUid,
                                            ),
                                      ),
                                    );
                                  },
                                  child: ProductCard(
                                    produk: produk,
                                    location: location,
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: buildColumn(leftProducts)),
                            const SizedBox(width: 8),
                            Expanded(child: buildColumn(rightProducts)),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final ProductModel produk;
  final String location;

  const ProductCard({super.key, required this.produk, required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 14,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                    image: produk.images.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(produk.images.first),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: produk.images.isEmpty ? AppColor.border : null,
                  ),
                  child: produk.images.isEmpty
                      ? const Icon(Icons.image, color: AppColor.textHint)
                      : null,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produk.namaProduk,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "Rp",
                      style: TextStyle(
                        color: AppColor.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      AppFormatters.formatRupiah(produk.hargaPerHari),
                      style: const TextStyle(
                        color: AppColor.secondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const Text(
                      "/hari",
                      style: TextStyle(color: AppColor.textHint, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Symbols.calendar_month,
                      color: AppColor.textHint,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "${produk.minJumlahPinjam}-${produk.maxHariPinjam} hari",
                        style: const TextStyle(
                          color: AppColor.textHint,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Symbols.location_pin,
                      color: AppColor.textHint,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                          color: AppColor.textHint,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const CategoryItem({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: Container(
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Icon(icon, color: color, size: 28, weight: 700),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

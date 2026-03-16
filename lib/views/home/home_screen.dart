import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/controllers/product_controller.dart';
import 'package:rentora_app/controllers/store_controller.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/core/utils/app_formatters.dart';
import 'package:rentora_app/models/product_model.dart';
import 'package:rentora_app/views/cart/cart_screen.dart';
import 'package:rentora_app/views/checkout/payment_success_screen.dart';
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
  Timer? _timer;

  final ProductController _produkController = ProductController();
  List<ProductModel> produkList = [];
  bool isLoading = true;

  Map<int, String> storeMap = {};

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
    _timer?.cancel();
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
    final storeIds = products.map((p) => p.storeId).toList();

    Map<int, String> tempStoreMap = {};

    final storesMap = await storeController.getStoresByIds(storeIds);

    for (var storeId in storeIds) {
      final store = storesMap[storeId];
      tempStoreMap[storeId] =
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
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
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

  @override
  Widget build(BuildContext context) {
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const TextField(
                    cursorColor: AppColor.textSecondary,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
                    decoration: InputDecoration(
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentSuccessScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Symbols.chat,
                  color: AppColor.textOnPrimary,
                  size: 24,
                  weight: 700,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
                icon: Icon(
                  Symbols.shopping_cart,
                  color: AppColor.textOnPrimary,
                  size: 24,
                  weight: 700,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----- KATEGORI -----
            const Text(
              "Kategori",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 12),

            Builder(
              builder: (context) {
                final screenWidth = MediaQuery.of(context).size.width;
                const double sidePadding = 16.0;
                const double spacing = 12.0;
                final itemWidth =
                    (screenWidth - (sidePadding * 2) - (spacing * 3)) / 4;

                return Wrap(
                  spacing: spacing,
                  runSpacing: 12.0,
                  children: categoryItems.map((item) {
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
                      child: SizedBox(width: itemWidth, child: item),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 12),

            // ----- BANNER -----
            SizedBox(
              height: 140,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
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
                            width: _currentBannerIndex == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentBannerIndex == index
                                  ? AppColor.secondary
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

            const SizedBox(height: 12),

            // ----- LIST PRODUK -----
            const Text(
              "Rekomendasi Produk",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 12),

            isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColor.primary),
                  )
                : Builder(
                    builder: (context) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      const double sidePadding = 16.0;
                      const double crossSpacing = 8.0;
                      final itemWidth =
                          (screenWidth - (sidePadding * 2) - crossSpacing) / 2;

                      return Wrap(
                        spacing: crossSpacing,
                        runSpacing: 8.0,
                        children: produkList.map((produk) {
                          final location = storeMap[produk.storeId] ?? "...";
                          return SizedBox(
                            width: itemWidth,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailProductScreen(
                                      produk: produk,
                                      storeId: produk.storeId,
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
                    },
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
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
                image: produk.images.isNotEmpty
                    ? DecorationImage(
                        image: FileImage(File(produk.images.first)),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: produk.images.isEmpty ? AppColor.border : null,
              ),
              child: produk.images.isEmpty
                  ? const Icon(Icons.image, color: AppColor.textHint)
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produk.namaProduk,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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
                      style: TextStyle(
                        color: AppColor.secondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "/hari",
                      style: TextStyle(color: AppColor.textHint, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Symbols.location_pin,
                      color: AppColor.textHint,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(color: AppColor.textHint, fontSize: 10),
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
          width: 72,
          height: 72,
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

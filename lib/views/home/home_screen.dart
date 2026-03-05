import 'dart:async';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/views/cart/cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<CategoryItem> categories = const [
    CategoryItem(
      label: "Elektronik",
      icon: Symbols.speaker,
      color: Color(0xff98A1BC),
    ),
    CategoryItem(
      label: "Pakaian",
      icon: Symbols.apparel,
      color: Color(0xffFF9B51),
    ),
    CategoryItem(
      label: "Sepatu",
      icon: Symbols.shoe_cleats,
      color: Color(0xff578FCA),
    ),
    CategoryItem(
      label: "Tas",
      icon: Symbols.backpack,
      color: Color(0xffF16727),
    ),
    CategoryItem(
      label: "Furniture",
      icon: Symbols.chair,
      color: Color(0xffFACC15),
    ),
    CategoryItem(label: "Buku", icon: Symbols.book_2, color: Color(0xffE2B59A)),
    CategoryItem(
      label: "Hobi",
      icon: Symbols.stadia_controller,
      color: Color(0xff758A93),
    ),
    CategoryItem(
      label: "Otomotif",
      icon: Symbols.search_hands_free,
      color: Color(0xffBBDCE5),
    ),
  ];

  int _currentBannerIndex = 0;
  late PageController _pageController;
  Timer? _timer;

  final List<String> bannerImages = [
    "assets/images/banner1.jpg",
    "assets/images/banner2.jpg",
    "assets/images/banner3.jpg",
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentBannerIndex < bannerImages.length - 1) {
        _currentBannerIndex++;
      } else {
        _currentBannerIndex = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
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
                  Symbols.chat,
                  color: AppColor.textOnPrimary,
                  size: 24,
                  weight: 600,
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
                  weight: 600,
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
            // ===== Kategori =====
            const Text(
              "Kategori",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              itemCount: categories.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                mainAxisExtent: 106,
              ),
              itemBuilder: (context, index) {
                final item = categories[index];

                return CategoryItem(
                  label: item.label,
                  icon: item.icon,
                  color: item.color,
                );
              },
            ),

            SizedBox(height: 12),

            // ===== Banner =====
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
                                  ? AppColor.divider
                                  : Colors.white.withAlpha(150),
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

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const CategoryItem({
    super.key,
    required this.label,
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

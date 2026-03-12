import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/controllers/product_controller.dart';
import 'package:rentora_app/controllers/store_controller.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/models/product_model.dart';
import 'package:rentora_app/views/detail_product/detail_product_screen.dart';
import 'package:rentora_app/views/home/home_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String title;
  final String categoryValue;

  const CategoryScreen({
    super.key,
    required this.title,
    required this.categoryValue,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<ProductModel> produkList = [];

  bool isLoading = true;

  final ProductController _produkController = ProductController();

  Map<int, String> storeMap = {};

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // Mengambil data produk dari controller berdasarkan kategori
  Future<void> _loadProducts() async {
    setState(() {
      isLoading = true;
    });

    // Ambil semua produk berdasarkan kategori
    final data = await _produkController.getProductByKategori(
      widget.categoryValue,
    );

    final storeController = StoreController();
    Map<int, String> tempStoreMap = {};

    // Ambil lokasi store untuk semua produk
    final storeIds = data.map((p) => p.storeId).toList();
    final storesMap = await storeController.getStoresByIds(storeIds);

    for (var storeId in storeIds) {
      final store = storesMap[storeId];
      tempStoreMap[storeId] =
          store?.location?.toUpperCase() ?? "LOKASI TIDAK ADA";
    }

    if (!mounted) return;

    setState(() {
      produkList = data;
      storeMap = tempStoreMap;
      isLoading = false;
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
                onPressed: () {},
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColor.primary),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  width: double.infinity,
                  decoration: const BoxDecoration(color: AppColor.surface),
                  child: Row(
                    children: [
                      const Text("Kategori: ", style: TextStyle(fontSize: 16)),
                      Text(
                        widget.categoryValue,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: produkList.isEmpty
                      ? Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: AppColor.surface,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Lottie.asset("assets/animations/EmptyBox.json"),
                                Text('Tidak ada produk dalam kategori ini.'),
                              ],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: AppColor.surface,
                                ),
                                child: const Text(
                                  "Rekomendasi",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Grid untuk menampilkan produk.
                              Container(
                                padding: const EdgeInsets.all(8),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    const double crossSpacing = 8.0;
                                    final itemWidth =
                                        (constraints.maxWidth - crossSpacing) /
                                        2;
                                    return Wrap(
                                      spacing: crossSpacing,
                                      runSpacing: 8.0,
                                      children: produkList.map((produk) {
                                        final location =
                                            storeMap[produk.storeId] ?? "...";
                                        return SizedBox(
                                          width: itemWidth,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetailProductScreen(
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
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

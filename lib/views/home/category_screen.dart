import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/models/product_model.dart';
import 'package:rentora_app/services/database/db_helper.dart';
import 'package:rentora_app/views/home/home_screen.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/views/detail/detail_product_screen.dart';

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
  List<ProductModel> productList = [];
  bool isLoading = true;

  Future<void> _loadProducts() async {
    final allProducts = await DBHelper.getAllProduk();
    if (!mounted) return;

    setState(() {
      productList = allProducts
          .where((product) => product.kategori == widget.categoryValue)
          .toList();
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
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
          padding: EdgeInsets.only(right: 8),
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
              SizedBox(width: 8),
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
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      Text("Kategori: ", style: TextStyle(fontSize: 16)),
                      Text(
                        widget.categoryValue,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: productList.isEmpty
                      ? Container(
                          width: double.infinity,
                          decoration: BoxDecoration(color: Colors.white),
                          child: Center(
                            child: Text('Tidak ada produk dalam kategori ini.'),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                ),
                                child: Text(
                                  "Rekomendasi",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    double crossSpacing = 8.0;
                                    final itemWidth =
                                        (constraints.maxWidth - crossSpacing) /
                                        2;

                                    return Wrap(
                                      spacing: crossSpacing,
                                      runSpacing: 8.0,
                                      children: productList
                                          .map(
                                            (produk) => SizedBox(
                                              width: itemWidth,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailProductScreen(
                                                            produk: produk,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: ProductCard(
                                                  produk: produk,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
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

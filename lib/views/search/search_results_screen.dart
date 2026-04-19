import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/controllers/product_controller.dart';
import 'package:rentora_app/controllers/store_controller.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/models/product_model.dart';
import 'package:rentora_app/views/detail_product/detail_product_screen.dart';
import 'package:rentora_app/widgets/product_card.dart';

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;
  const SearchResultsScreen({Key? key, this.initialQuery = ''})
    : super(key: key);

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final ProductController _productController = ProductController();
  final StoreController _storeController = StoreController();
  final TextEditingController _searchController = TextEditingController();

  List<ProductModel> produkList = [];
  Map<String, String> storeMap = {};
  bool isLoading = true;

  String? selectedDistrict;
  List<String> districtOptions = [];
  String priceOrder = ''; // 'asc' or 'desc'

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    _loadDistrictOptions();
    _performSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDistrictOptions() async {
    final all = await _productController.getAllProduct();
    final storeUids = all
        .map((p) => p.storeUid)
        .whereType<String>()
        .toSet()
        .toList();
    final stores = await _storeController.getStoresByIds(storeUids);
    final districts = stores
        .map((s) => s.district)
        .whereType<String>()
        .toSet()
        .toList();
    districts.sort();
    if (!mounted) return;
    setState(() {
      districtOptions = districts;
    });
  }

  Future<void> _performSearch() async {
    setState(() {
      isLoading = true;
    });

    final results = await _productController.searchProducts(
      query: _searchController.text,
      district: selectedDistrict,
      priceOrder: priceOrder,
    );

    final storeUids = results
        .map((p) => p.storeUid)
        .whereType<String>()
        .toSet()
        .toList();
    final storesList = await _storeController.getStoresByIds(storeUids);
    final tempStoreMap = {
      for (var s in storesList)
        s.uid: s.district?.toUpperCase() ?? 'LOKASI TIDAK ADA',
    };

    if (!mounted) return;
    setState(() {
      produkList = results;
      storeMap = tempStoreMap;
      isLoading = false;
    });
  }

  void _onDistrictChanged(String? district) {
    setState(() {
      selectedDistrict = district;
    });
    _performSearch();
  }

  void _onPriceOrderChanged(String? order) {
    setState(() {
      priceOrder = order == 'Terendah'
          ? 'asc'
          : (order == 'Tertinggi' ? 'desc' : '');
    });
    _performSearch();
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
                  child: TextField(
                    controller: _searchController,
                    cursorColor: AppColor.textSecondary,
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColor.textPrimary,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "Cari produk...",
                      hintStyle: TextStyle(
                        color: AppColor.textSecondary,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      prefixIcon: Icon(
                        Symbols.search,
                        weight: 600,
                        color: AppColor.textSecondary,
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Symbols.search),
                        onPressed: _performSearch,
                        color: AppColor.primary,
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 42,
                        minHeight: 42,
                      ),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            width: double.infinity,
            decoration: const BoxDecoration(color: AppColor.surface),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: selectedDistrict,
                    decoration: const InputDecoration(
                      isDense: true,
                      labelText: 'District',
                      border: InputBorder.none,
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Semua'),
                      ),
                      ...districtOptions
                          .map(
                            (d) => DropdownMenuItem<String?>(
                              value: d,
                              child: Text(d),
                            ),
                          )
                          .toList(),
                    ],
                    onChanged: _onDistrictChanged,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<String?>(
                    value: priceOrder == 'asc'
                        ? 'Terendah'
                        : (priceOrder == 'desc' ? 'Tertinggi' : null),
                    decoration: const InputDecoration(
                      isDense: true,
                      labelText: 'Urut Harga',
                      border: InputBorder.none,
                    ),
                    items: const [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Default'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'Terendah',
                        child: Text('Terendah'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'Tertinggi',
                        child: Text('Tertinggi'),
                      ),
                    ],
                    onChanged: _onPriceOrderChanged,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColor.primary),
                  )
                : produkList.isEmpty
                ? const Center(
                    child: Text('Tidak ada produk untuk pencarian ini.'),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              const double crossSpacing = 8.0;
                              final itemWidth =
                                  (constraints.maxWidth - crossSpacing) / 2;
                              return Wrap(
                                spacing: crossSpacing,
                                runSpacing: 8.0,
                                children: produkList.map((produk) {
                                  final location =
                                      storeMap[produk.storeUid] ?? '...';
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

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/controllers/product_controller.dart';
import 'package:rentora_app/controllers/store_controller.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/models/product_model.dart';
import 'package:rentora_app/views/detail_product/detail_product_screen.dart';
import 'package:rentora_app/core/extensions/navigator.dart';
import 'package:rentora_app/widgets/product_card.dart';
import 'package:rentora_app/widgets/custom_button.dart';

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;
  const SearchResultsScreen({super.key, this.initialQuery = ''});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final ProductController _productController = ProductController();
  final StoreController _storeController = StoreController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  String _sortOption = 'Paling Sesuai';
  String _selectedRadius = '500';
  final List<String> _regionOptions = [
    'DKI Jakarta',
    'Jabodetabek',
    'Jawa Barat',
    'Banten',
  ];
  final Set<String> _selectedRegions = {};
  String? _selectedPriceRangeChip;

  List<ProductModel> produkList = [];
  Map<String, String> storeMap = {};
  bool isLoading = true;

  String? selectedDistrict;
  List<String> districtOptions = [];
  String priceOrder = ''; // 'asc' or 'desc'

  @override
  void initState() {
    super.initState();
    // Set query awal, ambil opsi distrik, dan lakukan pencarian
    _searchController.text = widget.initialQuery;
    _loadDistrictOptions();
    _performSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Widget _priceRangeChip(
    String label,
    String min,
    String max, {
    StateSetter? setModalState,
  }) {
    final selected = _selectedPriceRangeChip == label;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF333333),
          fontSize: 13,
        ),
      ),
      selected: selected,
      elevation: 0,
      pressElevation: 0,
      shadowColor: Colors.transparent,
      selectedShadowColor: Colors.transparent,
      showCheckmark: true,
      checkmarkColor: Colors.white,
      onSelected: (s) {
        if (setModalState != null) {
          setModalState(() {
            _selectedPriceRangeChip = s ? label : null;
            if (s) {
              _minPriceController.text = min;
              _maxPriceController.text = max;
            } else {
              _minPriceController.clear();
              _maxPriceController.clear();
            }
          });
        } else {
          setState(() {
            _selectedPriceRangeChip = s ? label : null;
            if (s) {
              _minPriceController.text = min;
              _maxPriceController.text = max;
            } else {
              _minPriceController.clear();
              _maxPriceController.clear();
            }
          });
        }
      },
      backgroundColor: const Color(0xFFF0F2F4),
      selectedColor: AppColor.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Urutkan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RadioListTile<String>(
                          title: Text(
                            'Paling Sesuai',
                            style: TextStyle(
                              color: _sortOption == 'Paling Sesuai'
                                  ? AppColor.primary
                                  : const Color(0xFF222222),
                              fontWeight: _sortOption == 'Paling Sesuai'
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          value: 'Paling Sesuai',
                          groupValue: _sortOption,
                          controlAffinity: ListTileControlAffinity.trailing,
                          activeColor: AppColor.primary,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (v) {
                            if (v == null) return;
                            setModalState(() {
                              _sortOption = v;
                              priceOrder = '';
                            });
                            _performSearch();
                          },
                        ),
                        RadioListTile<String>(
                          title: Text(
                            'Terbaru',
                            style: TextStyle(
                              color: _sortOption == 'Terbaru'
                                  ? AppColor.primary
                                  : const Color(0xFF222222),
                              fontWeight: _sortOption == 'Terbaru'
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          value: 'Terbaru',
                          groupValue: _sortOption,
                          controlAffinity: ListTileControlAffinity.trailing,
                          activeColor: AppColor.primary,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (v) {
                            if (v == null) return;
                            setModalState(() {
                              _sortOption = v;
                              priceOrder = '';
                            });
                            _performSearch();
                          },
                        ),
                        RadioListTile<String>(
                          title: Text(
                            'Harga Tertinggi',
                            style: TextStyle(
                              color: _sortOption == 'Harga Tertinggi'
                                  ? AppColor.primary
                                  : const Color(0xFF222222),
                              fontWeight: _sortOption == 'Harga Tertinggi'
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          value: 'Harga Tertinggi',
                          groupValue: _sortOption,
                          controlAffinity: ListTileControlAffinity.trailing,
                          activeColor: AppColor.primary,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (v) {
                            if (v == null) return;
                            setModalState(() {
                              _sortOption = v;
                              priceOrder = 'desc';
                            });
                            _performSearch();
                          },
                        ),
                        RadioListTile<String>(
                          title: Text(
                            'Harga Terendah',
                            style: TextStyle(
                              color: _sortOption == 'Harga Terendah'
                                  ? AppColor.primary
                                  : const Color(0xFF222222),
                              fontWeight: _sortOption == 'Harga Terendah'
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          value: 'Harga Terendah',
                          groupValue: _sortOption,
                          controlAffinity: ListTileControlAffinity.trailing,
                          activeColor: AppColor.primary,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (v) {
                            if (v == null) return;
                            setModalState(() {
                              _sortOption = v;
                              priceOrder = 'asc';
                            });
                            _performSearch();
                          },
                        ),
                        RadioListTile<String>(
                          title: Text(
                            'Terlaris',
                            style: TextStyle(
                              color: _sortOption == 'Terlaris'
                                  ? AppColor.primary
                                  : const Color(0xFF222222),
                              fontWeight: _sortOption == 'Terlaris'
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          value: 'Terlaris',
                          groupValue: _sortOption,
                          controlAffinity: ListTileControlAffinity.trailing,
                          activeColor: AppColor.primary,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (v) {
                            if (v == null) return;
                            setModalState(() {
                              _sortOption = v;
                              priceOrder = '';
                            });
                            _performSearch();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Filter',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Jarak toko ke alamat'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilterChip(
                              label: Text(
                                'Radius 500 m',
                                style: TextStyle(
                                  color: _selectedRadius == '500'
                                      ? Colors.white
                                      : const Color(0xFF333333),
                                ),
                              ),
                              selected: _selectedRadius == '500',
                              elevation: 0,
                              pressElevation: 0,
                              shadowColor: Colors.transparent,
                              selectedShadowColor: Colors.transparent,
                              showCheckmark: true,
                              checkmarkColor: Colors.white,
                              onSelected: (s) => setModalState(
                                () => _selectedRadius = s ? '500' : '',
                              ),
                              backgroundColor: const Color(0xFFF0F2F4),
                              selectedColor: AppColor.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            FilterChip(
                              label: Text(
                                'Radius 1 km',
                                style: TextStyle(
                                  color: _selectedRadius == '1k'
                                      ? Colors.white
                                      : const Color(0xFF333333),
                                ),
                              ),
                              selected: _selectedRadius == '1k',
                              elevation: 0,
                              pressElevation: 0,
                              shadowColor: Colors.transparent,
                              selectedShadowColor: Colors.transparent,
                              showCheckmark: true,
                              checkmarkColor: Colors.white,
                              onSelected: (s) => setModalState(
                                () => _selectedRadius = s ? '1k' : '',
                              ),
                              backgroundColor: const Color(0xFFF0F2F4),
                              selectedColor: AppColor.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            FilterChip(
                              label: Text(
                                'Radius 2 km',
                                style: TextStyle(
                                  color: _selectedRadius == '2k'
                                      ? Colors.white
                                      : const Color(0xFF333333),
                                ),
                              ),
                              selected: _selectedRadius == '2k',
                              elevation: 0,
                              pressElevation: 0,
                              shadowColor: Colors.transparent,
                              selectedShadowColor: Colors.transparent,
                              showCheckmark: true,
                              checkmarkColor: Colors.white,
                              onSelected: (s) => setModalState(
                                () => _selectedRadius = s ? '2k' : '',
                              ),
                              backgroundColor: const Color(0xFFF0F2F4),
                              selectedColor: AppColor.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            FilterChip(
                              label: Text(
                                'Radius 5 km',
                                style: TextStyle(
                                  color: _selectedRadius == '5k'
                                      ? Colors.white
                                      : const Color(0xFF333333),
                                ),
                              ),
                              selected: _selectedRadius == '5k',
                              elevation: 0,
                              pressElevation: 0,
                              shadowColor: Colors.transparent,
                              selectedShadowColor: Colors.transparent,
                              showCheckmark: true,
                              checkmarkColor: Colors.white,
                              onSelected: (s) => setModalState(
                                () => _selectedRadius = s ? '5k' : '',
                              ),
                              backgroundColor: const Color(0xFFF0F2F4),
                              selectedColor: AppColor.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Lokasi'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _regionOptions.map((r) {
                            final sel = _selectedRegions.contains(r);
                            return FilterChip(
                              label: Text(
                                r,
                                style: TextStyle(
                                  color: sel
                                      ? Colors.white
                                      : const Color(0xFF333333),
                                ),
                              ),
                              selected: sel,
                              elevation: 0,
                              pressElevation: 0,
                              shadowColor: Colors.transparent,
                              selectedShadowColor: Colors.transparent,
                              onSelected: (selected) {
                                setModalState(() {
                                  if (selected) {
                                    _selectedRegions.add(r);
                                  } else {
                                    _selectedRegions.remove(r);
                                  }
                                });
                              },
                              backgroundColor: const Color(0xFFF0F2F4),
                              selectedColor: AppColor.primary,
                              checkmarkColor: Colors.white,
                              showCheckmark: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        const Text('Harga'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _minPriceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Rp Terendah',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF9AA3AD),
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 12,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE7ECF0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColor.primary,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _maxPriceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Rp Tertinggi',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF9AA3AD),
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 12,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE7ECF0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColor.primary,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _priceRangeChip(
                              'Rp20rb - Rp50rb',
                              '20000',
                              '50000',
                              setModalState: setModalState,
                            ),
                            _priceRangeChip(
                              'Rp50rb - Rp100rb',
                              '50000',
                              '100000',
                              setModalState: setModalState,
                            ),
                            _priceRangeChip(
                              'Rp100rb - Rp200rb',
                              '100000',
                              '200000',
                              setModalState: setModalState,
                            ),
                            _priceRangeChip(
                              'Rp200rb - Rp500rb',
                              '200000',
                              '500000',
                              setModalState: setModalState,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  setModalState(() {
                                    _selectedRadius = '500';
                                    _selectedRegions.clear();
                                    _minPriceController.clear();
                                    _maxPriceController.clear();
                                    _selectedPriceRangeChip = null;
                                  });
                                },
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(color: AppColor.primary),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: CustomButton(
                                text: 'Terapkan',
                                onPressed: () {
                                  Navigator.pop(context);
                                  _performSearch();
                                },
                                backgroundColor: AppColor.primary,
                                textColor: AppColor.textOnPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Ambil daftar distrik dari semua produk
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

  // Lakukan pencarian produk berdasarkan query, distrik, dan urutan harga
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
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.sort),
                color: AppColor.textOnPrimary,
                onPressed: _showSortSheet,
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                color: AppColor.textOnPrimary,
                onPressed: _showFilterSheet,
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
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
                                        context.push(
                                          DetailProductScreen(
                                            produk: produk,
                                            storeUid: produk.storeUid,
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

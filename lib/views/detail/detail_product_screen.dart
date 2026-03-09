import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/models/product_model.dart';
import 'package:rentora_app/controllers/store_controller.dart';
import 'package:rentora_app/models/store_model.dart';
import 'package:rentora_app/views/cart/cart_screen.dart';
import 'package:rentora_app/controllers/cart_controller.dart';

class DetailProductScreen extends StatefulWidget {
  final ProductModel produk;
  const DetailProductScreen({super.key, required this.produk});

  @override
  State<DetailProductScreen> createState() => _DetailProductScreenState();
}

class _DetailProductScreenState extends State<DetailProductScreen> {
  late PageController _pageController;
  int _currentImageIndex = 0;
  final StoreController _storeController = StoreController();
  late Future<StoreModel?> _storeFuture;
  final CartController _cartController = CartController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _storeFuture = _storeController.getStoreByUserId(widget.produk.userId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String formatRupiah(int number) {
    final value = NumberFormat("#,###", "id_ID").format(number);
    return "Rp $value";
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // IMAGE SECTION
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
                                    image: FileImage(
                                      File(widget.produk.images[index]),
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            color: widget.produk.images.isEmpty
                                ? Colors.grey[200]
                                : null,
                          ),
                          child: widget.produk.images.isEmpty
                              ? const Icon(Icons.image, color: Colors.grey)
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
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentImageIndex == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentImageIndex == index
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

              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Rp",
                              style: TextStyle(
                                color: AppColor.secondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              NumberFormat(
                                "#,###",
                                "id_ID",
                              ).format(widget.produk.hargaPerHari),
                              style: TextStyle(
                                color: AppColor.secondary,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "/hari",
                              style: TextStyle(
                                color: AppColor.textHint,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),

                        Text("2x Disewa"),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.produk.namaProduk,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 8),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Ulasan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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

                    SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Symbols.star,
                          fill: 1,
                          size: 20,
                          color: Colors.amber,
                        ),

                        SizedBox(width: 4),

                        Text(
                          "5.0",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(width: 4),

                        Text(
                          "Penilaian Produk ",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        Text("(60)", style: TextStyle(fontSize: 12)),
                      ],
                    ),

                    SizedBox(height: 8),

                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColor.primarySoft,
                          child: Icon(
                            Icons.person,
                            size: 16,
                            color: AppColor.primary,
                          ),
                        ),

                        SizedBox(width: 12),

                        Text(
                          "user1234",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Symbols.star,
                          fill: 1,
                          size: 16,
                          color: Colors.amber,
                        ),
                        Icon(
                          Symbols.star,
                          fill: 1,
                          size: 16,
                          color: Colors.amber,
                        ),
                        Icon(
                          Symbols.star,
                          fill: 1,
                          size: 16,
                          color: Colors.amber,
                        ),
                        Icon(
                          Symbols.star,
                          fill: 1,
                          size: 16,
                          color: Colors.amber,
                        ),
                        Icon(
                          Symbols.star,
                          fill: 1,
                          size: 16,
                          color: Colors.amber,
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                    Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
                      style: TextStyle(fontSize: 14),
                    ),

                    SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColor.textHint,
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
                                color: AppColor.textHint,
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
                                color: AppColor.textHint,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 8),

              FutureBuilder<StoreModel?>(
                future: _storeFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (snapshot.hasData && snapshot.data != null) {
                    final store = snapshot.data!;
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(color: Colors.white),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  store.image != null
                                      ? ClipOval(
                                          child: Image.file(
                                            File(store.image!),
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 28,
                                          backgroundColor: AppColor.primarySoft,
                                          child: Icon(
                                            Icons.person,
                                            size: 32,
                                            color: AppColor.primary,
                                          ),
                                        ),
                                  SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        store.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        "Aktif 2 menit lalu",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        store.location?.toUpperCase() ??
                                            "Lokasi tidak ada",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  minimumSize: Size(0, 28),
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  side: BorderSide(color: AppColor.primary),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "Kunjungi",
                                  style: TextStyle(
                                    color: AppColor.primary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                              Container(
                                width: 1,
                                height: 24,
                                color: AppColor.divider,
                              ),
                              Expanded(
                                child: Center(
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "16",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            Symbols.box,
                                            size: 16,
                                            color: Colors.brown,
                                          ),
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
                  } else {
                    return Center(child: Text("Toko tidak ditemukan"));
                  }
                },
              ),

              SizedBox(height: 8),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Lokasi Pengambilan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(height: 132, color: AppColor.border),
                    SizedBox(height: 8),
                    Row(
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
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
              ),

              SizedBox(height: 8),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Deskripsi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(children: [Text(widget.produk.deskripsiProduk)]),
                  ],
                ),
              ),

              SizedBox(height: 8),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 56,
        color: AppColor.textOnPrimary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Center(
                  child: Icon(Symbols.chat, color: AppColor.primary),
                ),
              ),
            ),
            Container(width: 1, height: 24, color: AppColor.divider),

            // Icon tambah ke keranjang
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _cartController.addToCart(widget.produk);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Produk ditambahkan ke keranjang'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
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
                child: Text(
                  "Sewa",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

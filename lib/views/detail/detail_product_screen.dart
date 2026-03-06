import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/core/constants/app_color.dart';

class DetailProductScreen extends StatefulWidget {
  const DetailProductScreen({super.key});

  @override
  State<DetailProductScreen> createState() => _DetailProductScreenState();
}

class _DetailProductScreenState extends State<DetailProductScreen> {
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // IMAGE SECTION
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                color: AppColor.border,
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
                              "60.000",
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

                        Text("72x Disewa"),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Kamera Digital",
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColor.textHint,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColor.textHint,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColor.textHint,
                            borderRadius: BorderRadius.circular(8),
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Pict Cam Store",
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
                                  "KOTA JAKARTA BARAT",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
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
                        Column(
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
                              "Jl. Jalan Ks Tubun II C, RW 01, Slipi, Palmerah,\nWest Jakarta, Special Capital Region of Jakarta,\nJava, 10260, Indonesia",
                            ),
                          ],
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
                    Wrap(
                      children: [
                        Text(
                          "Kamera Digital Merk Canon EOS 700.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 8),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 56,
          color: AppColor.textOnPrimary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(Symbols.chat, color: AppColor.primary),
                ),
              ),

              Container(width: 1, height: 24, color: AppColor.divider),

              Expanded(
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Symbols.add_shopping_cart,
                    color: AppColor.primary,
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
      ),
    );
  }
}

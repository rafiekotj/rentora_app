import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/models/product_model.dart';
import 'package:rentora_app/services/database/db_helper.dart';
import 'package:rentora_app/views/seller/seller_cu_product_screen.dart';
import 'package:rentora_app/widgets/custom_button.dart';

class SellerProductScreen extends StatefulWidget {
  const SellerProductScreen({super.key});

  @override
  State<SellerProductScreen> createState() => _SellerProductScreenState();
}

class _SellerProductScreenState extends State<SellerProductScreen> {
  List<ProductModel> produkList = [];

  String formatRupiah(dynamic number) {
    if (number == null) return "";

    final value = int.tryParse(number.toString().replaceAll(".", "")) ?? 0;

    return NumberFormat("#,###", "id_ID").format(value).replaceAll(",", ".");
  }

  Future<void> loadProduk() async {
    final data = await DBHelper.getAllProduk();

    setState(() {
      produkList = data;
    });
  }

  @override
  void initState() {
    super.initState();
    loadProduk();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: AppBar(
        toolbarHeight: 58,
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.textOnPrimary,
        title: Text(
          "Produk Saya",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Symbols.search, weight: 600)),
          SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  SORT & FILTER
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Row(
                        children: [
                          Icon(
                            Symbols.sort,
                            size: 18,
                            color: AppColor.textPrimary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Urutkan",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColor.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 12),

                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Row(
                        children: [
                          Icon(
                            Symbols.filter_list,
                            size: 18,
                            color: AppColor.textPrimary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Filter",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColor.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: produkList.length,
                itemBuilder: (context, index) {
                  final produk = produkList[index];

                  return Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // IMAGE
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: produk.images.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.file(
                                    File(produk.images.first),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(Symbols.image, color: Colors.grey),
                        ),

                        SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // NAMA PRODUK
                              Text(
                                produk.namaProduk,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              SizedBox(height: 4),

                              // KATEGORI
                              Text(
                                produk.kategori,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColor.textHint,
                                ),
                              ),

                              SizedBox(height: 6),

                              Row(
                                children: [
                                  Text(
                                    "Rp ${formatRupiah(produk.hargaPerHari)}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.secondary,
                                    ),
                                  ),
                                  Text(
                                    " / hari",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColor.textHint,
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // STOK
                                  Text(
                                    "Stok: ${produk.stok}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColor.textSecondary,
                                    ),
                                  ),

                                  Row(
                                    children: [
                                      // EDIT
                                      IconButton(
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SellerCuProductScreen(
                                                    produk: produk,
                                                  ),
                                            ),
                                          );

                                          loadProduk();
                                        },
                                        icon: Icon(
                                          Icons.edit_outlined,
                                          size: 20,
                                          color: Colors.orange,
                                        ),
                                      ),

                                      // DELETE
                                      IconButton(
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text("Konfirmasi Hapus"),
                                              content: Text(
                                                "Apakah kamu yakin ingin menghapus produk ini?",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: Text("Batal"),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: Text(
                                                    "Hapus",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            await DBHelper.deleteProduk(
                                              produk.id!,
                                            );
                                            loadProduk();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Produk berhasil dihapus",
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        icon: Icon(
                                          Icons.delete_outline,
                                          size: 20,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: CustomButton(
            text: "Tambah Produk",
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SellerCuProductScreen(),
                ),
              );

              loadProduk();
            },
          ),
        ),
      ),
    );
  }
}

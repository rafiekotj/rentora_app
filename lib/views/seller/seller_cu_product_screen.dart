import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/models/produk_model.dart';
import 'package:rentora_app/services/database/db_helper.dart';
import 'package:rentora_app/widgets/custom_button.dart';

class SellerCuProductScreen extends StatefulWidget {
  final ProdukModel? produk;

  const SellerCuProductScreen({super.key, this.produk});

  @override
  State<SellerCuProductScreen> createState() => _SellerCuProductScreenState();
}

class _SellerCuProductScreenState extends State<SellerCuProductScreen> {
  String? _selectedKategori;
  String? _hargaPerHari;

  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _namaProdukController = TextEditingController();
  final TextEditingController _deskripsiProdukController =
      TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController(
    text: "0",
  );
  final TextEditingController _jumlahPinjamController = TextEditingController(
    text: "1",
  );
  final TextEditingController _hariPinjamController = TextEditingController(
    text: "7",
  );

  String formatRupiah(String number) {
    if (number.isEmpty) return "";
    final value = int.tryParse(number.replaceAll(".", "")) ?? 0;
    return NumberFormat("#,###", "id_ID").format(value).replaceAll(",", ".");
  }

  Future<void> _pickImage() async {
    if (_images.length >= 5) return;
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      File savedImage = await _saveImageToLocal(imageFile);
      setState(() {
        _images.add(savedImage);
      });
    }
  }

  Future<File> _saveImageToLocal(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final imageDir = Directory("${directory.path}/produk_images");
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final savedImage = await image.copy("${imageDir.path}/$fileName.jpg");
    return savedImage;
  }

  Future<void> _simpanProduk() async {
    if (_images.isEmpty ||
        _namaProdukController.text.isEmpty ||
        _deskripsiProdukController.text.isEmpty ||
        _selectedKategori == null ||
        (_hargaPerHari == null || _hargaPerHari!.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lengkapi semua data produk")));
      return;
    }

    final produk = ProdukModel(
      id: widget.produk?.id,
      images: _images.map((e) => e.path).toList(),
      namaProduk: _namaProdukController.text,
      deskripsiProduk: _deskripsiProdukController.text,
      kategori: _selectedKategori!,
      hargaPerHari: int.tryParse(_hargaPerHari!.replaceAll(".", "")) ?? 0,
      stok: int.tryParse(_stokController.text) ?? 0,
      minJumlahPinjam: int.tryParse(_jumlahPinjamController.text) ?? 1,
      maxHariPinjam: int.tryParse(_hariPinjamController.text) ?? 7,
    );

    try {
      if (widget.produk != null) {
        await DBHelper.updateProduk(produk);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Produk berhasil diupdate")));
      } else {
        await DBHelper.insertProduk(produk);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Produk berhasil disimpan")));
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan saat menyimpan produk")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.produk != null) {
      _namaProdukController.text = widget.produk!.namaProduk;
      _deskripsiProdukController.text = widget.produk!.deskripsiProduk;
      _selectedKategori = widget.produk!.kategori;
      _hargaPerHari = widget.produk!.hargaPerHari.toString();
      _stokController.text = widget.produk!.stok.toString();
      _jumlahPinjamController.text = widget.produk!.minJumlahPinjam.toString();
      _hariPinjamController.text = widget.produk!.maxHariPinjam.toString();
      _images.addAll(widget.produk!.images.map((e) => File(e)));
    }
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
          "Tambah Produk",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: "Foto Produk ",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColor.textPrimary,
                              ),
                              children: [
                                TextSpan(
                                  text: "*",
                                  style: TextStyle(color: AppColor.error),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 12),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                ..._images.map((image) {
                                  return Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: AppColor.border,
                                              width: 1,
                                            ),
                                            image: DecorationImage(
                                              image: FileImage(image),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),

                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _images.remove(image);
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppColor.error,
                                                shape: BoxShape.circle,
                                              ),
                                              padding: EdgeInsets.all(4),
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 8,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),

                                if (_images.length < 5)
                                  GestureDetector(
                                    onTap: _pickImage,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColor.primary,
                                          width: 1.5,
                                        ),
                                        color: AppColor.primarySoft,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add,
                                            color: AppColor.primary,
                                            size: 20,
                                          ),
                                          Text(
                                            "Tambah\nFoto",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: AppColor.primary,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(
                      height: 32,
                      indent: 16,
                      endIndent: 16,
                      color: AppColor.divider,
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: "Nama Produk ",
                                  style: TextStyle(
                                    color: AppColor.textPrimary,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "*",
                                      style: TextStyle(color: AppColor.error),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "${_namaProdukController.text.length}/255",
                                style: TextStyle(
                                  color: AppColor.textHint,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          TextField(
                            controller: _namaProdukController,
                            maxLength: 255,
                            onChanged: (value) {
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              counterText: "",
                              hintText: "Masukkan Nama Produk",
                              hintStyle: TextStyle(
                                color: AppColor.textHint,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(
                      height: 32,
                      indent: 16,
                      endIndent: 16,
                      color: AppColor.divider,
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: "Deskripsi Produk ",
                                  style: TextStyle(
                                    color: AppColor.textPrimary,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "*",
                                      style: TextStyle(color: AppColor.error),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "${_deskripsiProdukController.text.length}/3000",
                                style: TextStyle(
                                  color: AppColor.textHint,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          TextField(
                            controller: _deskripsiProdukController,
                            maxLength: 3000,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            onChanged: (value) {
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              counterText: "",
                              hintText: "Masukkan Deskripsi Produk",
                              hintStyle: TextStyle(
                                color: AppColor.textHint,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 8),

            // ==================== KATEGORI ====================
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  children: [
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.only(left: 16, right: 12),
                      leading: Icon(
                        Symbols.list,
                        color: AppColor.textPrimary,
                        size: 22,
                      ),
                      title: RichText(
                        text: TextSpan(
                          text: "Kategori ",
                          style: TextStyle(
                            color: AppColor.textPrimary,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: "*",
                              style: TextStyle(color: AppColor.error),
                            ),
                          ],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_selectedKategori != null)
                            Text(
                              _selectedKategori!,
                              style: TextStyle(
                                color: AppColor.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          SizedBox(width: 4),
                          Icon(
                            Symbols.chevron_right,
                            color: AppColor.textHint,
                            size: 20,
                          ),
                        ],
                      ),
                      onTap: () {
                        final List<String> kategoriList = [
                          "Elektronik & Gadget",
                          "Kamera & Fotografi",
                          "Pakaian & Kostum",
                          "Sepatu & Alas Kaki",
                          "Tas & Koper",
                          "Furniture & Rumah Tangga",
                          "Peralatan Pesta & Event",
                          "Olahraga & Outdoor",
                          "Hobi & Alat Musik",
                          "Buku & Mainan",
                          "Peralatan Bayi & Anak",
                          "Otomotif & Transportasi",
                          "Peralatan Tukang & Perkakas",
                          "Kesehatan & Medis",
                        ];

                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.white,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder: (context) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 12, bottom: 8),
                                    height: 4,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Pilih Kategori",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColor.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Divider(height: 1, color: AppColor.divider),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: kategoriList.length,
                                    itemBuilder: (context, index) {
                                      final item = kategoriList[index];
                                      return ListTile(
                                        title: Text(item),
                                        trailing: _selectedKategori == item
                                            ? Icon(
                                                Symbols.check,
                                                color: AppColor.primary,
                                              )
                                            : null,
                                        onTap: () {
                                          setState(() {
                                            _selectedKategori = item;
                                          });
                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  children: [
                    // ==================== HARGA / HARI ====================
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.only(left: 16, right: 12),
                      leading: Icon(
                        Symbols.sell,
                        color: AppColor.textPrimary,
                        size: 22,
                      ),
                      title: RichText(
                        text: TextSpan(
                          text: "Harga / hari ",
                          style: TextStyle(
                            color: AppColor.textPrimary,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: "*",
                              style: TextStyle(color: AppColor.error),
                            ),
                          ],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _hargaPerHari != null && _hargaPerHari!.isNotEmpty
                                ? "Rp ${formatRupiah(_hargaPerHari!)}"
                                : "Atur",
                            style: TextStyle(
                              color: AppColor.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          Icon(
                            Symbols.chevron_right,
                            color: AppColor.textHint,
                            size: 20,
                          ),
                        ],
                      ),
                      onTap: () {
                        _hargaController.text = _hargaPerHari ?? "";

                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.white,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder: (context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom +
                                    MediaQuery.of(context).padding.bottom +
                                    2,
                                left: 16,
                                right: 16,
                                top: 12,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 16),
                                      height: 4,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Atur Harga Sewa",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  TextField(
                                    controller: _hargaController,
                                    keyboardType: TextInputType.number,
                                    autofocus: true,
                                    style: TextStyle(fontSize: 16),
                                    onChanged: (value) {
                                      String formatted = formatRupiah(value);

                                      _hargaController.value = TextEditingValue(
                                        text: formatted,
                                        selection: TextSelection.collapsed(
                                          offset: formatted.length,
                                        ),
                                      );
                                    },
                                    decoration: InputDecoration(
                                      prefixText: "Rp ",
                                      prefixStyle: TextStyle(
                                        color: AppColor.textPrimary,
                                        fontSize: 16,
                                      ),
                                      hintText: "0",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: AppColor.border,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: AppColor.primary,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 24),

                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColor.primary,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          setState(() {
                                            _hargaPerHari = _hargaController
                                                .text
                                                .replaceAll(".", "");
                                          });
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "Simpan",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),

                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: AppColor.divider,
                    ),

                    // ==================== STOK ====================
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.only(left: 16, right: 16),
                      leading: Icon(
                        Symbols.layers,
                        color: AppColor.textPrimary,
                        size: 22,
                      ),
                      title: RichText(
                        text: TextSpan(
                          text: "Stok ",
                          style: TextStyle(
                            color: AppColor.textPrimary,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: "*",
                              style: TextStyle(color: AppColor.error),
                            ),
                          ],
                        ),
                      ),

                      trailing: SizedBox(
                        width: 60,
                        child: TextField(
                          controller: _stokController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: AppColor.textPrimary,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),

                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: AppColor.divider,
                    ),

                    // ==================== MIN. JUMLAH BARANG ====================
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.only(left: 16, right: 16),
                      leading: Icon(
                        Symbols.layers,
                        color: AppColor.textPrimary,
                        size: 22,
                      ),
                      title: RichText(
                        text: TextSpan(
                          text: "Min. Jumlah Peminjaman ",
                          style: TextStyle(
                            color: AppColor.textPrimary,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: "*",
                              style: TextStyle(color: AppColor.error),
                            ),
                          ],
                        ),
                      ),
                      trailing: SizedBox(
                        width: 60,
                        child: TextField(
                          controller: _jumlahPinjamController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: AppColor.textPrimary,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),

                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: AppColor.divider,
                    ),

                    // ==================== MAKS. HARI PEMINJAMAN ====================
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.only(left: 16, right: 16),
                      leading: Icon(
                        Symbols.layers,
                        color: AppColor.textPrimary,
                        size: 22,
                      ),
                      title: RichText(
                        text: TextSpan(
                          text: "Maks. Hari Peminjaman ",
                          style: TextStyle(
                            color: AppColor.textPrimary,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: "*",
                              style: TextStyle(color: AppColor.error),
                            ),
                          ],
                        ),
                      ),
                      trailing: SizedBox(
                        width: 60,
                        child: TextField(
                          controller: _hariPinjamController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: AppColor.textPrimary,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
          child: CustomButton(text: "Simpan", onPressed: _simpanProduk),
        ),
      ),
    );
  }
}

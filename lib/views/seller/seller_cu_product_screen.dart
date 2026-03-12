import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rentora_app/controllers/product_controller.dart';
import 'package:rentora_app/controllers/store_controller.dart';
import 'package:rentora_app/controllers/user_controller.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/core/utils/app_formatters.dart';
import 'package:rentora_app/models/product_model.dart';
import 'package:rentora_app/services/local_storage/preference_handler.dart';
import 'package:rentora_app/widgets/custom_button.dart';

class SellerCuProductScreen extends StatefulWidget {
  final ProductModel? produk;

  const SellerCuProductScreen({super.key, this.produk});

  @override
  State<SellerCuProductScreen> createState() => _SellerCuProductScreenState();
}

class _SellerCuProductScreenState extends State<SellerCuProductScreen> {
  final UserController _userController = UserController();
  final ProductController _productController = ProductController();
  final StoreController _storeController = StoreController();

  String? _selectedKategori;
  String? _hargaPerHari;
  String? _dendaPerHari;

  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _namaProdukController = TextEditingController();
  final TextEditingController _deskripsiProdukController =
      TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _dendaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController(
    text: "0",
  );
  final TextEditingController _jumlahPinjamController = TextEditingController(
    text: "1",
  );
  final TextEditingController _hariPinjamController = TextEditingController(
    text: "7",
  );

  bool _isSaving = false;
  int? _currentStoreId;

  // daftar kategori produk
  static const List<String> _kategoriList = [
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

  // Memilih gambar dan menyalin ke local storage aplikasi
  Future<void> _pickImage() async {
    if (_images.length >= 5) return;

    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage == null) return;

    File imageFile = File(pickedImage.path);
    File savedImage = await _saveImageToLocal(imageFile);

    setState(() {
      _images.add(savedImage);
    });
  }

  // Menghapus gambar dari daftar
  void _removeImage(File image) {
    setState(() {
      _images.remove(image);
    });
  }

  // Menyalin file gambar ke direktori aplikasi
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

  // Memuat data user saat ini dan store yang terkait
  Future<void> _loadCurrentUser() async {
    final email = await PreferenceHandler.getUserEmail();
    if (email == null) return;

    final user = await _userController.getCurrentUser();
    if (user == null) return;

    final store = await _storeController.getStoreByUserId(user.id!);
    if (store == null || !mounted) {
      return;
    }

    setState(() {
      _currentStoreId = store.id;
    });
  }

  // Menyimpan atau mengupdate produk
  Future<void> _simpanProduk() async {
    // Validasi input
    if (_images.isEmpty ||
        _namaProdukController.text.isEmpty ||
        _deskripsiProdukController.text.isEmpty ||
        _selectedKategori == null ||
        (_hargaPerHari == null || _hargaPerHari!.isEmpty) ||
        (_dendaPerHari == null || _dendaPerHari!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi semua data produk")),
      );
      return;
    }

    // Validasi store
    if (_currentStoreId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Profil toko tidak ditemukan. Silakan lengkapi profil toko Anda.",
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Buat objek ProductModel dari input user
      final produk = ProductModel(
        id: widget.produk?.id,
        storeId: _currentStoreId!,
        images: _images.map((e) => e.path).toList(),
        namaProduk: _namaProdukController.text,
        deskripsiProduk: _deskripsiProdukController.text,
        kategori: _selectedKategori!,
        hargaPerHari: int.tryParse(_hargaPerHari!.replaceAll(".", "")) ?? 0,
        dendaPerHari: int.tryParse(_dendaPerHari!.replaceAll(".", "")) ?? 0,
        stok: int.tryParse(_stokController.text) ?? 0,
        minJumlahPinjam: int.tryParse(_jumlahPinjamController.text) ?? 1,
        maxHariPinjam: int.tryParse(_hariPinjamController.text) ?? 7,
      );

      // Simpan atau update produk
      if (widget.produk != null) {
        await _productController.updateProduct(produk);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produk berhasil diupdate")),
        );
      } else {
        await _productController.addProduct(produk);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produk berhasil disimpan")),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terjadi kesalahan saat menyimpan produk"),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();

    // Jika widget.produk tidak null, masuk Mode Edit.
    if (widget.produk != null) {
      _namaProdukController.text = widget.produk!.namaProduk;
      _deskripsiProdukController.text = widget.produk!.deskripsiProduk;
      _selectedKategori = widget.produk!.kategori;
      _hargaPerHari = widget.produk!.hargaPerHari.toString();
      _dendaPerHari = widget.produk!.dendaPerHari.toString();
      _stokController.text = widget.produk!.stok.toString();
      _jumlahPinjamController.text = widget.produk!.minJumlahPinjam.toString();
      _hariPinjamController.text = widget.produk!.maxHariPinjam.toString();
      _images.addAll(widget.produk!.images.map((e) => File(e)));
    }
  }

  // Menampilkan modal untuk memilih kategori produk
  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColor.textHint,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

              const Divider(height: 1, color: AppColor.divider),

              Flexible(
                child: ListView.builder(
                  itemCount: _kategoriList.length,
                  itemBuilder: (context, index) {
                    final item = _kategoriList[index];
                    final isSelected = _selectedKategori == item;

                    return ListTile(
                      title: Text(item),
                      trailing: isSelected
                          ? const Icon(Symbols.check, color: AppColor.primary)
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
              ),
            ],
          ),
        );
      },
    );
  }

  // Menampilkan modal untuk mengatur harga sewa
  void _showPricePicker() {
    _hargaController.text = _hargaPerHari ?? "";
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                  margin: const EdgeInsets.only(bottom: 16),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColor.textHint,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              const Text(
                "Atur Harga Sewa",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(fontSize: 16),
                onChanged: (value) {
                  String formatted = AppFormatters.formatRupiah(value);
                  _hargaController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: formatted.length,
                    ),
                  );
                },
                decoration: InputDecoration(
                  prefixText: "Rp ",
                  prefixStyle: const TextStyle(
                    color: AppColor.textPrimary,
                    fontSize: 16,
                  ),
                  hintText: "0",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColor.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColor.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: AppColor.surface,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _hargaPerHari = _hargaController.text.replaceAll(".", "");
                    });
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Simpan",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // Menampilkan modal untuk mengatur denda keterlambatan
  void _showFinePicker() {
    _dendaController.text = _dendaPerHari ?? "";
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                  margin: const EdgeInsets.only(bottom: 16),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColor.textHint,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              const Text(
                "Atur Denda Keterlambatan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _dendaController,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(fontSize: 16),
                onChanged: (value) {
                  String formatted = AppFormatters.formatRupiah(value);
                  _dendaController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: formatted.length,
                    ),
                  );
                },
                decoration: InputDecoration(
                  prefixText: "Rp ",
                  prefixStyle: const TextStyle(
                    color: AppColor.textPrimary,
                    fontSize: 16,
                  ),
                  hintText: "0",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColor.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColor.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: AppColor.surface,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    final harga =
                        int.tryParse(
                          _hargaPerHari?.replaceAll(".", "") ?? "0",
                        ) ??
                        0;
                    final denda =
                        int.tryParse(
                          _dendaController.text.replaceAll(".", ""),
                        ) ??
                        0;

                    if (denda > harga * 0.5) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Denda tidak boleh melebihi 50% dari harga sewa.",
                          ),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _dendaPerHari = _dendaController.text.replaceAll(".", "");
                    });

                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Simpan",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: AppBar(
        toolbarHeight: 58,
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.textOnPrimary,
        title: const Text(
          "Tambah Produk",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Foto Produk, Nama, dan Deskripsi
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
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
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                ..._images.map((image) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10),
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
                                            onTap: () => _removeImage(image),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: AppColor.error,
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              child: const Icon(
                                                Icons.close,
                                                color: AppColor.surface,
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
                                      child: const Column(
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
                    const Divider(
                      height: 32,
                      indent: 16,
                      endIndent: 16,
                      color: AppColor.divider,
                    ),
                    _InfoProdukTextField(
                      controller: _namaProdukController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      label: "Nama Produk",
                      maxLength: 255,
                      hint: "Masukkan Nama Produk",
                    ),
                    const Divider(
                      height: 32,
                      indent: 16,
                      endIndent: 16,
                      color: AppColor.divider,
                    ),
                    _InfoProdukTextField(
                      controller: _deskripsiProdukController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      label: "Deskripsi Produk",
                      maxLength: 3000,
                      hint: "Masukkan Deskripsi Produk",
                      isMultiLine: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Pilihan Kategori
            Container(
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.only(left: 16, right: 12),
                  leading: const Icon(
                    Symbols.list,
                    color: AppColor.textPrimary,
                    size: 22,
                  ),
                  title: Row(
                    children: [
                      RichText(
                        text: const TextSpan(
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _selectedKategori ?? 'Pilih Kategori',
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: _selectedKategori != null
                                ? AppColor.textPrimary
                                : AppColor.textHint,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Symbols.chevron_right,
                    color: AppColor.textHint,
                    size: 20,
                  ),
                  onTap: _showCategoryPicker,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Harga, Stok, dan Aturan Peminjaman
            Container(
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  children: [
                    _OptionTile(
                      icon: Symbols.sell,
                      title: "Harga / hari",
                      value: _hargaPerHari != null && _hargaPerHari!.isNotEmpty
                          ? "Rp ${AppFormatters.formatRupiah(_hargaPerHari!)}"
                          : "Atur",
                      onTap: _showPricePicker,
                    ),
                    const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: AppColor.divider,
                    ),
                    _OptionTile(
                      icon: Symbols.payments,
                      title: "Denda Keterlambatan / hari",
                      value: _dendaPerHari != null && _dendaPerHari!.isNotEmpty
                          ? "Rp ${AppFormatters.formatRupiah(_dendaPerHari!)}"
                          : "Atur",
                      onTap: _showFinePicker,
                    ),
                    const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: AppColor.divider,
                    ),
                    _NumericInputTile(
                      icon: Symbols.layers,
                      title: "Stok",
                      controller: _stokController,
                    ),
                    const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: AppColor.divider,
                    ),
                    _NumericInputTile(
                      icon: Symbols.layers,
                      title: "Min. Jumlah Peminjaman",
                      controller: _jumlahPinjamController,
                    ),
                    const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: AppColor.divider,
                    ),
                    _NumericInputTile(
                      icon: Symbols.layers,
                      title: "Maks. Hari Peminjaman",
                      controller: _hariPinjamController,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Tombol Simpan
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColor.surface,
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowMedium,
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: CustomButton(
            text: "Simpan",
            onPressed: _simpanProduk,
            isLoading: _isSaving,
          ),
        ),
      ),
    );
  }
}

// TextField
class _InfoProdukTextField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String label;
  final int maxLength;
  final String hint;
  final bool isMultiLine;

  const _InfoProdukTextField({
    required this.controller,
    required this.onChanged,
    required this.label,
    required this.maxLength,
    required this.hint,
    this.isMultiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  text: "$label ",
                  style: const TextStyle(
                    color: AppColor.textPrimary,
                    fontSize: 14,
                  ),
                  children: const [
                    TextSpan(
                      text: "*",
                      style: TextStyle(color: AppColor.error),
                    ),
                  ],
                ),
              ),
              Text(
                "${controller.text.length}/$maxLength",
                style: const TextStyle(color: AppColor.textHint, fontSize: 12),
              ),
            ],
          ),
          TextField(
            controller: controller,
            maxLength: maxLength,
            maxLines: isMultiLine ? null : 1,
            keyboardType: isMultiLine
                ? TextInputType.multiline
                : TextInputType.text,
            onChanged: onChanged,
            decoration: InputDecoration(
              counterText: "",
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColor.textHint,
                fontSize: 14,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}

// Tile untuk menampilkan opsi Harga/Denda
class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.only(left: 16, right: 12),
      leading: Icon(icon, color: AppColor.textPrimary, size: 22),
      title: RichText(
        text: TextSpan(
          text: "$title ",
          style: const TextStyle(color: AppColor.textPrimary, fontSize: 14),
          children: const [
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
            value,
            style: const TextStyle(color: AppColor.textPrimary, fontSize: 14),
          ),
          const Icon(Symbols.chevron_right, color: AppColor.textHint, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}

// Tile input angka langsung di baris
class _NumericInputTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final TextEditingController controller;

  const _NumericInputTile({
    required this.icon,
    required this.title,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.only(left: 16, right: 16),
      leading: Icon(icon, color: AppColor.textPrimary, size: 22),
      title: RichText(
        text: TextSpan(
          text: "$title ",
          style: const TextStyle(color: AppColor.textPrimary, fontSize: 14),
          children: const [
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
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.end,
          style: const TextStyle(color: AppColor.textPrimary, fontSize: 14),
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}

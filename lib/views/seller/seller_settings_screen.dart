import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/controllers/store_controller.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/widgets/custom_text_field.dart';

class SellerSettingsScreen extends StatefulWidget {
  const SellerSettingsScreen({super.key});

  @override
  State<SellerSettingsScreen> createState() => _SellerSettingsScreenState();
}

class _SellerSettingsScreenState extends State<SellerSettingsScreen> {
  final _storeController = StoreController();

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  final _imagePicker = ImagePicker();

  String? _imageUrl; // url gambar di Firebase Storage

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Memuat data toko
  Future<void> _loadStoreData() async {
    setState(() => _isLoading = true);
    try {
      final store = await _storeController.getStore();
      if (store != null) {
        _nameController.text = store.name;
        _locationController.text = store.location ?? '';
        if (store.image != null && store.image!.isNotEmpty) {
          _imageUrl = store.image;
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Membuka galeri, kompres, dan upload gambar ke Firebase Storage
  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _isLoading = true);
      try {
        // Kompres gambar
        final compressed = await FlutterImageCompress.compressWithFile(
          pickedFile.path,
          minWidth: 800,
          minHeight: 800,
          quality: 75,
        );
        if (compressed == null) throw Exception('Gagal kompres gambar');

        // Upload ke Firebase Storage
        final ref = FirebaseStorage.instance.ref().child(
          'store_profile/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await ref.putData(compressed);
        final url = await ref.getDownloadURL();

        setState(() {
          _imageUrl = url;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal upload gambar: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // Menyimpan data toko yang telah diubah
  Future<void> _saveStore() async {
    if (_nameController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama toko tidak boleh kosong')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Ambil url lama jika tidak ada upload baru
      String? imageToSave = _imageUrl;
      if ((imageToSave == null || imageToSave.isEmpty)) {
        final store = await _storeController.getStore();
        if (store != null && store.image != null && store.image!.isNotEmpty) {
          imageToSave = store.image;
        }
      }
      await _storeController.saveStore(
        name: _nameController.text,
        location: _locationController.text,
        image: imageToSave,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengaturan toko berhasil disimpan')),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: AppBar(
        toolbarHeight: 58,
        elevation: 0,
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.textOnPrimary,
        title: const Text(
          "Pengaturan Toko",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- PROFILE PICTURE SECTION ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColor.border),
                boxShadow: const [
                  BoxShadow(
                    color: AppColor.shadowLight,
                    blurRadius: 14,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColor.primarySoft,
                          backgroundImage: (_imageUrl ?? '').isNotEmpty
                              ? NetworkImage(_imageUrl!) as ImageProvider
                              : null,
                          child: (_imageUrl ?? '').isEmpty
                              ? const Icon(
                                  Symbols.storefront,
                                  size: 50,
                                  color: AppColor.secondary,
                                  weight: 650,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: -4,
                          right: -4,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _pickImage,
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColor.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColor.surface,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(18),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Symbols.photo_camera,
                                    color: AppColor.textOnPrimary,
                                    size: 18,
                                    weight: 700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Foto Profil Toko',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColor.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // --- STORE INFO SECTION ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColor.border),
                boxShadow: const [
                  BoxShadow(
                    color: AppColor.shadowLight,
                    blurRadius: 14,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Toko',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Lengkapi data toko Anda untuk tampil lebih profesional',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _nameController,
                    hintText: 'Nama Toko',
                    prefixIcon: Symbols.storefront,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _locationController,
                    hintText: 'Lokasi',
                    prefixIcon: Symbols.location_on,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
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
          child: ElevatedButton(
            onPressed: _saveStore,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: AppColor.textOnPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 2,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColor.textOnPrimary,
                      ),
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'Simpan Pengaturan',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ),
    );
  }
}

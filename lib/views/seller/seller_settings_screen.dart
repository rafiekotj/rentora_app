import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/controllers/store_controller.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/widgets/custom_text_field.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class SellerSettingsScreen extends StatefulWidget {
  const SellerSettingsScreen({super.key});

  @override
  State<SellerSettingsScreen> createState() => _SellerSettingsScreenState();
}

class _SellerSettingsScreenState extends State<SellerSettingsScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLatLng;
  bool _isMapReady = false;
  bool isMapSectionLoading = false;
  final _storeController = StoreController();

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  String? _address;
  String? _province;
  String? _city;
  String? _district;
  String? _postalCode;
  double? _latitude;
  double? _longitude;

  // Update alamat berdasarkan koordinat
  Future<void> _updateAddressFromLatLng(LatLng latLng) async {
    if (mounted) setState(() => isMapSectionLoading = true);
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (!mounted) return;
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final address = [
          p.street,
          p.subLocality,
          p.locality,
          p.subAdministrativeArea,
          p.administrativeArea,
          p.postalCode,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
        if (mounted) {
          setState(() {
            _address = address;
            _locationController.text = address;
            _province = p.administrativeArea;
            _city = p.locality;
            _district = p.subAdministrativeArea;
            _postalCode = p.postalCode;
            _latitude = latLng.latitude;
            _longitude = latLng.longitude;
            _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _address = null;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _address = null;
        });
      }
    } finally {
      if (mounted) setState(() => isMapSectionLoading = false);
    }
  }

  // Mendapatkan lokasi saat ini
  // Mendapatkan lokasi saat ini
  Future<void> _getCurrentLocation() async {
    if (mounted) setState(() => isMapSectionLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
      });
      if (_currentLatLng != null) {
        await _updateAddressFromLatLng(_currentLatLng!);
      }
    } finally {
      if (mounted) setState(() => isMapSectionLoading = false);
    }
  }

  final _imagePicker = ImagePicker();

  String? _imageUrl; // url gambar di Firebase Storage

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStoreData();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Memuat data toko
  // Memuat data toko
  Future<void> _loadStoreData() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final store = await _storeController.getStore();
      if (!mounted) return;
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
  // Ambil gambar dari galeri, kompres, dan upload ke storage
  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;
    if (mounted) setState(() => _isLoading = true);
    try {
      final compressed = await FlutterImageCompress.compressWithFile(
        pickedFile.path,
        minWidth: 800,
        minHeight: 800,
        quality: 75,
      );
      if (compressed == null) throw Exception('Gagal kompres gambar');
      final ref = FirebaseStorage.instance.ref().child(
        'store_profile/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await ref.putData(compressed);
      final url = await ref.getDownloadURL();
      if (mounted) {
        setState(() {
          _imageUrl = url;
        });
      }
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

  // Menyimpan data toko yang telah diubah
  // Simpan data toko
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
        province: _province,
        city: _city,
        district: _district,
        postalCode: _postalCode,
        fullAddress: _address,
        latitude: _latitude,
        longitude: _longitude,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengaturan toko berhasil disimpan')),
      );
      Navigator.of(context).pop();
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
    final theme = Theme.of(context);
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

                  // --- GOOGLE MAP SECTION ---
                  if (_currentLatLng != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            SizedBox(
                              height: 220,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: _currentLatLng!,
                                    zoom: 16,
                                  ),
                                  myLocationEnabled: true,
                                  myLocationButtonEnabled: true,
                                  zoomGesturesEnabled: true,
                                  onMapCreated: (controller) {
                                    _mapController = controller;
                                    if (mounted && !_isMapReady) {
                                      setState(() {
                                        _isMapReady = true;
                                      });
                                    }
                                  },
                                  markers: {
                                    Marker(
                                      markerId: const MarkerId(
                                        'current_location',
                                      ),
                                      position: _currentLatLng!,
                                      draggable: true,
                                      onDragEnd: (newPos) async {
                                        if (mounted) {
                                          setState(() {
                                            _currentLatLng = newPos;
                                          });
                                        }
                                        await _updateAddressFromLatLng(newPos);
                                      },
                                    ),
                                  },
                                  onTap: (latLng) async {
                                    if (mounted) {
                                      setState(() {
                                        _currentLatLng = latLng;
                                      });
                                    }
                                    await _updateAddressFromLatLng(latLng);
                                  },
                                ),
                              ),
                            ),
                            if (isMapSectionLoading)
                              Positioned.fill(
                                child: ColoredBox(
                                  color: theme.colorScheme.surface.withAlpha(
                                    115,
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColor.primary,
                                      strokeWidth: 3.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_address != null && _address!.isNotEmpty)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: AppColor.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _address!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColor.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  if (_currentLatLng == null)
                    Container(
                      height: 220,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
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

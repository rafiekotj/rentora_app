import 'package:rentora_app/controllers/user_controller.dart';
import 'package:rentora_app/models/store_model.dart';
import 'package:rentora_app/services/database/store_service.dart';

class StoreController {
  final StoreService _storeService = StoreService();
  // Cache sederhana in-memory per instance untuk mengurangi panggilan Firestore berulang
  final Map<String, StoreModel> _cache = {};

  // Mengambil beberapa toko berdasarkan daftar ID (Firestore pakai String ID)
  Future<List<StoreModel>> getStoresByIds(List<String> storeIds) async {
    // Ambil terlebih dahulu dari cache, dan hanya minta yang belum ada.
    final ids = storeIds.where((id) => id.isNotEmpty).toList();
    if (ids.isEmpty) return [];

    final missing = <String>[];
    final results = <StoreModel>[];
    for (final id in ids) {
      final cached = _cache[id];
      if (cached != null) {
        results.add(cached);
      } else {
        missing.add(id);
      }
    }

    if (missing.isNotEmpty) {
      final fetched = await _storeService.getStoresByIds(missing);
      for (final s in fetched) {
        _cache[s.uid] = s;
      }
      results.addAll(fetched);
    }

    return results;
  }

  // Mengambil semua toko yang dimiliki oleh seorang user berdasarkan userId (Firestore pakai String userId)
  Future<List<StoreModel>> getStoresByUser(String userId) async {
    return await _storeService.getStoresByUser(userId);
  }

  // Mengambil data satu toko berdasarkan ID toko
  Future<StoreModel?> getStoreById(String storeId) async {
    if (storeId.isEmpty) return null;
    final cached = _cache[storeId];
    if (cached != null) return cached;
    final store = await _storeService.getStoreById(storeId);
    if (store != null) _cache[storeId] = store;
    return store;
  }

  // Mengambil data satu toko berdasarkan ID user yang memiliki toko tersebut
  Future<StoreModel?> getStoreByUserId(String userId) async {
    final store = await _storeService.getStoreByUserId(userId);
    if (store != null) _cache[store.uid] = store;
    return store;
  }

  // Mengambil data toko milik user yang sedang login saat ini
  Future<StoreModel?> getStore() async {
    final userController = UserController();
    final user = await userController.getCurrentUser();
    if (user == null) return null;
    return await getStoreByUserId(user.uid);
  }

  // Menyimpan data toko untuk user yang sedang login
  Future<void> saveStore({
    required String name,
    String? location,
    String? image,
    String? province,
    String? city,
    String? district,
    String? postalCode,
    String? fullAddress,
    double? latitude,
    double? longitude,
  }) async {
    final userController = UserController();
    final user = await userController.getCurrentUser();
    if (user == null) {
      throw Exception('User belum login');
    }
    await _storeService.saveStore(
      userUid: user.uid,
      name: name,
      location: location,
      image: image,
      province: province,
      city: city,
      district: district,
      postalCode: postalCode,
      fullAddress: fullAddress,
      latitude: latitude,
      longitude: longitude,
    );
  }
}

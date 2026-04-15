import 'package:rentora_app/controllers/user_controller.dart';
import 'package:rentora_app/models/store_model.dart';
import 'package:rentora_app/services/database/store_service.dart';

class StoreController {
  final StoreService _storeService = StoreService();

  // Mengambil beberapa toko berdasarkan daftar ID (Firestore pakai String ID)
  Future<List<StoreModel>> getStoresByIds(List<String> storeIds) async {
    return await _storeService.getStoresByIds(storeIds);
  }

  // Mengambil semua toko yang dimiliki oleh seorang user berdasarkan userId (Firestore pakai String userId)
  Future<List<StoreModel>> getStoresByUser(String userId) async {
    return await _storeService.getStoresByUser(userId);
  }

  // Mengambil data satu toko berdasarkan ID toko
  Future<StoreModel?> getStoreById(String storeId) async {
    return await _storeService.getStoreById(storeId);
  }

  // Mengambil data satu toko berdasarkan ID user yang memiliki toko tersebut
  Future<StoreModel?> getStoreByUserId(String userId) async {
    return await _storeService.getStoreByUserId(userId);
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
    );
  }
}

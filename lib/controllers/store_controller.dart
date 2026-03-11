import 'package:rentora_app/controllers/user_controller.dart';
import 'package:rentora_app/models/store_model.dart';
import 'package:rentora_app/services/database/sqflite.dart';

class StoreController {
  // Mengambil beberapa toko berdasarkan daftar ID
  Future<Map<int, StoreModel>> getStoresByIds(List<int> storeIds) async {
    if (storeIds.isEmpty) {
      return {};
    }

    final db = await DBHelper.database();
    final placeholders = ('?' * storeIds.length).split('').join(',');

    final result = await db.query(
      'stores',
      where: 'id IN ($placeholders)',
      whereArgs: storeIds,
    );

    if (result.isNotEmpty) {
      return {for (var e in result) e['id'] as int: StoreModel.fromMap(e)};
    }

    return {};
  }

  // Mengambil semua toko yang dimiliki oleh seorang user berdasarkan userId
  Future<List<StoreModel>> getStoresByUser(int userId) async {
    final db = await DBHelper.database();

    final result = await db.query(
      'stores',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return result.map((e) => StoreModel.fromMap(e)).toList();
  }

  // Mengambil data satu toko berdasarkan ID toko
  Future<StoreModel?> getStoreById(int storeId) async {
    final db = await DBHelper.database();

    final result = await db.query(
      'stores',
      where: 'id = ?',
      whereArgs: [storeId],
    );
    if (result.isNotEmpty) {
      return StoreModel.fromMap(result.first);
    }
    return null;
  }

  // Mengambil data satu toko berdasarkan ID user yang memiliki toko tersebut
  Future<StoreModel?> getStoreByUserId(int userId) async {
    final db = await DBHelper.database();

    final result = await db.query(
      'stores',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      return StoreModel.fromMap(result.first);
    }

    return null;
  }

  // Mengambil data toko milik user yang sedang login saat ini
  Future<StoreModel?> getStore() async {
    final userController = UserController();
    final user = await userController.getCurrentUser();

    if (user == null) return null;

    return await getStoreByUserId(user.id!);
  }

  // Menyimpan data toko untuk user yang sedang login
  Future<void> saveStore({
    required String name,
    String? location,
    String? image,
  }) async {
    final db = await DBHelper.database();

    final userController = UserController();
    final user = await userController.getCurrentUser();

    if (user == null) {
      throw Exception('User belum login');
    }

    // cek apakah store sudah ada
    final existingStore = await getStoreByUserId(user.id!);

    if (existingStore != null) {
      await db.update(
        'stores',
        {'name': name, 'location': location, 'image': image},
        where: 'userId = ?',
        whereArgs: [user.id],
      );
    } else {
      await db.insert('stores', {
        'userId': user.id,
        'name': name,
        'location': location,
        'image': image,
      });
    }
  }
}

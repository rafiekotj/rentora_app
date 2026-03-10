import 'package:rentora_app/controllers/user_controller.dart';
import 'package:rentora_app/models/store_model.dart';
import 'package:rentora_app/services/database/sqflite.dart';

class StoreController {
  Future<int> createStore(StoreModel store) async {
    final db = await DBHelper.database();

    return await db.insert('stores', store.toMap());
  }

  Future<List<StoreModel>> getStoresByUser(int userId) async {
    final db = await DBHelper.database();

    final result = await db.query(
      'stores',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return result.map((e) => StoreModel.fromMap(e)).toList();
  }

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

  Future<StoreModel?> getStore() async {
    final userController = UserController();
    final user = await userController.getCurrentUser();

    if (user == null) return null;

    return await getStoreByUserId(user.id!);
  }

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
      // update store
      await db.update(
        'stores',
        {'name': name, 'location': location, 'image': image},
        where: 'userId = ?',
        whereArgs: [user.id],
      );
    } else {
      // insert store baru
      await db.insert('stores', {
        'userId': user.id,
        'name': name,
        'location': location,
        'image': image,
      });
    }
  }
}

import 'package:rentora_app/models/store_model.dart';
import 'package:rentora_app/models/user_model.dart';
import 'package:rentora_app/services/database/db_helper.dart';
import 'package:rentora_app/services/local_storage/preference_handler.dart';

class StoreController {
  Future<UserModel?> _getCurrentUser() async {
    final email = await PreferenceHandler.getUserEmail();
    if (email == null) {
      return null;
    }
    return await DBHelper.getUserByEmail(email);
  }

  Future<StoreModel?> getStore() async {
    final user = await _getCurrentUser();
    if (user == null || user.id == null) {
      return null;
    }
    return await DBHelper.getStoreByUserId(user.id!);
  }

  Future<void> saveStore({
    required String name,
    String? location,
    String? image,
  }) async {
    final user = await _getCurrentUser();
    if (user == null || user.id == null) {
      throw Exception("User not found, cannot save store.");
    }

    final existingStore = await getStore();

    if (existingStore != null) {
      final updatedStore = StoreModel(
        id: existingStore.id,
        userId: user.id!,
        name: name,
        location: location ?? existingStore.location,
        image: image ?? existingStore.image,
      );
      await DBHelper.updateStore(updatedStore);
    } else {
      final newStore = StoreModel(
        userId: user.id!,
        name: name,
        location: location,
        image: image,
      );
      await DBHelper.saveStore(newStore);
    }
  }
}

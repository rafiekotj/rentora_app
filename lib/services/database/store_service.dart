import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentora_app/models/store_model.dart';

class StoreService {
  final CollectionReference storesCollection = FirebaseFirestore.instance
      .collection('stores');

  Future<List<StoreModel>> getStoresByIds(List<String> storeIds) async {
    // Filter: hanya id yang tidak kosong dan unik
    final filteredIds = storeIds.where((id) => id.isNotEmpty).toSet().toList();
    if (filteredIds.isEmpty) return [];
    final snapshot = await storesCollection
        .where(FieldPath.documentId, whereIn: filteredIds)
        .get();
    return snapshot.docs
        .map((doc) => StoreModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<StoreModel>> getStoresByUser(String userUid) async {
    final snapshot = await storesCollection
        .where('userUid', isEqualTo: userUid)
        .get();
    return snapshot.docs
        .map((doc) => StoreModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<StoreModel?> getStoreById(String storeId) async {
    final doc = await storesCollection.doc(storeId).get();
    if (doc.exists) {
      return StoreModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<StoreModel?> getStoreByUserId(String userUid) async {
    final snapshot = await storesCollection
        .where('userUid', isEqualTo: userUid)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return StoreModel.fromMap(
        snapshot.docs.first.data() as Map<String, dynamic>,
      );
    }
    return null;
  }

  Future<void> saveStore({
    required String userUid,
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
    final data = {
      'userUid': userUid,
      'name': name,
      'location': location,
      'image': image,
      'province': province,
      'city': city,
      'district': district,
      'postalCode': postalCode,
      'fullAddress': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
    };
    final snapshot = await storesCollection
        .where('userUid', isEqualTo: userUid)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      final docId = snapshot.docs.first.id;
      await storesCollection.doc(docId).update({
        ...data,
        'uid': docId, // pastikan field uid selalu terisi
      });
    } else {
      final docRef = await storesCollection.add(data);
      // update field uid setelah dokumen berhasil dibuat
      await storesCollection.doc(docRef.id).update({'uid': docRef.id});
    }
  }
}

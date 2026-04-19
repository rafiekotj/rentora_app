import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentora_app/models/store_model.dart';

class StoreService {
  final CollectionReference storesCollection = FirebaseFirestore.instance
      .collection('stores');

  Future<List<StoreModel>> getStoresByIds(List<String> storeIds) async {
    final filteredIds = storeIds.where((id) => id.isNotEmpty).toSet().toList();
    if (filteredIds.isEmpty) return [];

    const int chunkSize = 10;
    final chunks = <List<String>>[];
    for (var i = 0; i < filteredIds.length; i += chunkSize) {
      chunks.add(
        filteredIds.sublist(
          i,
          i + chunkSize > filteredIds.length
              ? filteredIds.length
              : i + chunkSize,
        ),
      );
    }

    final futures = chunks.map((c) async {
      final snapshot = await storesCollection
          .where(FieldPath.documentId, whereIn: c)
          .get();
      return snapshot.docs
          .map((doc) => StoreModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });

    final results = await Future.wait(futures);
    return results.expand((r) => r).toList();
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
      await storesCollection.doc(docId).update({...data, 'uid': docId});
    } else {
      final docRef = await storesCollection.add(data);
      await storesCollection.doc(docRef.id).update({'uid': docRef.id});
    }
  }
}

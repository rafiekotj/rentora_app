import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentora_app/models/product_model.dart';

class ProductService {
  final CollectionReference productsCollection = FirebaseFirestore.instance
      .collection('products');

  Future<String> addProduct(ProductModel product) async {
    final docRef = await productsCollection.add(product.toMap());
    return docRef.id;
  }

  Future<void> updateProduct(String productId, ProductModel product) async {
    await productsCollection.doc(productId).update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await productsCollection.doc(productId).delete();
  }

  Future<List<ProductModel>> getProductsByStore(String storeUid) async {
    final snapshot = await productsCollection
        .where('storeUid', isEqualTo: storeUid)
        .get();
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProductModel>> getProductByKategori(String kategori) async {
    final snapshot = await productsCollection
        .where('kategori', isEqualTo: kategori)
        .get();
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProductModel>> getAllProduct() async {
    final snapshot = await productsCollection.get();
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}

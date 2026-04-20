import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentora_app/models/product_model.dart';

class ProductService {
  final CollectionReference productsCollection = FirebaseFirestore.instance
      .collection('products');

  Future<String> addProduct(ProductModel product) async {
    // Tambah produk baru ke database
    final docRef = await productsCollection.add(product.toMap());
    return docRef.id;
  }

  Future<void> updateProduct(String productId, ProductModel product) async {
    // Update data produk berdasarkan id
    await productsCollection.doc(productId).update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    // Hapus produk berdasarkan id
    await productsCollection.doc(productId).delete();
  }

  Future<List<ProductModel>> getProductsByStore(String storeUid) async {
    // Ambil semua produk milik store tertentu
    final snapshot = await productsCollection
        .where('storeUid', isEqualTo: storeUid)
        .get(const GetOptions(source: Source.serverAndCache));
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProductModel>> getProductByKategori(String kategori) async {
    // Ambil produk berdasarkan kategori
    final snapshot = await productsCollection
        .where('kategori', isEqualTo: kategori)
        .get(const GetOptions(source: Source.serverAndCache));
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProductModel>> getAllProduct() async {
    // Ambil semua produk
    final snapshot = await productsCollection.get(
      const GetOptions(source: Source.serverAndCache),
    );
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}

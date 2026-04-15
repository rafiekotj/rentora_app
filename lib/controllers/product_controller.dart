import 'package:rentora_app/controllers/store_controller.dart';
import 'package:rentora_app/models/product_model.dart';
import 'package:rentora_app/services/database/product_service.dart';

class ProductController {
  final _storeController = StoreController();
  final _productService = ProductService();

  // Menambahkan produk baru ke Firestore
  Future<String> addProduct(ProductModel product) async {
    return await _productService.addProduct(product);
  }

  // Memperbarui data produk di Firestore
  Future<void> updateProduct(String productId, ProductModel product) async {
    await _productService.updateProduct(productId, product);
  }

  // Menghapus produk dari Firestore
  Future<void> deleteProduct(String productId) async {
    await _productService.deleteProduct(productId);
  }

  // Mengambil produk toko saat ini
  Future<List<ProductModel>> getMyProducts() async {
    final store = await _storeController.getStore();
    if (store == null) {
      return [];
    }
    return await _productService.getProductsByStore(store.uid);
  }

  // Mengambil daftar produk berdasarkan kategori tertentu
  Future<List<ProductModel>> getProductByKategori(String kategori) async {
    return await _productService.getProductByKategori(kategori);
  }

  // Mengambil semua produk
  Future<List<ProductModel>> getAllProduct() async {
    return await _productService.getAllProduct();
  }
}

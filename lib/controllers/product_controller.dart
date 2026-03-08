import 'package:rentora_app/models/product_model.dart';
import 'package:rentora_app/services/database/db_helper.dart';

class ProductController {
  // Get all products
  Future<List<ProductModel>> getProducts() async {
    return await DBHelper.getAllProduk();
  }

  // Add a new product
  Future<void> addProduct(ProductModel produk) async {
    await DBHelper.insertProduk(produk);
  }

  // Update an existing product
  Future<void> updateProduct(ProductModel produk) async {
    await DBHelper.updateProduk(produk);
  }

  // Delete a product
  Future<void> deleteProduct(int id) async {
    await DBHelper.deleteProduk(id);
  }
}

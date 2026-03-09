import 'package:rentora_app/models/product_model.dart';
import 'package:rentora_app/services/database/db_helper.dart';

class ProductController {
  Future<List<ProductModel>> getProducts() async {
    return await DBHelper.getAllProduk();
  }

  Future<void> addProduct(ProductModel produk) async {
    await DBHelper.insertProduk(produk);
  }

  Future<void> updateProduct(ProductModel produk) async {
    await DBHelper.updateProduk(produk);
  }

  Future<void> deleteProduct(int id) async {
    await DBHelper.deleteProduk(id);
  }
}

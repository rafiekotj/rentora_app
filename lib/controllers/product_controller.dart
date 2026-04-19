import 'package:rentora_app/controllers/store_controller.dart';
import 'package:rentora_app/models/product_model.dart';
import 'package:rentora_app/services/database/product_service.dart';

class ProductController {
  final _storeController = StoreController();
  final _productService = ProductService();

  Future<String> addProduct(ProductModel product) async {
    return await _productService.addProduct(product);
  }

  Future<void> updateProduct(String productId, ProductModel product) async {
    await _productService.updateProduct(productId, product);
  }

  Future<void> deleteProduct(String productId) async {
    await _productService.deleteProduct(productId);
  }

  Future<List<ProductModel>> getMyProducts() async {
    final store = await _storeController.getStore();
    if (store == null) {
      return [];
    }
    return await _productService.getProductsByStore(store.uid);
  }

  Future<List<ProductModel>> getProductByKategori(String kategori) async {
    return await _productService.getProductByKategori(kategori);
  }

  Future<List<ProductModel>> getAllProduct() async {
    return await _productService.getAllProduct();
  }
}

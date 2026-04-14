import 'package:rentora_app/controllers/store_controller.dart';
import 'package:rentora_app/models/product_model.dart';

class ProductController {
  // final _storeController = StoreController();

  // // Menambahkan produk baru ke database
  // Future<int> addProduct(ProductModel product) async {
  //   final db = await DBHelper.database();

  //   return await db.insert('product', product.toMap());
  // }

  // // Memperbarui data produk yang ada di database
  // Future<int> updateProduct(ProductModel product) async {
  //   final db = await DBHelper.database();

  //   return await db.update(
  //     'product',
  //     product.toMap(),
  //     where: 'id = ?',
  //     whereArgs: [product.id],
  //   );
  // }

  // // Menghapus produk dari database
  // Future<void> deleteProduct(int productId) async {
  //   await DBHelper.deleteProduk(productId);
  // }

  // // Mengambil produk toko saat ini
  // Future<List<ProductModel>> getMyProducts() async {
  //   final store = await _storeController.getStore();
  //   if (store == null) {
  //     return [];
  //   }
  //   return await DBHelper.getProdukByStore(store.id!);
  // }

  // // Mengambil daftar produk dari database berdasarkan kategori tertentu
  // Future<List<ProductModel>> getProductByKategori(String kategori) async {
  //   final db = await DBHelper.database();

  //   final result = await db.query(
  //     'product',
  //     where: 'kategori = ?',
  //     whereArgs: [kategori],
  //   );

  //   return result.map((e) => ProductModel.fromMap(e)).toList();
  // }

  // // Mengambil semua produk yang ada dari database
  // Future<List<ProductModel>> getAllProduct() async {
  //   final db = await DBHelper.database();

  //   final result = await db.query('product');

  //   return result.map((e) => ProductModel.fromMap(e)).toList();
  // }
}

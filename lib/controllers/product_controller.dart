import 'package:rentora_app/models/product_model.dart';
import 'package:rentora_app/services/database/sqflite.dart';

class ProductController {
  Future<int> addProduct(ProductModel product) async {
    final db = await DBHelper.database();

    return await db.insert('product', product.toMap());
  }

  Future<int> updateProduct(ProductModel product) async {
    final db = await DBHelper.database();

    return await db.update(
      'product',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<List<ProductModel>> getProductByUser(int userId) async {
    final db = await DBHelper.database();

    final result = await db.query(
      'product',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return result.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<List<ProductModel>> getProductByKategori(String kategori) async {
    final db = await DBHelper.database();

    final result = await db.query(
      'product',
      where: 'kategori = ?',
      whereArgs: [kategori],
    );

    return result.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<void> deleteProduct(int id) async {
    final db = await DBHelper.database();

    await db.delete('product', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ProductModel>> getAllProduct() async {
    final db = await DBHelper.database();

    final result = await db.query('product');

    return result.map((e) => ProductModel.fromMap(e)).toList();
  }
}

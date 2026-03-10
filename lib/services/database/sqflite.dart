import 'package:rentora_app/models/cart_model.dart';
import 'package:rentora_app/models/product_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:rentora_app/models/user_model.dart';

class DBHelper {
  // Membuka atau membuat database
  static Future<Database> database() async {
    final dbPath = await getDatabasesPath();

    return await openDatabase(
      join(dbPath, 'rentora.db'),
      version: 1,

      // Dijalankan saat database pertama kali dibuat
      onCreate: (db, version) async {
        // ==========================
        // TABLE USER
        // ==========================
        await db.execute('''
        CREATE TABLE user(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT UNIQUE,
          password TEXT,
          phone TEXT
        )
        ''');

        // ==========================
        // TABLE PRODUK
        // ==========================
        await db.execute('''
        CREATE TABLE product (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          storeId INTEGER,
          images TEXT,
          namaProduk TEXT,
          deskripsiProduk TEXT,
          kategori TEXT,
          hargaPerHari INTEGER,
          dendaPerHari INTEGER,
          stok INTEGER,
          minJumlahPinjam INTEGER,
          maxHariPinjam INTEGER,
          FOREIGN KEY (storeId) REFERENCES stores(id)
        )
        ''');

        // ==========================
        // TABLE STORES
        // ==========================
        await db.execute('''
        CREATE TABLE stores (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          name TEXT NOT NULL,
          image TEXT,
          location TEXT,
          FOREIGN KEY (userId) REFERENCES user(id)
        )
        ''');

        // ==========================
        // TABLE CART
        // ==========================
        await db.execute('''
        CREATE TABLE cart (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          product_id INTEGER,
          store_id INTEGER,
          quantity INTEGER,
          rental_days INTEGER,
          product_data TEXT,
          FOREIGN KEY (product_id) REFERENCES product(id),
          FOREIGN KEY (store_id) REFERENCES stores(id)
        )
        ''');
      },
    );
  }

  // ===============================
  // FUNGSI UNTUK USER
  // ===============================

  // Menyimpan user baru ke database saat registrasi
  static Future<int> registerUser(UserModel user) async {
    final db = await database();

    return await db.insert('user', user.toMap());
  }

  // Memverifikasi user dari database saat login
  static Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    final db = await database();

    final result = await db.query(
      'user',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }

    return null;
  }

  // ===============================
  // FUNGSI UNTUK PRODUK
  // ===============================

  // Mengambil semua produk berdasarkan ID toko
  static Future<List<ProductModel>> getProdukByStore(int storeId) async {
    final db = await database();

    final result = await db.query(
      'product',
      where: 'storeId = ?',
      whereArgs: [storeId],
    );

    return result.map((e) => ProductModel.fromMap(e)).toList();
  }

  // Menghapus produk dari database berdasarkan ID
  static Future<void> deleteProduk(int id) async {
    final db = await database();

    await db.delete('product', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================
  // FUNGSI UNTUK KERANJANG (CART)
  // ==========================

  // Menambahkan item baru ke keranjang
  static Future<int> insertCart(CartModel cart) async {
    final db = await database();
    return await db.insert(
      'cart',
      cart.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Memperbarui item yang ada di keranjang
  static Future<int> updateCart(CartModel cart) async {
    final db = await database();
    return await db.update(
      'cart',
      cart.toMap(),
      where: 'id = ?',
      whereArgs: [cart.id],
    );
  }

  // Menghapus satu item dari keranjang berdasarkan ID
  static Future<int> deleteCart(int id) async {
    final db = await database();
    return await db.delete('cart', where: 'id = ?', whereArgs: [id]);
  }

  // Menghapus semua item dari keranjang
  static Future<int> clearCart() async {
    final db = await database();
    return await db.delete('cart');
  }

  // Mengambil semua item yang ada di keranjang
  static Future<List<CartModel>> getAllCart() async {
    final db = await database();
    final maps = await db.query('cart');
    return maps.map((e) => CartModel.fromMap(e)).toList();
  }
}

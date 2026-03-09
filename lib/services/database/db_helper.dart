import 'dart:convert';
import 'package:rentora_app/models/product_model.dart';
import 'package:rentora_app/models/store_model.dart';
import 'package:rentora_app/models/user_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Future<Database> db() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'my_rentora.db'),
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE user (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT,
          password TEXT,
          phone TEXT)''');
        await db.execute('''
        CREATE TABLE produk (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER,
          images TEXT,
          namaProduk TEXT,
          deskripsiProduk TEXT,
          kategori TEXT,
          hargaPerHari INTEGER,
          dendaPerHari INTEGER,
          stok INTEGER,
          minJumlahPinjam INTEGER,
          maxHariPinjam INTEGER,
          FOREIGN KEY (userId) REFERENCES user(id)
        )
        ''');
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
      },
      version: 1,
    );
  }

  // ================= USER =================
  static Future<void> registerUser(UserModel user) async {
    final dbs = await db();
    await dbs.insert('user', user.toMap());
  }

  static Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    final dbs = await db();
    final List<Map<String, dynamic>> results = await dbs.query(
      "user",
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (results.isNotEmpty) {
      return UserModel.fromMap(results.first);
    }
    return null;
  }

  static Future<UserModel?> getUserByEmail(String email) async {
    final dbs = await db();
    final List<Map<String, dynamic>> results = await dbs.query(
      "user",
      where: 'email = ?',
      whereArgs: [email],
    );
    if (results.isNotEmpty) {
      return UserModel.fromMap(results.first);
    }
    return null;
  }

  // ================= STORE =================
  static Future<void> saveStore(StoreModel store) async {
    final dbs = await db();
    await dbs.insert(
      'stores',
      store.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateStore(StoreModel store) async {
    final dbs = await db();
    await dbs.update(
      'stores',
      store.toMap(),
      where: 'id = ?',
      whereArgs: [store.id],
    );
  }

  static Future<StoreModel?> getStoreByUserId(int userId) async {
    final dbs = await db();
    final List<Map<String, dynamic>> results = await dbs.query(
      'stores',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return StoreModel.fromMap(results.first);
    }
    return null;
  }

  // ================= PRODUK =================

  static Future<void> insertProduk(ProductModel produk) async {
    final dbs = await db();

    final data = produk.toMap();
    data['images'] = jsonEncode(produk.images);

    print("INSERT DATABASE:");
    print(data);

    await dbs.insert(
      'produk',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<ProductModel>> getAllProduk() async {
    final dbs = await db();
    final List<Map<String, dynamic>> maps = await dbs.query('produk');

    return maps.map((map) {
      final mutableMap = Map<String, dynamic>.from(map);

      final imagesString = mutableMap['images'] as String?;
      mutableMap['images'] = (imagesString == null || imagesString.isEmpty)
          ? <String>[]
          : List<String>.from(jsonDecode(imagesString));

      return ProductModel.fromMap(mutableMap);
    }).toList();
  }

  static Future<void> deleteProduk(int id) async {
    final dbs = await db();
    await dbs.delete('produk', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> updateProduk(ProductModel produk) async {
    final dbs = await db();

    final data = produk.toMap();
    data['images'] = jsonEncode(produk.images);

    await dbs.update('produk', data, where: 'id = ?', whereArgs: [produk.id]);
  }
}

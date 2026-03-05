import 'dart:convert';
import 'package:rentora_app/models/produk_model.dart';
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
          images TEXT,
          namaProduk TEXT,
          deskripsiProduk TEXT,
          kategori TEXT,
          hargaPerHari INTEGER,
          stok INTEGER,
          minJumlahPinjam INTEGER,
          maxHariPinjam INTEGER
        )
        ''');
      },
      version: 2,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          db.execute('''
        CREATE TABLE produk (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          images TEXT,
          namaProduk TEXT,
          deskripsiProduk TEXT,
          kategori TEXT,
          hargaPerHari INTEGER,
          stok INTEGER,
          minJumlahPinjam INTEGER,
          maxHariPinjam INTEGER
        )
        ''');
        }
      },
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

  // ================= PRODUK =================

  static Future<void> insertProduk(ProdukModel produk) async {
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

  static Future<List<ProdukModel>> getAllProduk() async {
    final dbs = await db();
    final List<Map<String, dynamic>> maps = await dbs.query('produk');

    return maps.map((map) {
      final mutableMap = Map<String, dynamic>.from(map);

      final imagesString = mutableMap['images'] as String?;
      mutableMap['images'] = (imagesString == null || imagesString.isEmpty)
          ? <String>[]
          : List<String>.from(jsonDecode(imagesString));

      return ProdukModel.fromMap(mutableMap);
    }).toList();
  }

  static Future<void> deleteProduk(int id) async {
    final dbs = await db();
    await dbs.delete('produk', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> updateProduk(ProdukModel produk) async {
    final dbs = await db();

    final data = produk.toMap();
    data['images'] = jsonEncode(produk.images);

    await dbs.update('produk', data, where: 'id = ?', whereArgs: [produk.id]);
  }
}

import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ProductModel {
  final String uid;
  final String storeUid;
  final List<String> images;
  final String namaProduk;
  final String deskripsiProduk;
  final String kategori;
  final int hargaPerHari;
  final int dendaPerHari;
  final int stok;
  final int minJumlahPinjam;
  final int maxHariPinjam;

  ProductModel({
    required this.uid,
    required this.storeUid,
    required this.images,
    required this.namaProduk,
    required this.deskripsiProduk,
    required this.kategori,
    required this.hargaPerHari,
    required this.dendaPerHari,
    required this.stok,
    required this.minJumlahPinjam,
    required this.maxHariPinjam,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'storeUid': storeUid,
      'images': jsonEncode(images),
      'namaProduk': namaProduk,
      'deskripsiProduk': deskripsiProduk,
      'kategori': kategori,
      'hargaPerHari': hargaPerHari,
      'dendaPerHari': dendaPerHari,
      'stok': stok,
      'minJumlahPinjam': minJumlahPinjam,
      'maxHariPinjam': maxHariPinjam,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    List<String> imagesList = [];
    try {
      final raw = map['images'];
      if (raw == null || raw.toString().isEmpty) {
        imagesList = [];
      } else if (raw is List) {
        imagesList = List<String>.from(raw);
      } else if (raw is String) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          imagesList = List<String>.from(decoded);
        } else {
          imagesList = [];
        }
      } else {
        imagesList = [];
      }
    } catch (_) {
      imagesList = [];
    }
    return ProductModel(
      uid: map['uid'] as String,
      storeUid: map['storeUid'] as String,
      images: imagesList,
      namaProduk: map['namaProduk'] as String,
      deskripsiProduk: map['deskripsiProduk'] as String,
      kategori: map['kategori'] as String,
      hargaPerHari: map['hargaPerHari'] as int,
      dendaPerHari: map['dendaPerHari'] as int,
      stok: map['stok'] as int,
      minJumlahPinjam: map['minJumlahPinjam'] as int,
      maxHariPinjam: map['maxHariPinjam'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductModel.fromJson(String source) =>
      ProductModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

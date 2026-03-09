import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ProductModel {
  final int? id;
  final int userId;
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
    this.id,
    required this.userId,
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
      'id': id,
      'userId': userId,
      'images': images,
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
    return ProductModel(
      id: map['id'] as int?,
      userId: map['userId'] as int? ?? 0,
      images: List<String>.from((map['images'] ?? [])),
      namaProduk: map['namaProduk'] as String? ?? '',
      deskripsiProduk: map['deskripsiProduk'] as String? ?? '',
      kategori: map['kategori'] as String? ?? '',
      hargaPerHari: map['hargaPerHari'] as int? ?? 0,
      dendaPerHari: map['dendaPerHari'] as int? ?? 0,
      stok: map['stok'] as int? ?? 0,
      minJumlahPinjam: map['minJumlahPinjam'] as int? ?? 1,
      maxHariPinjam: map['maxHariPinjam'] as int? ?? 7,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductModel.fromJson(String source) =>
      ProductModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

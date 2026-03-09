import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class StoreModel {
  final int? id;
  final int userId;
  final String name;
  final String? image;
  final String? location;

  StoreModel({
    this.id,
    required this.userId,
    required this.name,
    this.image,
    this.location,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'name': name,
      'image': image,
      'location': location,
    };
  }

  factory StoreModel.fromMap(Map<String, dynamic> map) {
    return StoreModel(
      id: map['id'] != null ? map['id'] as int : null,
      userId: map['userId'] as int,
      name: map['name'] as String,
      image: map['image'] != null ? map['image'] as String : null,
      location: map['location'] != null ? map['location'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory StoreModel.fromJson(String source) =>
      StoreModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

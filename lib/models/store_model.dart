import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class StoreModel {
  final String uid;
  final String userUid;
  final String name;
  final String? image;
  final String? location;

  StoreModel({
    required this.uid,
    required this.userUid,
    required this.name,
    this.image,
    this.location,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'userUid': userUid,
      'name': name,
      'image': image,
      'location': location,
    };
  }

  factory StoreModel.fromMap(Map<String, dynamic> map) {
    return StoreModel(
      uid: map['uid'] != null ? map['uid'] as String : '',
      userUid: map['userUid'] != null ? map['userUid'] as String : '',
      name: map['name'] != null ? map['name'] as String : '',
      image: map['image'] != null ? map['image'] as String : null,
      location: map['location'] != null ? map['location'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory StoreModel.fromJson(String source) =>
      StoreModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

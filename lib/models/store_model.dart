import 'dart:convert';

class StoreModel {
  final String uid;
  final String userUid;
  final String name;
  final String? image;
  final String? location;
  final String? province;
  final String? city;
  final String? district;
  final String? postalCode;
  final String? fullAddress;
  final double? latitude;
  final double? longitude;

  StoreModel({
    required this.uid,
    required this.userUid,
    required this.name,
    this.image,
    this.location,
    this.province,
    this.city,
    this.district,
    this.postalCode,
    this.fullAddress,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'userUid': userUid,
      'name': name,
      'image': image,
      'location': location,
      'province': province,
      'city': city,
      'district': district,
      'postalCode': postalCode,
      'fullAddress': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory StoreModel.fromMap(Map<String, dynamic> map) {
    return StoreModel(
      uid: map['uid'] != null ? map['uid'] as String : '',
      userUid: map['userUid'] != null ? map['userUid'] as String : '',
      name: map['name'] != null ? map['name'] as String : '',
      image: map['image'] != null ? map['image'] as String : null,
      location: map['location'] != null ? map['location'] as String : null,
      province: map['province'] != null ? map['province'] as String : null,
      city: map['city'] != null ? map['city'] as String : null,
      district: map['district'] != null ? map['district'] as String : null,
      postalCode: map['postalCode'] != null
          ? map['postalCode'] as String
          : null,
      fullAddress: map['fullAddress'] != null
          ? map['fullAddress'] as String
          : null,
      latitude: map['latitude'] != null
          ? (map['latitude'] as num).toDouble()
          : null,
      longitude: map['longitude'] != null
          ? (map['longitude'] as num).toDouble()
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory StoreModel.fromJson(String source) =>
      StoreModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

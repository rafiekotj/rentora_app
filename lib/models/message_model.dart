import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String uid;
  final String senderUid;
  final String text;
  final DateTime createdAt;
  final bool read;

  MessageModel({
    required this.uid,
    required this.senderUid,
    required this.text,
    required this.createdAt,
    this.read = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'sender_uid': senderUid,
      'text': text,
      'created_at': createdAt.toIso8601String(),
      'read': read,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    DateTime parsed = DateTime.now();
    try {
      final ca = map['created_at'];
      if (ca is String) {
        parsed = DateTime.parse(ca);
      } else if (ca is Timestamp) {
        parsed = ca.toDate();
      }
    } catch (_) {}

    return MessageModel(
      uid: map['uid'] ?? '',
      senderUid: map['sender_uid'] ?? '',
      text: map['text'] ?? '',
      createdAt: parsed,
      read: map['read'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) =>
      MessageModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

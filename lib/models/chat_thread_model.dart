import 'dart:convert';

class ChatThreadModel {
  final String uid;
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastUpdated;

  ChatThreadModel({
    required this.uid,
    required this.participants,
    this.lastMessage,
    this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'participants': participants,
      'last_message': lastMessage,
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }

  factory ChatThreadModel.fromMap(Map<String, dynamic> map) {
    DateTime? parsed;
    try {
      if (map['last_updated'] is String) {
        parsed = DateTime.parse(map['last_updated'] as String);
      }
    } catch (_) {}

    return ChatThreadModel(
      uid: map['uid'] ?? '',
      participants: List<String>.from(map['participants'] ?? <String>[]),
      lastMessage: map['last_message'],
      lastUpdated: parsed,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatThreadModel.fromJson(String source) =>
      ChatThreadModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

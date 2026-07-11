import 'package:hive/hive.dart';

/// Model representing a single chat message between the user and SafeNet AI assistant.
class ChatMessage {
  final String id;
  final String role; // "user" or "assistant"
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      role: json['role'] ?? 'user',
      text: json['text'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

// ==========================================
// CUSTOM HIVE ADAPTER FOR CHAT MESSAGES
// ==========================================

class ChatMessageAdapter extends TypeAdapter<ChatMessage> {
  @override
  final int typeId = 1;

  @override
  ChatMessage read(BinaryReader reader) {
    final id = reader.readString();
    final role = reader.readString();
    final text = reader.readString();
    final timestampMillis = reader.readInt();

    return ChatMessage(
      id: id,
      role: role,
      text: text,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMillis),
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessage obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.role);
    writer.writeString(obj.text);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
  }
}

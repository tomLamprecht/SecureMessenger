import 'package:my_flutter_test/models/AttachedFile.dart';

class Message {
  int id;
  int fromUserId;
  String fromUserName;
  int chatId;
  String value;
  List<AttachedFile> attachedFiles;
  DateTime timestamp;
  DateTime? lastTimeUpdated;

  Message({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.chatId,
    required this.value,
    required this.attachedFiles,
    required this.timestamp,
    required this.lastTimeUpdated
  });

  factory Message.fromJson(Map<String, dynamic> json, int providedChatId) {
    return Message(
      id: json['id'],
      fromUserId: json['fromAccount']['id'],
      fromUserName: json['fromAccount']['username'],
      chatId: providedChatId,
      value: json['value'],
      attachedFiles: (json['attachedFiles'] as List)
          .map((item) => AttachedFile.fromJson(item))
          .toList(),
      timestamp: DateTime.parse(json['timestamp']),
      lastTimeUpdated: json['lastTimeUpdated'] != null ? DateTime.parse(json['lastTimeUpdated']) : null
    );
  }
}
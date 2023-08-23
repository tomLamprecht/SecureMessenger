class Message {
  int id;
  int fromUserId;
  String fromUserName;
  int chatId;
  String value;
  DateTime timestamp;
  DateTime? lastTimeUpdated;

  Message({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.chatId,
    required this.value,
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
      timestamp: DateTime.parse(json['timestamp']),
      lastTimeUpdated: json['lastTimeUpdated'] != null ? DateTime.parse(json['lastTimeUpdated']) : null
    );
  }
}
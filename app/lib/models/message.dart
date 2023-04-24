class Message {
  int id;
  int fromUserId;
  int chatId;
  String value;
  DateTime timestamp;

  Message({
    required this.id,
    required this.fromUserId,
    required this.chatId,
    required this.value,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      fromUserId: json['fromUserId'],
      chatId: json['chatId'],
      value: json['value'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
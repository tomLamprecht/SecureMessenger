class Chat {
  final int id;
  final String name;
  final String description;
  final DateTime createdAt;
  String? encodedGroupPic;

  Chat({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    this.encodedGroupPic
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      encodedGroupPic: json['encodedGroupPic'],
    );
  }
}

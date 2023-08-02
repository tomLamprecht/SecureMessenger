class Chat {
  final int id;
  final String name;
  final String description; // todo: eigentlich wäre ja eine Gruppenbeschreibung valid, welche Anfangs leer ist und dann befüllt werden könnte
  final DateTime createdAt;

  const Chat(
      this.id,
      this.name,
      this.description,
      this.createdAt,
      );

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      json['id'],
      json['name'],
      json['description'],
      DateTime.parse(json['createdAt']),
    );
  }
}

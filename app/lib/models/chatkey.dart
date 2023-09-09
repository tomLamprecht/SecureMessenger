class Chatkey {
  String value;
  String encryptedByPublicKey;

  Chatkey({
    required this.value,
    required this.encryptedByPublicKey,
  });

  factory Chatkey.fromJson(Map<String, dynamic> json) {
    return Chatkey(
      value: json['value'],
      encryptedByPublicKey: json['encryptedByPublicKey'],
    );
  }
}
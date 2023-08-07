class Account {
  int accountId;
  String userName;
  String publicKey;

  Account({
    required this.accountId,
    required this.userName,
    required this.publicKey,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountId: json['accountId'],
      userName: json['userName'],
      publicKey: json['publicKey']
    );
  }
}
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
      accountId: json['id'],
      userName: json['userName'],
      publicKey: json['publicKey']
    );
    // todo: add joinedAt
  }
}
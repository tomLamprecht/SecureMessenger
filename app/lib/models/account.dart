class Account {
  int accountId;
  String userName;
  String publicKey;
  bool isSelected = false;
  String? encodedProfilePic;

  Account({
    required this.accountId,
    required this.userName,
    required this.publicKey,
    this.encodedProfilePic
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountId: json['id'],
      userName: json['userName'],
      publicKey: json['publicKey'],
      encodedProfilePic: json['encodedProfilePic'],
    );
  }
}
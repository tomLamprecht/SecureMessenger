class AccountIdToEncryptedSymKey {
  int accountId;
  String encryptedSymmetricKey;

  AccountIdToEncryptedSymKey({
    required this.accountId,
    required this.encryptedSymmetricKey,
  });

  factory AccountIdToEncryptedSymKey.fromJson(Map<String, dynamic> json) {
    return AccountIdToEncryptedSymKey(
      accountId: json['accountId'],
      encryptedSymmetricKey: json['encryptedSymmetricKey'],
    );
  }

  Map<String, dynamic> toJson() => {
    'accountId': accountId,
    'encryptedSymmetricKey': encryptedSymmetricKey
  };
}
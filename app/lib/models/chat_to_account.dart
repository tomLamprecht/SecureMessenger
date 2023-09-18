import 'package:securemessenger/models/chat.dart';

import 'account.dart';

class ChatToAccount {
  final int id;
  final Chat chat;
  final Account account;
  final String key;
  final bool isAdmin;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final Account encryptedBy;

  const ChatToAccount(
      this.id,
      this.chat,
      this.account,
      this.key,
      this.isAdmin,
      this.joinedAt,
      this.leftAt,
      this.encryptedBy
      );

  factory ChatToAccount.fromJson(Map<String, dynamic> json) {
    return ChatToAccount(
      json['id'],
      Chat.fromJson(json['chat']),
      Account.fromJson(json['account']),
      json['key'],
      json['isAdmin'],
      DateTime.parse(json['joinedAt']),
      json['leftAt'] != null ? DateTime.parse(json['leftAt']) : null,
      Account.fromJson(json['encryptedBy'])
    );
  }
}

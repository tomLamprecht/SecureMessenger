import 'package:securemessenger/models/account.dart';

class Friendship {
  final int id;
  final Account fromAccount;
  final Account toAccount;


  Friendship({
    required this.id,
    required this.fromAccount,
    required this.toAccount
  });

  factory Friendship.fromJson(Map<String, dynamic> json) {
    return Friendship(
      id: json["id"],
      fromAccount: Account.fromJson(json['fromAccount']),
      toAccount: Account.fromJson(json['toAccount'])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromAccount': fromAccount,
      'toAccount': toAccount
    };
  }
}

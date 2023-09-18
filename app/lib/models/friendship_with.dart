import 'package:securemessenger/models/account.dart';

class FriendshipWith {
  final int id;
  final Account withAccount;
  final bool accepted;


  FriendshipWith({
    required this.id,
    required this.withAccount,
    required this.accepted
  });

  factory FriendshipWith.fromJson(Map<String, dynamic> json) {
    return FriendshipWith(
        id: json['id'],
        withAccount: Account.fromJson(json['withAccount']),
        accepted: json['accepted']
    );
  }

}

import 'package:my_flutter_test/models/account.dart';

class Friendship {
  final int id;
  final Account fromAccount;
  final Account toAccount;


  Friendship({
    required this.id,
    required this.fromAccount,
    required this.toAccount
  });

  // Friendship copyWith({int? fromUserId, int? toUserId, bool? accepted}) {
  //   return Friendship(
  //     fromUserId: fromUserId ?? this.fromUserId,
  //     toUserId: toUserId ?? this.toUserId,
  //     accepted: accepted ?? this.accepted,
  //   );
  // }

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

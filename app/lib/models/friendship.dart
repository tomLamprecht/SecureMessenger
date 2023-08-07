import 'package:my_flutter_test/models/account.dart';

class Friendship {
  final Account fromAccount;
  final Account toAccount;


  Friendship({
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
      fromAccount: json['fromAccount'],
      toAccount: json['toAccount']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromAccount': fromAccount,
      'toAccount': toAccount
    };
  }
}

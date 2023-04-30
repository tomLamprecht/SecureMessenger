class Friendship {
  final int fromUserId;
  final int toUserId;
  final bool accepted;

  Friendship({
    required this.fromUserId,
    required this.toUserId,
    required this.accepted,
  });

  Friendship copyWith({int? fromUserId, int? toUserId, bool? accepted}) {
    return Friendship(
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      accepted: accepted ?? this.accepted,
    );
  }

  factory Friendship.fromJson(Map<String, dynamic> json) {
    return Friendship(
      fromUserId: json['fromUserId'],
      toUserId: json['toUserId'],
      accepted: json['accepted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'accepted': accepted,
    };
  }
}

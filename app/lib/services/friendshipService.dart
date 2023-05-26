import 'dart:convert';
import 'dart:developer';

import 'package:my_flutter_test/models/friendship.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class FriendshipServcie {
  Future<List<Friendship>?> getFriendshipRequests() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/friendships');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      final List<Friendship> chatList = jsonList.map((json) => Friendship.fromJson(json))
          .toList();
      return chatList;
    } else {
      log("Keine Liste bei GET-Request erhalten!");
      return null;
    }
  }

  Future<int?> createFriendshipRequest(String targetUserName) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/friendships');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'targetUserName': targetUserName});

    final response = await http.post(url, headers: headers, body: body);
    log("response: $response");
    if (response.statusCode == 201) {
      final friendshipId = json.decode(response.body)['friendshipId'];
      return friendshipId;
    } else {
      return null;
    }
  }
}
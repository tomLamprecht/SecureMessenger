import 'dart:convert';
import 'dart:developer';

import 'package:my_flutter_test/models/friendship.dart';
import '../custom_http_client.dart';
import 'api/api_config.dart';

class FriendshipServcie {
  Future<List<Friendship>?> getFriendshipRequests() async {
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/friendships');

    final response = await CustomHttpClient().get(url);
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
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/friendships');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'targetUserName': targetUserName});

    final response = await CustomHttpClient().post(url, headers: headers, body: body);
    log("response: $response");
    if (response.statusCode == 201) {
      final friendshipId = json.decode(response.body)['friendshipId'];
      return friendshipId;
    } else {
      return null;
    }
  }
}
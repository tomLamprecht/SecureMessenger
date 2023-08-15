import 'dart:convert';
import 'dart:developer';

import 'package:my_flutter_test/models/account.dart';
import 'package:my_flutter_test/models/friendship.dart';
import 'package:my_flutter_test/models/friendship_with.dart';
import '../custom_http_client.dart';
import 'api/api_config.dart';

class FriendshipService {
  Future<List<Account>> getFriendshipRequests() async {
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/friendships/incoming?showOnlyPending=true');

    final response = await CustomHttpClient().get(url);
    print("RespCode: ${response.statusCode}");
    if (response.statusCode == 200) {
      print("if - Response: ${response.body}");
      print("Json Decode: ${json.decode(response.body)}");
      final List<dynamic> jsonList = json.decode(response.body);
      final List<Friendship> friendshipList = jsonList.map((json) => Friendship.fromJson(json)).toList();
      final List<Account> accounts = [];
      for (var incomingFriendship in friendshipList) { accounts.add(incomingFriendship.fromAccount); }
      return accounts;
    } else {
      log("Keine Liste bei GET-Request Friendships erhalten!");
      return [];
    }
  }

  Future<List<Account>> getFriendships() async {
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/friendships/with');

    final response = await CustomHttpClient().get(url);
    print("friendships code: ${response.statusCode}");
    if (response.statusCode == 200) {
      print("responseBody: ${response.body}");
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => FriendshipWith.fromJson(json).withAccount).toList();
    } else {
      log("Keine Liste bei GET-Request Friends erhalten!");
      return [];
    }
  }

  Future<bool> postFriendshipRequest(int accountId) async {
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/friendships/$accountId');

    final response = await CustomHttpClient().post(url, body: json.encode({}));

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteFriendshipRequest(int accountId) async {
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/friendships/$accountId');
    final headers = {'Content-Type': 'application/json'};

    final response = await CustomHttpClient().delete(url, headers: headers);

    if (response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }
}
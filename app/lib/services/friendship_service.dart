import 'dart:convert';
import 'dart:developer';

import 'package:my_flutter_test/models/account.dart';
import 'package:my_flutter_test/models/friendship.dart';
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
      log("Keine Liste bei GET-Request erhalten!");
      return [];
    }
  }

  Future<List<Account>> getFriendships() async {
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/friendships');

    final response = await CustomHttpClient().get(url); //todo: ab hier gleiches wie drüber, in Methode auslagern wenn fehler fixed
    print("friendships code: ${response.statusCode}");
    if (response.statusCode == 200) {
      print("responseBody: ${response.body}");
      final List<dynamic> jsonList = json.decode(response.body);
      print("jsonList: $jsonList");
      if(jsonList.isEmpty) {
        return [];
      }
      final List<Friendship> friendshipList = jsonList.map((json) => Friendship.fromJson(json)).toList();
      print("friendships: $friendshipList");
      final List<Account> accounts = [];
      for (var incomingFriendship in friendshipList) { accounts.add(incomingFriendship.fromAccount); } // todo: muss ich fromAccount abfragen oder toAccount?
      print("friendships accounts: $accounts");
      return accounts;
    } else {
      log("Keine Liste bei GET-Request erhalten!");
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
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import '../models/Chat.dart';
import 'api_config.dart';

class ChatsService {
  Future<int?> createChat(String targetUserName) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/chats');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'targetUserName': targetUserName});

    final response = await http.post(url, headers: headers, body: body);
    log("response: $response");
    if (response.statusCode == 201) {
      final chatId = json.decode(response.body)['chatId'];
      return chatId;
    } else {
      return null;
    }
  }

  Future<List<Chat>?> getChatsFromUser() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/chats');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      final List<Chat> chatList = jsonList.map((json) => Chat.fromJson(json)).toList();
      return chatList;
    } else {
      log("Keine Liste bei GET-Request erhalten!");
      return null;
    }
  }
}
import 'dart:convert';
import 'dart:developer';

import '../custom_http_client.dart';
import '../models/chat.dart';
import 'api/api_config.dart';

class ChatsService {
  //einzelner Chat, Gruppenchat (Namen, chatnamen, description)
  // im Frontend wird keypair generiert
  // mit pubkey verschlüssel
  //
  Future<int?> createChat(String targetUserName) async {
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'targetUserName': targetUserName});

    final response = await CustomHttpClient().post(url, headers: headers, body: body);
    log("response: $response");
    if (response.statusCode == 201) {
      final chatId = json.decode(response.body)['chatId'];
      return chatId;
    } else {
      return null;
    }
  }

  Future<List<Chat>?> getChatsFromUser() async {
    print("get all chats");
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats');
    print("use uri $url");
    final response = await CustomHttpClient().get(url);
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
import 'dart:convert';
import 'dart:developer';

import '../custom_http_client.dart';
import '../models/account_id_to_encrypted_sym_key.dart';
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

  Future<int?> createChatNew(String chatName, String description, List<AccountIdToEncryptedSymKey> accountIdToEncryptedSymKeys) async {
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats');
    final headers = {'Content-Type': 'application/json'};
    List<Map<String, dynamic>> symKeys = accountIdToEncryptedSymKeys.map((e) => e.toJson()).toList();
    final body = json.encode({"chatName": chatName, "description": description, accountIdToEncryptedSymKeys: symKeys});

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

  Future<bool> deleteChatFromUser(int chatId, int accountId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/chats/$chatId/accounts/$accountId"');
    final headers = {'Content-Type': 'application/json'};

    final response = await CustomHttpClient().delete(url, headers: headers);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
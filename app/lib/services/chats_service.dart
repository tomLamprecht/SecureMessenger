import 'dart:convert';

import 'package:securemessenger/models/account.dart';
import 'package:securemessenger/models/chatkey.dart';

import '../custom_http_client.dart';
import '../models/account_id_to_encrypted_sym_key.dart';
import '../models/chat.dart';
import '../models/chat_to_account.dart';
import 'api/api_config.dart';

class ChatsService {

  Future<int?> createNewChat(String chatName, String description, List<AccountIdToEncryptedSymKey> accountIdToEncryptedSymKeys) async {
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats');
    final headers = {'Content-Type': 'application/json'};
    List<Map<String, dynamic>> symKeys = accountIdToEncryptedSymKeys.map((e) => e.toJson()).toList();
    final body = json.encode({"chatName": chatName, "description": description, "accountIdToEncryptedSymKeys": symKeys});

    final response = await CustomHttpClient().post(url, headers: headers, body: body);
    if (response.statusCode == 201) {
      final chatId = int.parse(response.body);
      return chatId;
    } else {
      return null;
    }
  }

  Future<List<Chat>> getChatsFromUser() async {
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats');
    final response = await CustomHttpClient().get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      final List<Chat> chatList = jsonList.map((json) => Chat.fromJson(json)).toList();
      return chatList;
    } else {
      return [];
    }
  }

  Future<ChatToAccount?> getChatToUser(int chatId) async {
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats/$chatId');

    final response = await CustomHttpClient().get(url);
    if (response.statusCode == 200) {
      return ChatToAccount.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  Future<Chatkey?> getOwnSymmetricKeyOfChat(int chatId) async {
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats/$chatId/symmetric-key');
    final headers = {'Content-Type': 'application/json'};
    final response = await CustomHttpClient().get(url, headers:  headers);

    if (response.statusCode == 200) {
      return Chatkey.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  Future<bool> deleteChatFromUser(int chatId, int accountId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/chats/$chatId/accounts/$accountId"');
    final headers = {'Content-Type': 'application/json'};

    final response = await CustomHttpClient().delete(url, headers: headers);

    if (response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addAccountsToGroup(int chatId, List<AccountIdToEncryptedSymKey> accounts) async {
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats/$chatId/accounts');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(accounts.map((e) => e.toJson()).toList());

    final response = await CustomHttpClient().post(url, headers: headers, body: body);

    return response.statusCode == 201;
  }

  Future<List<ChatToAccount>> getAllChatToAccountsInChat(int chatId) async {
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats/$chatId/chat-to-accounts');

    final response = await CustomHttpClient().get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ChatToAccount.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<List<Account>> getAllAccountsInChat(int chatId) async {
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats/$chatId/accounts');

    final response = await CustomHttpClient().get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Account.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<String> leaveChat(int chatId) async {
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats/$chatId/leave');
    final response = await CustomHttpClient().post(url);

    if (response.statusCode == 400) {
      return jsonDecode(response.body)['message'];
    }
    return "";
  }

  Future<bool> deleteChat(int chatId) async {
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats/$chatId');
    final response = await CustomHttpClient().delete(url);

    return response.statusCode == 204;
  }

  Future<bool> removeAccountFromChat(int chatId, int accountId) async {
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats/$chatId/accounts/$accountId');
    final response = await CustomHttpClient().delete(url);

    return response.statusCode == 204;
  }

  Future<bool> updateAdminRoleSettingOfAccount(int chatId, int accountId, bool isAdmin) async {
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats/$chatId/accounts/$accountId/admin?isAdmin=$isAdmin');
    final response = await CustomHttpClient().put(url);

    return response.statusCode == 204;
  }

  Future<bool> updateGroupPicFromChat(String encodedGroupPic, int chatId) async {
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats/$chatId/update-group-pic');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({"encodedGroupPic": encodedGroupPic});

    final response = await CustomHttpClient().put(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteGroupPicFromChat(int chatId) async {
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats/$chatId/delete-group-pic');
    final headers = {'Content-Type': 'application/json'};
    final response = await CustomHttpClient().delete(url, headers: headers);
    if (response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }
}

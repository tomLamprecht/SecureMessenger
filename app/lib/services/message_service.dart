import 'dart:convert';

import '../custom_http_client.dart';
import '../models/AttachedFile.dart';
import '../models/chatkey.dart';
import '../models/message.dart';
import 'api/api_config.dart';

Future<int?> sendMessage(int chatId, String message, List<AttachedFile> attachedFiles, int? selfDestructionDuration) async {
  final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats/$chatId/messages');
  final headers = {'Content-Type': 'application/json'};

  final body = json.encode({
    'value': message,
    'attachedFiles': attachedFiles.map((file) => file.toJson()).toList(),
    "selfDestructionDurationSecs": selfDestructionDuration,
  });

  final response = await CustomHttpClient().post(url, headers: headers, body: body);
  if (response.statusCode == 201) {
    return json.decode(response.body)['chatId'];
  } else {
    return null;
  }
}

Future<void> deleteMessage(int chatId, int messageId) async {
  final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats/$chatId/messages/$messageId');
  final response = await CustomHttpClient().delete(url);
  if (response.statusCode == 404) {
    throw Exception("Message could not get deleted");
  }
}

Future<void> updateMessage(int messageId, int chatId, String value) async {
  final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats/${chatId}/messages/${messageId}');
  final headers = {'Content-Type': 'application/json'};
  final response = await CustomHttpClient().put(url,  headers: headers, body: json.encode({"value": value}));
  if (response.statusCode == 404) {
    throw Exception("Message could not get updated");
  }
}

Future<List<Message>> readAllMessages(int chatId, int amount, int latestMessageId) async {
  final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats/$chatId/messages?maxSize=$amount&latestMessageId=$latestMessageId');
  final headers = {'Content-Type': 'application/json'};

  final response = await CustomHttpClient().get(url, headers: headers);
  if (response.statusCode == 200) {
    return (json.decode(response.body) as List<dynamic>).map((item) => Message.fromJson(item, chatId)).toList();
  } else {
    throw Exception("Messages could not be read. Server did respond with Http Status Code: ${response.statusCode}");
  }
}

Future<Chatkey?> getKeyOfChat(int chatId) async {
  final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats/$chatId/symmetric-key');
  final headers = {'Content-Type': 'application/json',
  'Accept' :'application/json' };
  final response = await CustomHttpClient().get(url, headers:  headers);
  if (response.statusCode == 200) {
    return Chatkey.fromJson(json.decode(response.body));
  } else {
    return null;
  }
}

Future<String> getSessionKey(int chatId) async{
  final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats/$chatId/messages/subscription');
  final headers = {'Content-Type': 'application/json'};
  final response = await CustomHttpClient().get(url, headers: headers);

  if (response.statusCode == 200) {
    return json.decode(response.body)['session'];
  } else {
    throw Exception("Could not build up a constant reading Session");
  }
}
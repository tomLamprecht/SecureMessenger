import 'dart:convert';
import 'dart:developer';

import '../custom_http_client.dart';
import '../models/message.dart';
import 'api/api_config.dart';

Future<int?> sendMessage(int chatId, String message) async {
  log("send message");
  final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats/$chatId/messages');
  final headers = {'Content-Type': 'application/json'};

  final body = json.encode({'value': message});

  final response = await CustomHttpClient().post(url, headers: headers, body: body);
  log("response (status: ${response.statusCode}) : ${response.body} ");
  if (response.statusCode == 201) {
    return json.decode(response.body)['chatId'];
  } else {
    return null;
  }
}

Future<void> deleteMessage(int chatId, int messageId) async {
  log("delete message $messageId");
  final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats/$chatId/messages/$messageId');

  final response = await CustomHttpClient().delete(url);
  if (response.statusCode == 404) {
    throw Exception("Message could not get deleted");
  }
}


Future<List<Message>> readAllMessages(int chatId) async {
  final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats/$chatId/messages');
  final headers = {'Content-Type': 'application/json'};

  final response = await CustomHttpClient().get(url, headers: headers);
  log("response: ${response.body}");
  if (response.statusCode == 200) {
    return (json.decode(response.body) as List<dynamic>).map((item) => Message.fromJson(item, chatId)).toList();
  } else {
    throw Exception("Messages could not be read. Server did respond with Http Status Code: ${response.statusCode}");
  }
}

Future<String?> getKeyOfChat(int chatId) async {
  log("Inside getKeyOfChat");
  final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats/$chatId/symmetric-key');
  final headers = {'Content-Type': 'application/json'};

  final response = await CustomHttpClient().get(url, headers: headers);
  log("response of get Key: ${response.body}");
  if (response.statusCode == 200) {
    log("sucessfully got Key of Chat");
    return response.body;
  } else {
    return null;
  }
}

Future<String> getSessionKey(int chatId) async{
  final url = Uri.parse('${ApiConfig.httpBaseUrl}/chats/$chatId/messages/subscription');
  final headers = {'Content-Type': 'application/json'};

  final response = await CustomHttpClient().get(url, headers: headers);
  log("response of get Session: ${response.body}");
  if (response.statusCode == 200) {
    log("sucessfully got Session for Websocket");
    return json.decode(response.body)['session'];
  } else {
    throw Exception("Could not build up a constant reading Session");
  }
}
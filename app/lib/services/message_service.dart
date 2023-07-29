import 'dart:convert';
import 'dart:developer';

import '../custom_http_client.dart';
import '../models/message.dart';
import 'api/api_config.dart';

Future<int?> sendMessage(int chatId, String message) async {
  log("send message");
  final url = Uri.parse('${ApiConfig.baseUrl}/chats/$chatId');
  final headers = {'Content-Type': 'application/json'};

  final body = json.encode({'value': message});

  final response = await CustomHttpClient().post(url, headers: headers, body: body);
  log("response: $response");
  if (response.statusCode == 201) {
    return json.decode(response.body)['chatId'];
  } else {
    return null;
  }
}

Future<List<Message>?> readAllMessages(int chatId) async {
  final url = Uri.parse('${ApiConfig.baseUrl}/chat/$chatId');
  final headers = {'Content-Type': 'application/json'};

  final response = await CustomHttpClient().post(url, headers: headers);
  log("response: $response");
  if (response.statusCode == 200) {
    return (json.decode(response.body) as List<dynamic>).map((item) => Message.fromJson(item)).toList();
  } else {
    return null;
  }
}

Future<String?> getKeyOfChat(int chatId) async {
  log("Inside getKeyOfChat");
  final url = Uri.parse('${ApiConfig.baseUrl}/chats/$chatId/my-chat');
  final headers = {'Content-Type': 'application/json'};

  final response = await CustomHttpClient().get(url, headers: headers);
  log("response: $response");
  if (response.statusCode == 200) {
    return json.decode(response.body)['key'];
  } else {
    return null;
  }
}
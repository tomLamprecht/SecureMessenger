import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:my_flutter_test/services/auth_data.dart';
import 'package:my_flutter_test/services/encryption_service.dart';

import '../models/message.dart';
import 'api/api_config.dart';
import 'header_auth.dart';

AuthData ds = AuthData();

Future<int?> sendMessage(int chatId, String message) async {
  final path = '/chats/$chatId';
  final url = Uri.parse('${ApiConfig.baseUrl}$path');
  final body = json.encode({'value': message});
  final headers = {'Content-Type': 'application/json',};
  headers.addAll(authHeaders('POST', path, message));

  final response = await http.post(url, headers: headers, body: body);
  log("response: $response");
  if (response.statusCode == 201) {
    return json.decode(response.body)['chatId'];
  } else {
    return null;
  }
}

Future<List<Message>?> readAllMessages(int chatId) async {
  final path = '/chat/$chatId';
  final url = Uri.parse('${ApiConfig.baseUrl}$path');
  final headers = {'Content-Type': 'application/json'};
  headers.addAll(authHeaders('POST', path, ''));

  final response = await http.post(url, headers: headers);
  log("response: $response");
  if (response.statusCode == 200) {
    return (json.decode(response.body) as List<dynamic>).map((item) =>
        Message.fromJson(item)).toList();
  } else {
    return null;
  }
}

Future<String?> getKeyOfChat(int chatId) async {
  final path = '/chats/$chatId/my-chat';
  final url = Uri.parse('${ApiConfig.baseUrl}$path');
  final headers = {'Content-Type': 'application/json'};
  headers.addAll(authHeaders('GET', path, ''));

  final response = await http.get(url, headers: headers);
  log("response: $response");
  if (response.statusCode == 200) {
    return json.decode(response.body)['key'];
  } else {
    return null;
  }
}
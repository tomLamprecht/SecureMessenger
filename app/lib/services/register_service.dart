import 'dart:convert';
import 'dart:developer' as developer;

import '../custom_http_client.dart';

class RegistrationService {
  final String _baseUrl;

  RegistrationService({String baseUrl = 'http://localhost:8080'}) : _baseUrl = baseUrl;

  Future<void> registerUser({
    required String captchaId,
    required String captchaTry,
    required String publicKey,
    required String userName,
  }) async {
    developer.log(captchaId);
    final response = await CustomHttpClient().post(
      Uri.parse('$_baseUrl/users/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'captchaTry': {
          'id': captchaId,
          'textTry': captchaTry
        },
        'publicKey': publicKey,
        'userName': userName,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to register user.');
    }

  }
}

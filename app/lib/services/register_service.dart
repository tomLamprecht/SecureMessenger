import 'dart:convert';

import 'package:securemessenger/services/api/api_config.dart';

import '../custom_http_client.dart';

class RegistrationService {
  final String _baseUrl;

  RegistrationService() : _baseUrl = ApiConfig.httpBaseUrl;

  Future<void> registerUser({
    required String captchaId,
    required String captchaTry,
    required String publicKey,
    required String userName,
  }) async {
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

    if (response.statusCode == 400) {
      switch (response.body) {
        case "Captcha was not correct. Please retry with a new one.":
          throw Exception("Invalid captcha text. Please try again.");
        case "Invalid userName was given. Only letters and numbers are allowed!":
          throw Exception("Invalid username. Only letters and numbers are allowed.");
        default:
          throw Exception("Something went wrong. Please try again later.");
      }
    } else if (response.statusCode == 500) {
      throw Exception("Server error. Please try again later.");
    } else if (response.statusCode == 409){
      throw Exception(response.body);
    }
  }
}

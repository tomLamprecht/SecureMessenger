import 'dart:convert';
import 'package:http/http.dart' as http;

class RegistrationService {
  final String _baseUrl;

  RegistrationService({String baseUrl = 'http://localhost:8080'}) : _baseUrl = baseUrl;

  Future<int> registerUser({
    required String captchaId,
    required String captchaTry,
    required String publicKey,
    required String userName,
  }) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'captchaTry': {
          'captchaId': captchaId,
          'captchaTry': captchaTry
        },
        'publicKey': publicKey,
        'userName': userName,
      }),
    );

    if (response.statusCode == 201) {
      return int.parse(response.body);
    } else {
      throw Exception('Failed to register user.');
    }
  }
}

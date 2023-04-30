import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class CaptchaService {
  final String _baseUrl;

  CaptchaService({String baseUrl = 'http://localhost:8080'}) : _baseUrl = baseUrl;

  Future<String> getNewCaptcha() async {
    final response = await http.get(Uri.parse('$_baseUrl/captcha'));
    if (response.statusCode == HttpStatus.ok) {
      return response.body;
    } else {
      throw Exception('Failed to get new captcha.');
    }
  }

  Future<File> getCaptchaImage(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/captcha/$id'),
        headers: {'Accept': 'image/png'});
    if (response.statusCode == HttpStatus.ok) {
      return File('captcha.png')..writeAsBytesSync(response.bodyBytes);
    } else {
      throw Exception('Failed to get captcha image.');
    }
  }

  Future<bool> validateCaptcha(String id, String textTry) async {
    final response = await http.post(Uri.parse('$_baseUrl/captcha/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'textTry': textTry,
        }));
    if (response.statusCode == HttpStatus.ok) {
      return response.body == 'true';
    } else {
      throw Exception('Failed to validate captcha.');
    }
  }
}

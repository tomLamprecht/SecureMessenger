import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

import '../deprecated_custom_http_client.dart';
import '../custom_http_client.dart';

class CaptchaService {
  final String _baseUrl;

  CaptchaService({String baseUrl = 'http://localhost:8080'}) : _baseUrl = baseUrl;

  Future<String> getNewCaptcha() async {
    final response = await CustomHttpClient().get(Uri.parse('$_baseUrl/captcha'));
    if (response.statusCode == HttpStatus.ok) {
      return response.body;
    } else {
      throw Exception('Failed to get new captcha.');
    }
  }

  Future<ImageProvider> fetchCaptchaImage(String id) async {
    final response = await CustomHttpClient().get(Uri.parse('$_baseUrl/captcha/$id'));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final imageBytes = Uint8List.fromList(bytes);
      final image = MemoryImage(imageBytes);
      return image;
    } else {
      throw Exception('Failed to load captcha image');
    }
  }
}

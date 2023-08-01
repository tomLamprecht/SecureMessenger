import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_test/services/files/rsa_helper.dart';
import 'package:my_flutter_test/services/stores/rsa_key_store.dart';
import 'package:pointycastle/export.dart';

class CustomHttpClient extends http.BaseClient {
  static final CustomHttpClient _instance = CustomHttpClient._();
  factory CustomHttpClient() => _instance;

  final http.Client _client = http.Client();

  CustomHttpClient._();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    var publicKey = RsaKeyStore().publicKey;

    if (publicKey == null) {
      return _client.send(request);
    }

    final String timestamp = DateTime.now().toIso8601String();
    final String method = request.method;
    final String path = Uri.encodeFull(request.url.toString());
    final String bodyHash = _getBodyHash(request);

    final String encodedTimestamp = Uri.encodeFull(timestamp);
    final String encodedPublicKey =
    Uri.encodeFull(RSAHelper().encodePublicKeyToString(publicKey));
    String authorizationHeader = encryptStringWithPrivateKey("$method#$path#$timestamp#$bodyHash");

    request.headers['x-auth-signature'] = authorizationHeader;
    request.headers['x-auth-timestamp'] = encodedTimestamp;
    request.headers['x-public-key'] = encodedPublicKey;

    return _client.send(request);
  }

  String encryptStringWithPrivateKey(String plaintext) {
    final encrypter = RSAEngine()
      ..init(true, PrivateKeyParameter<RSAPrivateKey>(
          RsaKeyStore().privateKey as PrivateKey));

    final input = Uint8List.fromList(utf8.encode(plaintext));
    final encrypted = encrypter.process(input);

    return base64.encode(encrypted);
  }

  String _getBodyHash(http.BaseRequest request) {
    String bodyJson = '{}';
    if (request is http.Request) {
      if (request.body.isNotEmpty) {
        bodyJson = request.body;
      }
    }
    return _calculateSHA256Hash(bodyJson);
  }

  String _calculateSHA256Hash(String input) {
    var bytes = utf8.encode(input);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}

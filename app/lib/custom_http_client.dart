import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:my_flutter_test/services/files/rsa_helper.dart';
import 'package:my_flutter_test/services/stores/rsa_key_store.dart';
import 'package:encrypt/encrypt.dart' as enc;

class CustomHttpClient extends http.BaseClient {
  static final CustomHttpClient _instance = CustomHttpClient._();
  factory CustomHttpClient() => _instance;

  final http.Client _client = http.Client();
  final rsaHelper = RSAHelper();

  CustomHttpClient._();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (RsaKeyStore().publicKey == null) {
      return _client.send(request);
    }

    final path = request.url.path;
    final method = request.method;
    final timestamp = DateTime.now().toUtc().toIso8601String();

    String body = "";
    if (request is http.Request) {
      body = request.body;
    }
    if (body.isEmpty) {
      body = "{}";
    }

    final payload = '$method#$path#$timestamp#$body';

    final publicKeyHeader = rsaHelper.encodePublicKeyToString(RsaKeyStore().publicKey!);
    final signature = _generateSignature(payload);


    request.headers.addAll({
      'x-auth-timestamp': timestamp,
      'x-public-key': publicKeyHeader,
      'x-auth-signature': signature
    });

    return _client.send(request);
  }

  String _generateSignature(String payload) {
    final input = Uint8List.fromList(utf8.encode(payload));
    final signer = enc.RSASigner(enc.RSASignDigest.SHA256, privateKey: RsaKeyStore().privateKey);
    final signedMessage = signer.sign(input);
    return base64Encode(signedMessage.bytes);
  }
}

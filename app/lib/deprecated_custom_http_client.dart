import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:http/http.dart' as http;
import 'package:my_flutter_test/services/files/rsa_helper.dart';
import 'package:my_flutter_test/services/stores/rsa_key_store.dart';
import 'package:pointycastle/export.dart';


class DeprecatedCustomHttpClient extends http.BaseClient {
  static final DeprecatedCustomHttpClient _instance = DeprecatedCustomHttpClient._();
  factory DeprecatedCustomHttpClient() => _instance;

  final http.Client _client = http.Client();

  DeprecatedCustomHttpClient._();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    var publicKey = RsaKeyStore().publicKey;

    if (publicKey == null) {
      return _client.send(request);
    }

    final String timestamp = DateTime.now().toUtc().toIso8601String();
    final String method = request.method.toUpperCase();
    final String path = request.url.toString();
    final String body = _getBody(request);

    log("sending request with:");
    log("method: $method");
    log("path: $path");
    log("body: $body");

    final String encodedTimestamp = Uri.encodeFull(timestamp);
    final String encodedPublicKey = RSAHelper().encodePublicKeyToString(publicKey);
    String authorizationHeader = signMessage(RsaKeyStore().privateKey! , "$method#$path#$timestamp#$body");

    request.headers['x-auth-signature'] = authorizationHeader;
    request.headers['x-auth-timestamp'] = encodedTimestamp;
    request.headers['x-public-key'] = encodedPublicKey;

    final http.StreamedResponse response = await _client.send(request);
    final int statusCode = response.statusCode;

    if (statusCode >= 400 || statusCode < 500) {

    }

    log("x-auth-signature: $authorizationHeader");
    log("x-auth-timestamp: $encodedTimestamp");
    log("x-public-key: $encodedPublicKey");

    return _client.send(request);
  }

  String signMessage(RSAPrivateKey privateKey, String message){
    Uint8List sourceBytes = Uint8List.fromList(utf8.encode(message));

    return enc.RSASigner(enc.RSASignDigest.SHA256, privateKey: privateKey).sign(sourceBytes).base64;
  }

  String encryptStringWithPrivateKey(String plaintext) {
    final encrypter = RSAEngine()
      ..init(true, PrivateKeyParameter<RSAPrivateKey>(
          RsaKeyStore().privateKey as PrivateKey));

    final input = Uint8List.fromList(utf8.encode(plaintext));
    final encrypted = encrypter.process(input);

    return base64.encode(encrypted);
  }

  String _getBody(http.BaseRequest request){
    String bodyJson = '{}';
    if( request is http.Request){
      if(request.body.isNotEmpty){
        bodyJson = request.body;
      }
    }
    return bodyJson;
  }
}

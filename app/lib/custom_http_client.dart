import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
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
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    log("PublicKey: ${RsaKeyStore().publicKey}");
    var publicKey = RsaKeyStore().publicKey;

    if (publicKey == null) {
      return _client.send(request);
    }

    String timestamp = DateTime.now().toIso8601String();
    String endpoint = request.url.toString();
    String requestHash = hashRequest(request);

    // Encode headers
    String encodedTimestamp = Uri.encodeFull(timestamp);
    String encodedEndpoint = Uri.encodeFull(endpoint);
    String encodedRequestHash = Uri.encodeFull(requestHash);
    String encodedPublicKey = Uri.encodeFull(RSAHelper().encodePublicKeyToString(publicKey));

    // header
    String authorizationHeader = encryptStringWithPrivateKey(encodedTimestamp + encodedEndpoint + encodedRequestHash);

    String publicKeyHeader = encodedPublicKey;

    // todo: authorizationHeader mit RsaKeyStore.privateKey verschlüsseln

    log("authorizationHeader: $authorizationHeader");
    log("publicKeyHeader: $publicKeyHeader");

    request.headers['Authorization'] = authorizationHeader;
    request.headers['x-public-key'] = publicKeyHeader;
    log("Send request");
    print(request.headers);
    return _client.send(request);
  }

  String hashRequest(http.BaseRequest request) {
    List<int> requestBytes = utf8.encode(request.toString());
    var hashedRequest = sha256.convert(requestBytes);
    return hashedRequest.toString();
  }

  String encryptStringWithPrivateKey(String plaintext) {
    final encrypter = RSAEngine()..init(true, PrivateKeyParameter<RSAPrivateKey>(RsaKeyStore().privateKey as PrivateKey));

    final input = Uint8List.fromList(utf8.encode(plaintext));
    final encrypted = encrypter.process(input);

    return base64.encode(encrypted);
  }

}
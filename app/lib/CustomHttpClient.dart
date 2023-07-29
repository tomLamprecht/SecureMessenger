import 'dart:convert';
import 'dart:developer';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_test/services/files/RSAHelper.dart';
import 'package:my_flutter_test/services/stores/RsaKeyStore.dart';


class CustomHttpClient extends http.BaseClient {
  static final CustomHttpClient _instance = CustomHttpClient._();
  factory CustomHttpClient() => _instance;

  final http.Client _client = http.Client();

  CustomHttpClient._();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    String timestamp = DateTime.now().toIso8601String();
    String endpoint = request.url.toString();
    String requestHash = hashRequest(request);

    // Encode headers
    String encodedTimestamp = Uri.encodeFull(timestamp);
    String encodedEndpoint = Uri.encodeFull(endpoint);
    String encodedRequestHash = Uri.encodeFull(requestHash);
    String encodedPublicKey = Uri.encodeFull(RSAHelper().encodePublicKeyToString(RsaKeyStore().publicKey));

    // header
    String authorizationHeader = encodedTimestamp + encodedEndpoint + encodedRequestHash;

    String publicKeyHeader = encodedPublicKey;

    // todo: authorizationHeader mit RsaKeyStore.privateKey verschlüsseln

    log("authorizationHeader: $authorizationHeader");
    log("publicKeyHeader: $publicKeyHeader");

    request.headers['Authorization'] = authorizationHeader;
    request.headers['x-public-key'] = publicKeyHeader;

    return _client.send(request);
  }

  String hashRequest(http.BaseRequest request) {
    List<int> requestBytes = utf8.encode(request.toString());
    var hashedRequest = sha256.convert(requestBytes);
    return hashedRequest.toString();
  }

}
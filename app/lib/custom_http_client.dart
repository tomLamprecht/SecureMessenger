import 'package:http/http.dart' as http;
import 'package:securemessenger/services/stores/ecc_key_store.dart';

import 'services/files/ecc_helper.dart';

class CustomHttpClient extends http.BaseClient {
  static final CustomHttpClient _instance = CustomHttpClient._();
  factory CustomHttpClient() => _instance;

  final http.Client _client = http.Client();
  final eccHelper = ECCHelper();

  CustomHttpClient._();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (EccKeyStore().publicKey == null) {
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

    final publicKeyHeader = eccHelper.encodePubKeyForBackend(EccKeyStore().publicKey!);
    final signature = _generateSignature(payload);


    request.headers.addAll({
      'x-auth-timestamp': timestamp,
      'x-public-key': publicKeyHeader,
      'x-auth-signature': signature
    });

    return _client.send(request);
  }

  String _generateSignature(String payload) {
    return eccHelper.sign(EccKeyStore().privateKey!, payload);
  }
}

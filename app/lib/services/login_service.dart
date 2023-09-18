import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:securemessenger/custom_http_client.dart';
import 'package:securemessenger/services/api/api_config.dart';
import 'package:securemessenger/services/files/cert_file_handler.dart';
import 'package:securemessenger/services/files/ecc_helper.dart';
import 'package:securemessenger/services/stores/ecc_key_store.dart';
import 'package:securemessenger/services/stores/who_am_i_store.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/export.dart';


Future<bool> requestAndSaveWhoAmI() async {

  final url = Uri.parse('${ApiConfig.httpBaseUrl}/accounts/whoami');
  final headers = {'Content-Type': 'application/json'};
  final response = await CustomHttpClient().get(url, headers: headers);

  if (response.statusCode == 200) {
    var jsonBody = json.decode(response.body);

    WhoAmIStore().accountId = jsonBody['id'];
    WhoAmIStore().username = jsonBody['userName'];
    WhoAmIStore().publicKey = jsonBody['publicKey'];
    return true;
  }
  return false;
}

Future<bool> signIn(Map<String, dynamic> data) async {
  String keyPairPemEncrypted = data["keyPairPemEncrypted"];
  String password = data["password"];
  String keyPairPem = CertFileHandler().decryptFileContentByPassword(keyPairPemEncrypted, password);

  EccKeyStore().privateKey = ECCHelper().parsePrivateKeyFromHexString(keyPairPem);
  EccKeyStore().publicKey = EccKeyStore().privateKey!.publicKey;

  return await requestAndSaveWhoAmI();
}

String? _extract(String content, String from, String to) {
  int startIndex = content.indexOf(from);
  int endIndex = content.indexOf(to) + to.length;

  if (startIndex != -1 && endIndex != -1) {
    return content.substring(startIndex, endIndex);
  }
  return null;
}

RSAPublicKey parsePublicKey(String fileContent) {
  var publicKey = _extract(fileContent, "-----BEGIN RSA PUBLIC KEY-----", "-----END PUBLIC KEY-----");
  return RSAKeyParser().parse(publicKey!) as RSAPublicKey;
}

RSAPrivateKey parsePrivateKey(String fileContent) {
  var privateKey = _extract(fileContent, "-----BEGIN RSA PRIVATE KEY-----", "-----END PRIVATE KEY-----");
  return RSAKeyParser().parse(privateKey!) as RSAPrivateKey;
}
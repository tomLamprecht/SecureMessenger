import 'dart:convert';
import 'dart:developer';

import 'package:encrypt/encrypt.dart';
import 'package:my_flutter_test/custom_http_client.dart';
import 'package:my_flutter_test/services/api/api_config.dart';
import 'package:my_flutter_test/services/files/cert_file_handler.dart';
import 'package:my_flutter_test/services/stores/rsa_key_store.dart';
import 'package:my_flutter_test/services/stores/who_am_i_store.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/export.dart';


Future<void> requestAndSaveWhoAmI() async {

  final url = Uri.parse('${ApiConfig.httpBaseUrl}/accounts/whoami');
  final headers = {'Content-Type': 'application/json'};


  final response = await CustomHttpClient().get(url, headers: headers);

  if (response.statusCode == 200) {
    var jsonbody = json.decode(response.body);

    WhoAmIStore().accountId = jsonbody['accountId'];
    WhoAmIStore().username = jsonbody['userName'];
    WhoAmIStore().publicKey = jsonbody['publicKey'];
    log("Successfully requested Account Information from backend (username = ${WhoAmIStore().username})");
  }else{
    throw Exception("Could not request Account Information from Backend");
  }

}

bool signIn(Map<String, dynamic> data) {
  String keyPairPemEncrypted = data["keyPairPemEncrypted"];
  String password = data["password"];
  String keyPairPem = CertFileHandler().decryptFileContentByPassword(keyPairPemEncrypted, password);

  RsaKeyStore().publicKey = parsePublicKey(keyPairPem);
  RsaKeyStore().privateKey = parsePrivateKey(keyPairPem);
  return true;
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
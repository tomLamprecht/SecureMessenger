import 'dart:developer';

import 'package:encrypt/encrypt.dart';
import 'package:my_flutter_test/services/files/cert_file_handler.dart';
import 'package:my_flutter_test/services/stores/rsa_key_store.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/export.dart';

bool signIn(String keyPairPemEncrypted, String password) {
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
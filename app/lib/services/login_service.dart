import 'package:my_flutter_test/services/auth_data.dart';
import 'package:my_flutter_test/services/files/certFileHandler.dart';

bool signIn(String keyPairPemEncrypted, String password) {
  String keyPairPem = CertFileHandler().decryptFileContentByPassword(keyPairPemEncrypted, password);
  AuthData ds = AuthData();
  ds.publicKey = _extract(keyPairPem, "-----BEGIN PUBLIC KEY-----\r\n", "\r\n-----END PUBLIC KEY-----");
  ds.privateKey = _extract(keyPairPem, "-----BEGIN PRIVATE KEY-----\r\n", "\r\n-----END PRIVATE KEY-----");
  return ds.publicKey != null && ds.privateKey != null;
}

String? _extract(String content, String from, String to) {
  int startIndex = content.indexOf(from);
  int endIndex = content.indexOf(to, startIndex + from.length);

  if (startIndex != -1 && endIndex != -1) {
    return content.substring(startIndex + from.length, endIndex);
  }

  return null;
}
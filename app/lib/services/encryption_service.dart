import 'package:encrypt/encrypt.dart';

String aesEncrypt(String plainText, String base64Key) {
  final key = Key.fromUtf8(base64Key);
  final iv = IV.fromLength(16);

  final encrypter = Encrypter(AES(key, mode: AESMode.ecb));
  final encrypted = encrypter.encrypt(plainText, iv: iv);

  return encrypted.base64;
}

String aesDecrypt(String base64Encrypted, String base64Key) {
  final key = Key.fromUtf8(base64Key);
  final iv = IV.fromLength(16);

  final encrypter = Encrypter(AES(key, mode: AESMode.ecb));
  final encrypted = Encrypted.fromBase64(base64Encrypted);

  return encrypter.decrypt(encrypted, iv: iv);
}
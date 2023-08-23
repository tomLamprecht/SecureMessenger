import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

const int aesKeyLengthInBits = 256;

String aesEncrypt(String plainText, String base64Key) {
  final key = Key.fromBase64(base64Key);
  final iv = IV.fromLength(aesKeyLengthInBits);

  final encrypter = Encrypter(AES(key, mode: AESMode.ecb));
  final encrypted = encrypter.encrypt(plainText, iv: iv);

  return encrypted.base64;
}

String aesDecrypt(String base64Encrypted, String base64Key) {
  final key = Key.fromBase64(base64Key);
  final iv = IV.fromLength(aesKeyLengthInBits);

  final encrypter = Encrypter(AES(key, mode: AESMode.ecb));
  final encrypted = Encrypted.fromBase64(base64Encrypted);

  return encrypter.decrypt(encrypted, iv: iv);
}

String createRandomBase64Key() {
  final Random _random = Random.secure();
  final Uint8List randomBytes =
      Uint8List(aesKeyLengthInBits ~/ 8); // Convert bit length to byte length
  for (int i = 0; i < randomBytes.length; i++) {
    randomBytes[i] = _random.nextInt(256);
  }
  return base64Encode(randomBytes);
}
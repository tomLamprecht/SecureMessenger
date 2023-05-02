import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'dart:convert';

import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/macs/hmac.dart';

class CertFileHandler {

  String encryptFileContentByPassword(String fileContent, String password) {
    final encrypter = _getEncrypter(password);
    final IV _iv = IV.fromLength(16); // 128-bit IV
    final encrypted = encrypter.encrypt(fileContent, iv: _iv);
    return encrypted.base64;
  }

  String decryptFileContentByPassword(String fileContent, String password) {
    final encrypter = _getEncrypter(password);
    final IV _iv = IV.fromLength(16); // 128-bit IV
    final encrypted = Encrypted.fromBase64(fileContent);
    return encrypter.decrypt(encrypted, iv: _iv);
  }

  Encrypter _getEncrypter(String password) {
    final iterations = 10000;
    final keyLength = 32; // 256-bit key
    final kdf = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(Uint8List(0), iterations, keyLength));

    final keyBytes = kdf.process(Uint8List.fromList(utf8.encode(password)));
    final key = Key(keyBytes);
    return Encrypter(AES(key));
  }
}

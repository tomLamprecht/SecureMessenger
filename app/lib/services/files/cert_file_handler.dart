import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:my_flutter_test/models/keypair.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';

import 'download_service.dart';


class CertFileHandler {

  String encryptFileContentByPassword(String fileContent, String password) {
    final encrypter = _getEncrypter(password);
    final encrypt.IV _iv = encrypt.IV.fromLength(16); // 128-bit IV
    final encrypted = encrypter.encrypt(fileContent, iv: _iv);
    return encrypted.base64;
  }

  String decryptFileContentByPassword(String fileContent, String password) {
    final encrypter = _getEncrypter(password);
    final encrypt.IV _iv = encrypt.IV.fromLength(16); // 128-bit IV
    final encrypted = encrypt.Encrypted.fromBase64(fileContent);
    return encrypter.decrypt(encrypted, iv: _iv);
  }

  encrypt.Encrypter _getEncrypter(String password) {
    final iterations = 10000;
    final keyLength = 32; // 256-bit key
    final kdf = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(Uint8List(0), iterations, keyLength));

    final keyBytes = kdf.process(Uint8List.fromList(utf8.encode(password)));
    final key = encrypt.Key(keyBytes);
    return encrypt.Encrypter(encrypt.AES(key));
  }



  Future<void> downloadFile(String value, String filename) async {
    DownloadService downloadService = kIsWeb ? WebDownloadService() : MobileDownloadService();

    // Encode the value string to UTF-8 bytes
    List<int> valueBytes = utf8.encode(value);

    await downloadService.download(
      text: value,
      filename: filename,
    );
  }

  Future<void> downloadCertificate(Keypair keyPair, String fileName, String password) async {
    var privateKey = keyPair.privateKey;

    // Encrypt the value with AES using the password as the encryption key
    var encryptedValue = encryptFileContentByPassword(privateKey.toHex(), password);

    await downloadFile(encryptedValue, fileName);
  }



}
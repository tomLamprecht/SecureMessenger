import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:securemessenger/models/keypair.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'download_service/download_service.dart';

class CertFileHandler {

  late final DownloadService _downloadService;

  CertFileHandler(){
    _downloadService = DownloadService.instance;
  }


  String encryptFileContentByPassword(String fileContent, String password) {
    final encrypter = _getEncrypter(password);
    final encrypt.IV iv = encrypt.IV.fromLength(16); // 128-bit IV
    final encrypted = encrypter.encrypt(fileContent, iv: iv);
    return encrypted.base64;
  }

  String decryptFileContentByPassword(String fileContent, String password) {
    final encrypter = _getEncrypter(password);
    final encrypt.IV iv = encrypt.IV.fromLength(16); // 128-bit IV
    final encrypted = encrypt.Encrypted.fromBase64(fileContent);
    return encrypter.decrypt(encrypted, iv: iv);
  }

  encrypt.Encrypter _getEncrypter(String password) {
    const iterations = 10000;
    const keyLength = 32; // 256-bit key
    final kdf = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(Uint8List(0), iterations, keyLength));

    final keyBytes = kdf.process(Uint8List.fromList(utf8.encode(password)));
    final key = encrypt.Key(keyBytes);
    return encrypt.Encrypter(encrypt.AES(key));
  }



  Future<void> downloadFile(String value, String filename) async {
    await _downloadService.download(
      text: value,
      filename: filename,
    );
  }

  Future<void> downloadCertificate(Keypair keyPair, String fileName, String password) async {
    var privateKey = keyPair.privateKey;

    var encryptedValue = encryptFileContentByPassword(privateKey.toHex(), password);

    await downloadFile(encryptedValue, fileName);
  }
}
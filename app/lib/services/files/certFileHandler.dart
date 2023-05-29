import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';

import 'dart:convert';

import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/macs/hmac.dart';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';

import 'RSAHelper.dart';

import 'DownloadService.dart';



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


  Future<AsymmetricKeyPair<PublicKey, PrivateKey>> generateRSAKeyPair() async {
    var certificate = RSAHelper();
    return certificate.getRSAKeyPair(certificate.getSecureRandom());
  }

  Future<void> downloadFile(String value, String filename) async {
    DownloadService downloadService =
    kIsWeb ? WebDownloadService() : MobileDownloadService();
    await downloadService.download(text: value, filename: filename);
  }

  ///  Generates a private and public key and encrypts it using the given password. It will provide a download for the encrypted Certificate including
  ///  private and public key and returning the non-encrypted public key.
  Future<String> generateAndDownloadEncryptedCert(String password) async {
    var keyPair = await generateRSAKeyPair();

    var publicKeyPEM = RSAHelper()
        .encodePublicKeyToPemPKCS1(keyPair.publicKey as RSAPublicKey);

    var privateKeyPEM = RSAHelper().encodePrivateKeyToPemPKCS1(
        keyPair.privateKey as RSAPrivateKey);

    String keyPairPEM = "$publicKeyPEM\n$privateKeyPEM";

    String encryptedKeyPairPEM = encryptFileContentByPassword(keyPairPEM, password);

    downloadFile(encryptedKeyPairPEM, "privateKey.pem");

    return publicKeyPEM;
  }


}

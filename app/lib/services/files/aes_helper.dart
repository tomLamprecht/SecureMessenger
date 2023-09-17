import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class AesHelper {
  static String encrypt(String value, String password) {
    var key = Key(Uint8List.fromList(utf8.encode(password)));
    var digest = sha256.convert(key.bytes).bytes;

    var iv = IV.fromSecureRandom(16); // 16 bytes IV for AES-128

    var plaintextBytes = Uint8List.fromList(utf8.encode(value));

    var encrypter = Encrypter(AES(Key(Uint8List.fromList(digest))));
    var encrypted = encrypter.encryptBytes(plaintextBytes, iv: iv);

    var encryptedData = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
    return base64.encode(encryptedData);
  }

  static String decrypt(String value, String password) {
    var key = Key(Uint8List.fromList(utf8.encode(password)));
    var digest = sha256.convert(key.bytes).bytes;

    var encryptedData = base64.decode(value);

    var iv = IV(Uint8List.sublistView(encryptedData, 0, 16)); // 16 bytes IV for AES-128
    var ciphertext = Uint8List.sublistView(encryptedData, 16);

    var encrypter = Encrypter(AES(Key(Uint8List.fromList(digest))));
    var decryptedBytes = encrypter.decryptBytes(Encrypted(ciphertext), iv: iv);

    return utf8.decode(decryptedBytes);
  }

  static String createRandomBase64Key({int bitLength = 256}) {
    if (![128, 192, 256].contains(bitLength)) {
      throw ArgumentError('Invalid key length for AES: $bitLength');
    }

    final Random random = Random.secure();
    final Uint8List randomBytes =
    Uint8List(bitLength ~/ 8);
    for (int i = 0; i < randomBytes.length; i++) {
      randomBytes[i] = random.nextInt(256);
    }
    return base64Encode(randomBytes);
  }
}

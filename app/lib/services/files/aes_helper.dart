import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class AesHelper {
  static String encrypt(String value, String password) {
    // Use the password to derive an encryption key
    var key = Key(Uint8List.fromList(utf8.encode(password)));
    var digest = sha256.convert(key.bytes).bytes;

    // Generate a random initialization vector (IV)
    var iv = IV.fromSecureRandom(16); // 16 bytes IV for AES-128

    // Convert the plaintext to bytes
    var plaintextBytes = Uint8List.fromList(utf8.encode(value));

    // Encrypt the plaintext with AES using the derived key and IV
    var encrypter = Encrypter(AES(Key(Uint8List.fromList(digest))));
    var encrypted = encrypter.encryptBytes(plaintextBytes, iv: iv);

    // Combine the IV and the encrypted ciphertext, then return as a base64-encoded string
    var encryptedData = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
    return base64.encode(encryptedData);
  }

  static String decrypt(String value, String password) {
    // Use the password to derive an encryption key
    var key = Key(Uint8List.fromList(utf8.encode(password)));
    var digest = sha256.convert(key.bytes).bytes;

    // Decode the base64-encoded input value to bytes
    var encryptedData = base64.decode(value);

    // Extract the IV and encrypted ciphertext from the input bytes
    var iv = IV(Uint8List.sublistView(encryptedData, 0, 16)); // 16 bytes IV for AES-128
    var ciphertext = Uint8List.sublistView(encryptedData, 16);

    // Decrypt the ciphertext with AES using the derived key and IV
    var encrypter = Encrypter(AES(Key(Uint8List.fromList(digest))));
    var decryptedBytes = encrypter.decryptBytes(Encrypted(ciphertext), iv: iv);

    // Convert the decrypted bytes to a UTF-8 encoded string and return
    return utf8.decode(decryptedBytes);
  }
}

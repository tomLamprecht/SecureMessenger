import "package:pointycastle/export.dart";

class RsaKeyStore {
  static final RsaKeyStore _instance = RsaKeyStore._();

  factory RsaKeyStore() => _instance;

  late RSAPublicKey _publicKey;
  late RSAPrivateKey _privateKey;

  RsaKeyStore._();

  RSAPublicKey get publicKey => _publicKey;

  set publicKey(RSAPublicKey publicKey) {
    _publicKey = publicKey;
  }

  RSAPrivateKey get privateKey => _privateKey;

  set privateKey(RSAPrivateKey publicKey) {
    _privateKey = privateKey;
  }
}

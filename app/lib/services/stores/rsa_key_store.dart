import "package:pointycastle/asymmetric/api.dart";

class RsaKeyStore {
  static final RsaKeyStore _instance = RsaKeyStore._();

  factory RsaKeyStore() => _instance;

  RSAPublicKey? publicKey;
  RSAPrivateKey? privateKey;

  RsaKeyStore._();

}

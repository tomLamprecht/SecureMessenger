
import 'package:elliptic/elliptic.dart';

class EccKeyStore {
  static final EccKeyStore _instance = EccKeyStore._();

  factory EccKeyStore() => _instance;

  PublicKey? publicKey;
  PrivateKey? privateKey;

  EccKeyStore._();
}

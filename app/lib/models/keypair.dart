import 'package:elliptic/elliptic.dart';

class Keypair{
  PrivateKey privateKey;
  PublicKey publicKey;

  Keypair(this.privateKey, this.publicKey);
}
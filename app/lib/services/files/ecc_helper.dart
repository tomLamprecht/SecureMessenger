import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_flutter_test/services/files/rsa_helper.dart';
import 'package:pointycastle/export.dart';

class ECCHelper{

  final ECDomainParameters _params = ECCurve_secp256k1();

  AsymmetricKeyPair<PublicKey, PrivateKey> generateKeyPair() {
    final keyGen = ECKeyGenerator()
      ..init(ParametersWithRandom(
          ECKeyGeneratorParameters(_params), getSecureRandomECC() // Seed
      ));

    return keyGen.generateKeyPair();
  }

  getSecureRandomECC(){
    final aes = AESFastEngine();
    final secureRandom = BlockCtrRandom(aes);
    secureRandom.seed(KeyParameter(Uint8List.fromList(
        List.generate(16, (index) => index + 1) // Seed for BlockCtrRandom
    )));
  }

  Signature signMessage(ECPrivateKey privateKey, String message) {
    final signer = Signer('SHA-256/ECDSA')
      ..init(true, PrivateKeyParameter(privateKey));

    final signature = signer.generateSignature(Uint8List.fromList(utf8.encode(message)));
    return signature;
  }


}
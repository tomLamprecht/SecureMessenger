import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import "package:pointycastle/export.dart";
import "package:asn1lib/asn1lib.dart";


class RSAHelper {
  static final BigInt _publicExponent = BigInt.parse('65537');
  static const int _keyLength = 2048;
  static const int _certainty = 4; // https://crypto.stackexchange.com/questions/15449/rsa-key-generation-parameters-public-exponent-certainty-string-to-key-count


  RSAHelper();

  Future<AsymmetricKeyPair<PublicKey, PrivateKey>?> getRSAKeyPair(SendPort sendPort) async {
    var keyPair = computeRSAKeyPair(getSecureRandom());
    sendPort.send(keyPair);
    return null;
  }

  SecureRandom getSecureRandom() {
    var secureRandom = FortunaRandom();
    var random = Random.secure();
    List<int> seeds = [];
    for (int i = 0; i < 32; i++) {
      seeds.add(random.nextInt(255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    return secureRandom;
  }

  String encodePublicKeyToString(RSAPublicKey publicKey) {
    var topLevel = ASN1Sequence();

    topLevel.add(ASN1Integer(publicKey.modulus!));
    topLevel.add(ASN1Integer(publicKey.exponent!));

    return base64.encode(topLevel.encodedBytes);
  }

  /// Encode Private key to PEM Format
  ///
  /// Given [RSAPrivateKey] returns a base64 encoded [String] with standard PEM headers and footers
  String encodePrivateKeyToPemPKCS1(RSAPrivateKey privateKey) {
    var encodedPrivateKey = encodePrivateKeyToString(privateKey);

    return """-----BEGIN RSA PRIVATE KEY-----\n$encodedPrivateKey\n-----END PRIVATE KEY-----""";
  }

  /// Encode Public key to PEM Format
  ///
  /// Given [RSAPublicKey] returns a base64 encoded [String] with standard PEM headers and footers
  String encodePublicKeyToPemPKCS1(RSAPublicKey publicKey) {
    var encodedPublicKey = encodePublicKeyToString(publicKey);
    return """-----BEGIN RSA PUBLIC KEY-----\n$encodedPublicKey\n-----END PUBLIC KEY-----""";
  }

  String encodePrivateKeyToString(RSAPrivateKey privateKey) {
    var topLevel = ASN1Sequence();

    var version = ASN1Integer(BigInt.from(0));
    var modulus = ASN1Integer(privateKey.n!);
    var publicExponent = ASN1Integer(privateKey.exponent!);
    var privateExponent = ASN1Integer(privateKey.d!);
    var p = ASN1Integer(privateKey.p!);
    var q = ASN1Integer(privateKey.q!);
    var dP = privateKey.d! % (privateKey.p! - BigInt.from(1));
    var exp1 = ASN1Integer(dP);
    var dQ = privateKey.d! % (privateKey.q! - BigInt.from(1));
    var exp2 = ASN1Integer(dQ);
    var iQ = privateKey.q!.modInverse(privateKey.p!);
    var co = ASN1Integer(iQ);

    topLevel.add(version);
    topLevel.add(modulus);
    topLevel.add(publicExponent);
    topLevel.add(privateExponent);
    topLevel.add(p);
    topLevel.add(q);
    topLevel.add(exp1);
    topLevel.add(exp2);
    topLevel.add(co);

    return base64.encode(topLevel.encodedBytes);
  }

}


AsymmetricKeyPair<PublicKey, PrivateKey> computeRSAKeyPair(
    SecureRandom secureRandom) {
  var rsapars = RSAKeyGeneratorParameters(RSAHelper._publicExponent, RSAHelper._keyLength, RSAHelper._certainty);
  var params = ParametersWithRandom(rsapars, secureRandom);
  var keyGenerator = RSAKeyGenerator();
  keyGenerator.init(params);
  return keyGenerator.generateKeyPair();
}




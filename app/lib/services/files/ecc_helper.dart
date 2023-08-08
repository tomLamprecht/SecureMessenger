import 'dart:convert';

import 'package:asn1lib/asn1lib.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:ecdsa/ecdsa.dart';
import 'package:elliptic/elliptic.dart' as ecc;
import 'package:my_flutter_test/models/keypair.dart';
import 'package:pointycastle/ecc/curves/secp256r1.dart';

class ECCHelper {
  String _encodeEcPublicKeyToPem(ECPublicKey publicKey) {
    ASN1ObjectIdentifier.registerFrequentNames();
    var outer = ASN1Sequence();
    var algorithm = ASN1Sequence();
    algorithm.add(ASN1ObjectIdentifier.fromName('ecPublicKey'));
    algorithm.add(ASN1ObjectIdentifier.fromName('prime256v1'));
    var subjectPublicKey = ASN1BitString(publicKey.Q!.getEncoded(false));

    outer.add(algorithm);
    outer.add(subjectPublicKey);
    var dataBase64 = base64.encode(outer.encodedBytes);
    var chunks = StringUtils.chunk(dataBase64, 64);

    return chunks.join();
  }

  Keypair generateKeyPair() {
    var ec = ecc.getP256();
    var priv = ec.generatePrivateKey();
    var pub = priv.publicKey;
    return Keypair(priv, pub);
  }

  String encodePubKeyForBackend(ecc.PublicKey pub) {
    var point = ECCurve_secp256r1().curve.createPoint(pub.X, pub.Y);
    var par = ECDomainParameters("secp256r1");
    var pointyCastlePK = ECPublicKey(point, par);
    return _encodeEcPublicKeyToPem(pointyCastlePK);
  }

  String sign(ecc.PrivateKey privateKey, String content) {
    var hashHex = _convertToHashHex(content);
    var hash = List<int>.generate(hashHex.length ~/ 2,
        (i) => int.parse(hashHex.substring(i * 2, i * 2 + 2), radix: 16));

    var sig = signature(privateKey, hash);
    return base64Encode(sig.toASN1());
  }

  ecc.PrivateKey parsePrivateKeyFromHexString(String hex) {
    return ecc.PrivateKey.fromHex(ecc.getP256(), hex);
  }

  String _convertToHashHex(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

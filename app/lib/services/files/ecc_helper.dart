import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:ecdsa/ecdsa.dart';
import 'package:elliptic/ecdh.dart';
import 'package:elliptic/elliptic.dart' as ecc;
import 'package:securemessenger/models/keypair.dart';
import 'package:securemessenger/services/encryption_service.dart';
import 'package:securemessenger/services/stores/ecc_key_store.dart';
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
    ECPublicKey pointyCastlePK = eccPublicKeyToPointyCastlePublicKey(pub);
    return _encodeEcPublicKeyToPem(pointyCastlePK);
  }

  ECPublicKey eccPublicKeyToPointyCastlePublicKey(ecc.PublicKey pub) {
    var point = ECCurve_secp256r1().curve.createPoint(pub.X, pub.Y);
    var par = ECDomainParameters("secp256r1");
    var pointyCastlePK = ECPublicKey(point, par);
    return pointyCastlePK;
  }

  String sign(ecc.PrivateKey privateKey, String content) {
    var hashHex = _convertToHashHex(content);
    var hash = List<int>.generate(hashHex.length ~/ 2,
        (i) => int.parse(hashHex.substring(i * 2, i * 2 + 2), radix: 16));

    var sig = signature(privateKey, hash);

    return base64Encode(sig.toASN1());
  }

  String encodeWithPubKey(ecc.PublicKey publicKey, String content) {
   return encryptForPkByAESAndECDH(eccPublicKeyToPointyCastlePublicKey(publicKey), content);
  }

  String encryptWithPubKeyStringUsingECDH(String publicKey, String content) {
    var key = publicKeyFromBase64String(publicKey);

    return encryptForPkByAESAndECDH(key, content);

  }

  String encryptForPkByAESAndECDH(ECPublicKey key, String content) {
    var secret = computeSecretHex(EccKeyStore().privateKey!, fromPointyCastlePkToEllipticPk(key));
    var sharedKey = sha256.convert(utf8.encode(secret));

    return aesEncrypt(content, base64.encode(sharedKey.bytes) );
  }

  ecc.PublicKey fromPointyCastlePkToEllipticPk(ECPublicKey key) {
     return ecc.PublicKey.fromPoint(ecc.getP256(), ecc.AffinePoint.fromXY(key.Q!.x!.toBigInteger()!, key.Q!.y!.toBigInteger()!));
  }

  String decryptByAESAndECDHUsingString(String key, String cypher){
    var keyObj = publicKeyFromBase64String(key);

    return decryptByAESAndECDH(keyObj, cypher);
  }

  String decryptByAESAndECDH(ECPublicKey key, String cypher){
    ecc.PublicKey public = fromPointyCastlePkToEllipticPk(key);
    var secret = computeSecretHex(EccKeyStore().privateKey!, public);
    var sharedKey = sha256.convert(utf8.encode(secret));
    
    return aesDecrypt(cypher, base64.encode(sharedKey.bytes));
  }

  ECPublicKey publicKeyFromBase64String(String base64String) {
    final publicKeyBytes = base64Decode(base64String.replaceAll("\n", "").replaceAll("\r", ""));

    final asn1Parser = ASN1Parser(Uint8List.fromList(publicKeyBytes));
    final outer = asn1Parser.nextObject() as ASN1Sequence;


    final publicKeyBitString = outer.elements[1] as ASN1BitString;
    final publicKeyAsBytes = publicKeyBitString.stringValue as Uint8List;

    final params = ECDomainParameters("secp256r1");
    final curve = params.curve;
    final point = curve.decodePoint(publicKeyAsBytes);

    return ECPublicKey(point, params);
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

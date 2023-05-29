import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';

import 'DownloadService.dart';
import 'RSAHelper.dart';

class RSAKeyPairWidget extends StatefulWidget {
  const RSAKeyPairWidget({super.key});

  @override
  _RSAKeyPairWidgetState createState() => _RSAKeyPairWidgetState();
}

class _RSAKeyPairWidgetState extends State<RSAKeyPairWidget> {
  Future<AsymmetricKeyPair<PublicKey, PrivateKey>>? keyPair;
  String _publicKeyPEM = "";
  String _privateKeyPEM = "";

  Future<AsymmetricKeyPair<PublicKey, PrivateKey>> generateRSAKeyPair() async {
    var certificate = RSAHelper();
    return certificate.getRSAKeyPair(certificate.getSecureRandom());
  }

  Future<void> downloadFile(String value, String filename) async {
    DownloadService downloadService =
        kIsWeb ? WebDownloadService() : MobileDownloadService();
    await downloadService.download(text: value, filename: filename);
  }

  Future<void> buttonGenerateKeyPair() async {
    setState(() {
      generateRSAKeyPair().then((value) => {
            setState(() {
              _publicKeyPEM = RSAHelper()
                  .encodePublicKeyToPemPKCS1(value.publicKey as RSAPublicKey);
              _privateKeyPEM += RSAHelper().encodePrivateKeyToPemPKCS1(
                  value.privateKey as RSAPrivateKey);
            })
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RSA Key Pair Widget'),
      ),
      body: Column(
        children: <Widget>[
          Center(
            child: ElevatedButton(
              onPressed: buttonGenerateKeyPair,
              child: Text('Generate RSA Key Pair (This may take some time)'),
            ),
          ),
          if(_publicKeyPEM.isNotEmpty) ElevatedButton(onPressed: (){downloadFile(_publicKeyPEM, "publicKey.pem");}, child: const Text("Download Public Key")),
          if(_privateKeyPEM.isNotEmpty) ElevatedButton(onPressed: (){downloadFile(_privateKeyPEM, "privateKey.pem");}, child: const Text("Download Private Key")),
        ],
      ),
    );
  }
}

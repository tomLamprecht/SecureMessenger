import 'dart:async';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/basic.dart' as flutter_widgets;
import 'package:my_flutter_test/services/register_service.dart';
import 'package:my_flutter_test/services/captcha_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';

import '../services/files/download_service.dart';
import '../services/files/rsa_helper.dart';
import '../services/files/cert_file_handler.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _userNameController;
  late TextEditingController _certPasswordController;
  late TextEditingController _captchaController;
  late String _captchaId;
  late CaptchaService _captchaService;
  late RegistrationService _registrationService;
  late String _privateKey = "";
  late String _publicKey = "";
  final _certFileHandler = CertFileHandler();

  final ValueNotifier<bool> _isDownloadButtonEnabled = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController();
    _certPasswordController = TextEditingController();
    _captchaController = TextEditingController();
    _captchaId = '';
    _captchaService = CaptchaService();
    _registrationService = RegistrationService();
    _certPasswordController.addListener(_onTextFieldChanged);
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  void _onTextFieldChanged() {
    _isDownloadButtonEnabled.value = _certPasswordController.text.isNotEmpty;
  }

  Future<AsymmetricKeyPair<PublicKey, PrivateKey>> generateRSAKeyPair() async {
    var certificate = RSAHelper();
    return certificate.getRSAKeyPair(certificate.getSecureRandom());
  }

   _encrypt(content, password) {
    return _certFileHandler.encryptFileContentByPassword(content, password);
  }

  Future<void> downloadAndEncryptFile(String value, String filename) async {
    value = _encrypt(value, _certPasswordController.text);

    DownloadService downloadService =
        kIsWeb ? WebDownloadService() : MobileDownloadService();
    await downloadService.download(text: value, filename: filename);
  }

  Future<void> computeKeyPair() async {
    setState(() {
      generateRSAKeyPair().then((value) => {
            setState(() {
              _publicKey = RSAHelper()
                  .encodePublicKeyToPemPKCS1(value.publicKey as RSAPublicKey);
              _privateKey += RSAHelper().encodePrivateKeyToPemPKCS1(
                  value.privateKey as RSAPrivateKey);
            })
          });
    });
  }

  void _generateKeys() {
    log("generate Keys...");
    setState(() {
      _publicKey =
          "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAt5EANZssAWw0M7oTMqj5Fmg+1zW2aP60+0GXom/SWmH/gxyvE2QbS5wnzBTKRHWJn2Y9DcMs2UJIM0Uh5a+Q0naoVpn9u9BwBq3f+Dj/BEzXp0eWJx5BZlJcFu+k9ERR3Db/DvlOcuI2ijgfoczJH2WLDWiu5/uUuuDV2bvxVxQUfseAKTIAfAaRKPhUPmIHTzr72DJ13/7ul8XKwxO8Ghg3fjZYU/4cGrGQUPznXA+Q9D7nesfMOPGC7JzVU1BC9ZYgLEewQRdzdi0URtYvHWwpIxQO+zHL2DhiOUTsF5ibj5xn3SW4Isbv/JMmdxTLG7es31WfdCeeHRFBPZuO1wIDAQAB";
      _privateKey =
          "MIIEpAIBAAKCAQEAt5EANZssAWw0M7oTMqj5Fmg+1zW2aP60+0GXom/SWmH/gxyvE2QbS5wnzBTKRHWJn2Y9DcMs2UJIM0Uh5a+Q0naoVpn9u9BwBq3f+Dj/BEzXp0eWJx5BZlJcFu+k9ERR3Db/DvlOcuI2ijgfoczJH2WLDWiu5/uUuuDV2bvxVxQUfseAKTIAfAaRKPhUPmIHTzr72DJ13/7ul8XKwxO8Ghg3fjZYU/4cGrGQUPznXA+Q9D7nesfMOPGC7JzVU1BC9ZYgLEewQRdzdi0URtYvHWwpIxQO+zHL2DhiOUTsF5ibj5xn3SW4Isbv/JMmdxTLG7es31WfdCeeHRFBPZuO1wIDAQABAoIBAGJYLduKWaYdeU4pJ3XhrylBCkG0Rhi0NPPTbVCaRgEkNYbhzC5AWJtGes/MZ50Lt4KNfLIt2Y5AA3xsUj/Csnz/Eyrqb1S60/nQF4jdyEpefL7jDF/Cxtjx0OJ820v+ejjXwggcqtnDteKRNOkzVKEcfsXdSq+ASmtgX1G6bg7vC3vcg26J9bI4ATtd/3eFd9by9lWYqLpg3d/9bnL+QqQb73UfnbZ6SDLvv3feFsbOPTbdZgc/X3gVxfK6Iun8xSzMbYnLtCG3bGMtdEhbP2EPxxPhWvR0Vtg64l3dQy2GR2eOsByh/xDHU93ebBOzTnzeACGoBFOhAJ1fDV+wkZkCgYEA5KiUiUm1zlCaam8Akz5a8Nx1OpKn7vMPsutpMlhVHAeTWmulvfG7B7L+o7gkxpYBsC/0xOCQLGTbKtu+GPsQaShMp0ECkf4W55LD3NiSrEQuqzab9vwNP3RjG3++w/quGiv3xUfrJiGYV+Tww6/yQh3isCGVmNfZqetW8kpUyisCgYEAzYQdfV9n3dL7m+DMgQJTKxgHMsifJsE79qRAbwd8IBDlapJZZyIx0uoM+1A8G2ac30OWvKU3ewbRQo+EVdDEcHv0/LhAgOEBPuHJRjQ44e4t5SPQLBPxOyPxUFB9glIdxwOECAtd4FeudjkzYrYbdDt5pqC3MkPtCbjqZxuY1AUCgYEAiqVVe3FAVds15jdsR9vVVJq4Uk2+mfqzmC9519cLtDU7ueXv156NY3u7PxZW5jrqxyQs7Hulr+Vvpysatxb0um5/HCMlJdTFmqC5Nl3zgZTOH267XyUx+zndJj1tNHP5wVDLqcmT4ckZEKJ3ApDa +hAY9edHSCgJiShzzfIYO4UCgYBe1QTKkliaSj3iCtQy/4CjFP5VV6/gsS/bOqWk1h5XqZRDHe71IRk+itOcr8RcnHfsqgKHX/F+6oFrJlBZTPEoOnqsltTk426wtn0q0PQihMZWwrTPchBRSt+SQOH5Xazx5VRqZdxWpf8R/IkSlpeKhds3oVeHcUKSxuoa0+gshQKBgQCtV0uHJ0ldpvmBJRPmMEkCJbd513nCoecaU6fDTL7tH1PzkFFVPUDTDiD3Y5ZZkk4VgKQ28QGpcV5E5SP6/wffCdyVrrJyRSV82cJXJM/yUSYuvesTkEkmpHyoKiImXL6FMsLl3A2tGrEcV343kBXGte9NM42tOA0VRWzBYjJl/A==";
    });
    computeKeyPair();
    log("Keys sucessfully generated");
  }

  Future<ImageProvider> _loadCaptchaImage() async {
    _captchaId = await _captchaService.getNewCaptcha();
    var image = await _captchaService.fetchCaptchaImage(_captchaId);
    return image;
  }

  Future<void> _registerUser() async {
    final userName = _userNameController.text;
    try {
      final response = await _registrationService.registerUser(
          captchaId: _captchaId,
          captchaTry: _captchaController.text,
          publicKey: _publicKey,
          userName: userName);
      if (response == 0) {
        throw Exception('Failed to register account.');
      }
      _redirectToChatOverview();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to register account: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _redirectToChatOverview() {
    // TODO: Navigate to chat overview screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: flutter_widgets.Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _generateKeys,
              child: const Text('Keys erzeugen'),
            ),
            const SizedBox(height: 16),
            if (_publicKey.isNotEmpty && _privateKey.isNotEmpty)
              ValueListenableBuilder(
                valueListenable: _isDownloadButtonEnabled,
                builder: (context, bool isDownloadButtonEnabled, child) {
                  return ElevatedButton(
                      onPressed: !isDownloadButtonEnabled
                          ? null
                          : () {
                              downloadAndEncryptFile('$_publicKey\n$_privateKey',
                                  "certificate.pem");
                            },
                      child: const Text("Download Certificate"));
                },
              ),
            TextField(
              controller: _certPasswordController,
              decoration: const InputDecoration(
                labelText: 'Certificate Password',
              ),
              keyboardType: TextInputType.visiblePassword,
              textCapitalization: TextCapitalization.words,
              maxLength: 50,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(
                labelText: 'Benutzername',
              ),
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              maxLength: 50,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
            ),
            const SizedBox(height: 32),
            FutureBuilder<ImageProvider>(
              future: _loadCaptchaImage(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return const Text('Failed to load captcha image');
                }
                return Stack(
                  children: [
                    SizedBox(
                      height: 120,
                      child: Image(
                        image: snapshot.data!,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            _captchaId = '';
                          });
                        },
                        tooltip: 'Neu laden',
                        child: Icon(Icons.refresh),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
                controller: _captchaController,
                decoration: const InputDecoration(
                  labelText: 'Captcha',
                ),
                maxLength: 7,
                maxLengthEnforcement: MaxLengthEnforcement.enforced),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _registerUser,
              child: const Text('Nutzer erstellen'),
            ),
          ],
        ),
      ),
    );
  }
}

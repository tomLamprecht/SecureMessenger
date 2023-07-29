import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/basic.dart' as flutter_widgets;
import 'package:my_flutter_test/services/register_service.dart';
import 'package:my_flutter_test/services/captcha_service.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_test/services/stores/rsa_key_store.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';

import '../services/files/cert_file_handler.dart';
import '../services/files/rsa_helper.dart';
import 'chat_overview_screen.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _userNameController;
  late TextEditingController _captchaController;
  late TextEditingController _certPasswordController;
  late String _captchaId;
  late CaptchaService _captchaService;
  late RegistrationService _registrationService;
  late String _publicKey;
  AsymmetricKeyPair<PublicKey, PrivateKey>? _keyPair;
  final _certFileHandler = CertFileHandler();

  final ValueNotifier<bool> _isDownloadButtonEnabled = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController();
    _captchaController = TextEditingController();
    _captchaController = TextEditingController();
    _captchaId = '';
    _captchaService = CaptchaService();
    _registrationService = RegistrationService();
    _certPasswordController = TextEditingController();
    _certPasswordController.addListener(_onTextFieldChanged);
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _certPasswordController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  void _onTextFieldChanged() {
    _isDownloadButtonEnabled.value = _certPasswordController.text.isNotEmpty;
  }

  Future _generateKeys() async {
    var rsaHelper = RSAHelper();
    _keyPair = await rsaHelper.getRSAKeyPair(rsaHelper.getSecureRandom());

    var encodedPublicKey = rsaHelper.encodePublicKeyToString(_keyPair!.publicKey as RSAPublicKey);
    _publicKey = encodedPublicKey;
  }

  Future<ImageProvider> _loadCaptchaImage() async {
    _captchaId = await _captchaService.getNewCaptcha();
    var image = await _captchaService.fetchCaptchaImage(_captchaId);
    return image;
  }

  Future<void> _registerUser() async {
    final userName = _userNameController.text;
    if (_keyPair == null) {
      await _generateKeys();
    }

    try {
      final response = await _registrationService.registerUser(
          captchaId: _captchaId,
          captchaTry: _captchaController.text,
          publicKey: _publicKey,
          userName: userName);
      if (response == 0) {
        throw Exception('Failed to register user.');
      }

      await _certFileHandler.downloadCertificate(_keyPair!, "certificate.pem", _certPasswordController.text);

      RsaKeyStore().publicKey = _keyPair!.publicKey as RSAPublicKey;
      RsaKeyStore().privateKey = _keyPair!.privateKey as RSAPrivateKey;
      _redirectToChatOverview();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to register user: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }


  void _redirectToChatOverview() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatOverviewPage()
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: flutter_widgets.Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              maxLength: 50,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
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
              maxLengthEnforcement: MaxLengthEnforcement.enforced
            ),
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
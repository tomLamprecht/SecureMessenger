import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:my_flutter_test/services/register_service.dart';
import 'package:my_flutter_test/services/captcha_service.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_test/services/stores/rsa_key_store.dart';
import 'package:pointycastle/asymmetric/api.dart';

import '../services/files/rsa_helper.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _userNameController;
  late TextEditingController _captchaController;
  late String _captchaId;
  late CaptchaService _captchaService;
  late RegistrationService _registrationService;
  late String _privateKey = "";
  late String _publicKey = "";

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController();
    _captchaController = TextEditingController();
    _captchaController = TextEditingController();
    _captchaId = '';
    _captchaService = CaptchaService();
    _registrationService = RegistrationService();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  Future _generateKeys() async {
    var rsaHelper = RSAHelper();
    var keypair = await rsaHelper.getRSAKeyPair(rsaHelper.getSecureRandom());

    var encodedPublicKey = rsaHelper.encodePublicKeyToString(keypair.publicKey as RSAPublicKey);
    var encodedPrivateKey = rsaHelper.encodePrivateKeyToString(keypair.privateKey as RSAPrivateKey);
    RsaKeyStore().publicKey = keypair.publicKey as RSAPublicKey;
    RsaKeyStore().privateKey = keypair.privateKey as RSAPrivateKey;
    setState(() {
      _publicKey = encodedPublicKey;
      _privateKey = encodedPrivateKey;
    });
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
        throw Exception('Failed to register user.');
      }
      _redirectToChatOverview();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to register user: $e'),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Private Key:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _privateKey,
              style: TextStyle(fontFamily: 'Monospace'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Public Key:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _publicKey,
              style: TextStyle(fontFamily: 'Monospace'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateKeys,
              child: const Text('Keys erzeugen'),
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
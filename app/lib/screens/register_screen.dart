import 'dart:async';
import 'package:flutter/services.dart';
import 'package:securemessenger/models/keypair.dart';
import 'package:securemessenger/services/files/ecc_helper.dart';
import 'package:securemessenger/services/register_service.dart';
import 'package:securemessenger/services/captcha_service.dart';
import 'package:flutter/material.dart';
import 'package:securemessenger/services/stores/ecc_key_store.dart';

import '../services/files/cert_file_handler.dart';
import 'chat_overview_screen.dart';
import '../widgets/validated_text_field.dart';

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
  ImageProvider<Object>? image;
  late CaptchaService _captchaService;
  late RegistrationService _registrationService;
  late String _publicKey;
  Keypair? _keyPair;
  final _certFileHandler = CertFileHandler();
  final ValueNotifier<String?> _usernameValidationError =
  ValueNotifier<String?>(null);
  bool _validCredentials = false;

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController();
    _userNameController.addListener(_onTextFieldChanged);
    _captchaController = TextEditingController();
    _certPasswordController = TextEditingController();
    _certPasswordController.addListener(_onTextFieldChanged);
    _captchaId = '';
    _captchaService = CaptchaService();
    _registrationService = RegistrationService();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _certPasswordController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  void _onTextFieldChanged() {
    var tmp = _validCredentials;
    _validCredentials = _validateUsername(_userNameController.text) == null &&
        _validatePassword(_certPasswordController.text) == null;
    if( _validCredentials != tmp)
    {
      setState(() {});
    }
  }

  Future _generateKeys() async {
    var eccHelper = ECCHelper();
    _keyPair = eccHelper.generateKeyPair();
    _publicKey = eccHelper.encodePubKeyForBackend(_keyPair!.publicKey);
  }

  Future<ImageProvider> _loadCaptchaImage() async {
    if (_captchaId != '') {
      return image!;
    }
    _captchaId = await _captchaService.getNewCaptcha();

    image = await _captchaService.fetchCaptchaImage(_captchaId);
    return image!;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])').hasMatch(value)) {
      return 'Password must contain both upper and lower case letters';
    }

    if (!RegExp(r'^(?=.*\d)').hasMatch(value)) {
      return 'Password must contain at least one numeric digit';
    }

    if (!RegExp(r'^(?=.*[@$!%*?&])').hasMatch(value)) {
      return 'Password must contain at least one special character (@, \$, !, %, *, ?, &)';
    }

    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return "Username can't be empty";
    }
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return 'Invalid username. Only letters and numbers are allowed!';
    }
    return null;
  }

  void _refreshCaptcha() {
    setState(() {
      _captchaId = '';
    });
  }

  Future<void> _registerUser() async {
    final userName = _userNameController.text;
    if (_keyPair == null) {
      await _generateKeys();
    }

    try {
      await _registrationService.registerUser(
          captchaId: _captchaId,
          captchaTry: _captchaController.text,
          publicKey: _publicKey,
          userName: userName);

      await _certFileHandler.downloadCertificate(
          _keyPair!, "$userName.cert", _certPasswordController.text);

      EccKeyStore().publicKey = _keyPair!.publicKey;
      EccKeyStore().privateKey = _keyPair!.privateKey;
      _redirectToChatOverview();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().substring(11)),
        backgroundColor: Colors.red,
      ));
      _refreshCaptcha();
    }
  }

  void _redirectToChatOverview() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ChatOverviewPage()),
            (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text("Register"), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<String?>(
                valueListenable: _usernameValidationError,
                builder: (context, errorMessage, child) {
                  return ValidatedTextField(
                    controller: _userNameController,
                    isPassword: false,
                    labelText: 'Username',
                    validationFunction: _validateUsername,
                  );
                }),
            ValidatedTextField(
              controller: _certPasswordController,
              labelText: 'Password',
              isPassword: true,
              validationFunction: _validatePassword,
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
                  return const Text(
                      'Failed to load captcha image. Please try again later.');
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
                        tooltip: 'Reload',
                        child: const Icon(Icons.refresh),
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
              onPressed: _validCredentials ? _registerUser : null,
              child: const Text('Create user'),
            ),
          ],
        ),
      ),
    );
  }
}

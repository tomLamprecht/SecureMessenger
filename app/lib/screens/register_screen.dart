import 'dart:async';
import 'package:flutter/services.dart';
import 'package:my_flutter_test/models/keypair.dart';
import 'package:my_flutter_test/services/files/ecc_helper.dart';
import 'package:my_flutter_test/services/register_service.dart';
import 'package:my_flutter_test/services/captcha_service.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_test/services/stores/ecc_key_store.dart';

import '../services/files/cert_file_handler.dart';
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
  Keypair? _keyPair;
  final _certFileHandler = CertFileHandler();
  final ValueNotifier<String?> _usernameValidationError = ValueNotifier<String?>(null);

  final ValueNotifier<bool> _isDownloadButtonEnabled = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController();
    _captchaController = TextEditingController();
    _certPasswordController = TextEditingController();
    _certPasswordController.addListener(_onTextFieldChanged);
    _captchaId = '';
    _captchaService = CaptchaService();
    _registrationService = RegistrationService();
    _userNameController.addListener(_validateUsernameOnChange);
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
    var eccHelper = ECCHelper();
    _keyPair = eccHelper.generateKeyPair();
    _publicKey = eccHelper.encodePubKeyForBackend(_keyPair!.publicKey);
  }

  Future<ImageProvider> _loadCaptchaImage() async {
    _captchaId = await _captchaService.getNewCaptcha();
    var image = await _captchaService.fetchCaptchaImage(_captchaId);
    return image;
  }

  void _validateUsernameOnChange() {
    _usernameValidationError.value = _validateUsername(_userNameController.text);
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return null;
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

      await _certFileHandler.downloadCertificate(_keyPair!, "$userName.cert", _certPasswordController.text);

      EccKeyStore().publicKey = _keyPair!.publicKey;
      EccKeyStore().privateKey = _keyPair!.privateKey;
      _redirectToChatOverview();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().substring(11)),
        backgroundColor: Colors.red,
      ));
      if (e.toString() == "Exception: Invalid captcha text. Please try again.") {
        setState(() {

        });
        // todo: refresh the FutureBuilder<ImageProvider>
      }
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
      appBar: AppBar(title: const Text("Register"), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<String?>(
              valueListenable: _usernameValidationError,
              builder: (context, errorMessage, child) {
                return TextField(
                  controller: _userNameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    errorText: _validateUsername(_userNameController.text),
                  ),
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 50,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                );
              }
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
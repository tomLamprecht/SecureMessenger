import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';

import 'package:my_flutter_test/services/registerService.dart';
import 'package:my_flutter_test/services/captchaService.dart';
import 'package:flutter/material.dart';


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
  String _privateKey = "";
  String _publicKey = "";

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController();
    _captchaId = '';
    _captchaService = CaptchaService();
    _registrationService = RegistrationService();
    _loadCaptchaImage();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

  Future<void> _generateKeys() async {
    // TODO: Implement key generation logic
  }

  Future<File> _loadCaptchaImage() async {
    _captchaId = await _captchaService.getNewCaptcha();
    return await _captchaService.getCaptchaImage(_captchaId);
  }

  Future<void> _registerUser() async {
    final userName = _userNameController.text;
    final captchaTry = ''; // TODO: Implement captcha verification logic

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
            const Text(
              "",
              style: TextStyle(fontFamily: 'Monospace'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Public Key:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "",
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
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<File>(
                    future: _loadCaptchaImage(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.file(snapshot.data!);
                      } else if (snapshot.hasError) {
                        return Text('Failed to load captcha image.');
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
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
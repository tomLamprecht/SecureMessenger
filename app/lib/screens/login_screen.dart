import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:securemessenger/screens/register_screen.dart';

import '../services/login_service.dart';
import 'chat_overview_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passwordController = TextEditingController();
  PlatformFile? _selectedFile;
  bool isLoading = false;

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['cert']);

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        _selectedFile = file;
      });
    } else {
      // User canceled the picker
    }
  }

  Future<void> _signIn() async {
    if (_selectedFile != null && _passwordController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      if (_selectedFile?.bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Error while loading cert file!"),
          )
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      String content = utf8.decode(_selectedFile!.bytes!);
      bool success;
      try {
        success = await compute(signIn, {"keyPairPemEncrypted": content, "password": _passwordController.text});
      } catch (e) {
        success = false;
      }


      setState(() {
        isLoading = false;
      });

      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ChatOverviewPage(),
          ),
            (route) => false,
        );
      } else {
        _showAlertDialog('Error during the login process: Either the certificate or password is invalid or the account does not exist.');
      }
    }
  }

  void _showAlertDialog(String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Colors.blue,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 2),
            ElevatedButton(
              onPressed: _pickFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: const Text('Pick a .cert file', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 10),
            Text(
              _selectedFile != null ? 'Selected file: ${_selectedFile!.name}' : 'No file selected',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              onChanged: (value) => setState(() {}),
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(fontSize: 18),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedFile == null || _passwordController.text.isEmpty)
              Text(
                _selectedFile == null ? 'Please select a .cert file.' : 'Please enter a password.',
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isLoading || _selectedFile == null || _passwordController.text.isEmpty ? null : _signIn,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 24),
              ),
              child: isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
                  : const Text('Sign In', style: TextStyle(fontSize: 18)),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: const Text("Register", style: TextStyle(fontSize: 18)),
            ),
            const Spacer(flex: 2),
          ],
        )
      ),
    );
  }
}

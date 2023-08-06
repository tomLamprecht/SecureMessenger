import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_flutter_test/screens/register_screen.dart';
import '../services/login_service.dart';
import 'chat_overview_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  TextEditingController _passwordController = TextEditingController();
  PlatformFile? _selectedFile;
  bool isLoading = false;

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

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
    if (_selectedFile != null) {
      setState(() {
        isLoading = true;
      });

      String content = utf8.decode(_selectedFile!.bytes!);
      final success = await compute(signIn, {"keyPairPemEncrypted": content, "password": _passwordController.text});

      setState(() {
        isLoading = false;
      });

      if (!success) {
        _showAlertDialog('File is not in the right format!');
      } else {
        requestAndSaveWhoAmI();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatOverviewPage(),
          ),
        );
      }
    }
  }

  void _showAlertDialog(String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Fehler'),
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
            ),
          ),
          ElevatedButton(
            child: Text('Pick a file'),
            onPressed: _pickFile,
          ),
          Text(_selectedFile != null
              ? 'Selected file: ${_selectedFile!.name}'
              : 'No file selected'),
          ElevatedButton(
            child: Text('Sign In'),
            onPressed: isLoading ? null : _signIn,
          ),
          if (isLoading)
            SizedBox(
              height: 36,
              width: 36,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegisterScreen(),
                ),
              );
            },
            child: Text("Register"),
          ),
        ],
      ),
    );
  }
}

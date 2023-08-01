import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_flutter_test/screens/register.dart';
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

  void _signIn() {
    if (_selectedFile != null) {
      String content = utf8.decode(_selectedFile!.bytes!);
      final success = signIn(content, _passwordController.text);
      if (!success) {
        _showAlertDialog('File is not in the right format!');
      }

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatOverviewPage()
          )
      );
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
            onPressed: _signIn,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RegisterScreen()
                ),
            );
          }, child: Text("Register"))
        ],
      ),
    );
  }
}

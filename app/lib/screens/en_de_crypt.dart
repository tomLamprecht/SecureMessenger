import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/files/cert_file_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CertFileHandler Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _contentController = TextEditingController();
  final _passwordController = TextEditingController();
  final _handler = CertFileHandler();
  String _result = '';

  void _encrypt() {
    final content = _contentController.text;
    final password = _passwordController.text;
    final encrypted = _handler.encryptFileContentByPassword(content, password);
    setState(() {
      _result = encrypted;
    });
  }

  void _decrypt() {
    final content = _contentController.text;
    final password = _passwordController.text;
    final decrypted = _handler.decryptFileContentByPassword(content, password);
    setState(() {
      _result = decrypted;
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _result));
  }

  @override
  void dispose() {
    _contentController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CertFileHandler Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: false,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _encrypt,
              child: const Text('Encrypt'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _decrypt,
              child: const Text('Decrypt'),
            ),
            const SizedBox(height: 16.0),
            Text(
              _result,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _copyToClipboard,
              child: const Text('Copy to Clipboard'),
            ),
          ],
        ),
      ),
    );
  }
}

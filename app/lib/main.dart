import 'package:flutter/material.dart';

import 'widgets/createChat.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Messenger Test'),
        ),
        body: const CreateChatWidget(),
      ),
    );
  }
}

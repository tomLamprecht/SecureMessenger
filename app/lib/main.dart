import 'package:flutter/material.dart';
import 'package:securemessenger/screens/chat_overview_screen.dart';
import 'package:securemessenger/screens/login_screen.dart';
import 'package:securemessenger/services/stores/ecc_key_store.dart';

void main() => runApp(
  const MaterialApp(
    home: MyApp(),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat',

      theme: ThemeData.light(useMaterial3: false),

      home: EccKeyStore().publicKey == null
          ? const LoginScreen()
          : ChatOverviewPage(),
    );
  }
}

class WidgetList extends StatelessWidget {
  final Map<String, Widget> widgets;

  const WidgetList({Key? key, required this.widgets}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widgets.entries.map((e) {
        return ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => e.value,
              ),
            );
          },
          child: Text(e.key),
        );
      }).toList(),
    );
  }
}

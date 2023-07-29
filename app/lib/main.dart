import 'package:flutter/material.dart';
import 'package:my_flutter_test/screens/chat_screen.dart';
import 'package:my_flutter_test/screens/login_screen.dart';
import 'package:my_flutter_test/screens/register.dart';
import 'package:my_flutter_test/services/stores/rsa_key_store.dart';

void main() => runApp(
  const MaterialApp(
    home: MyApp(),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp() : super();

  @override
  Widget build(BuildContext context) {
    return RsaKeyStore().publicKey == null
        ? LoginScreen()
        : ChatScreen(chatTitle: 'Test Chat', chatId: 1);
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

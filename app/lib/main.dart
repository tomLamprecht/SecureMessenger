import 'package:flutter/material.dart';
import 'package:my_flutter_test/screens/chat_overview_screen.dart';
import 'package:my_flutter_test/screens/login_screen.dart';
import 'package:my_flutter_test/services/stores/ecc_key_store.dart';

void main() => runApp(
  const MaterialApp(
    home: MyApp(),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp() : super();

  @override
  Widget build(BuildContext context) {
    return EccKeyStore().publicKey == null
        ? LoginScreen()
        : ChatOverviewPage();
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

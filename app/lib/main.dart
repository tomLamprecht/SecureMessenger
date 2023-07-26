import 'package:flutter/material.dart';
import 'package:my_flutter_test/screens/chat_screen.dart';
import 'package:my_flutter_test/screens/register.dart';

void main() => runApp(
  const MaterialApp(
    home: WidgetList(
        widgets: {
          'Chat Page': ChatScreen(chatTitle: 'Test Chat', chatId: 1),
          'Register Page': RegisterScreen()
        }
      )
  )
);

class WidgetList extends StatelessWidget {
  final Map<String, Widget> widgets;

  const WidgetList({super.key, required this.widgets});

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

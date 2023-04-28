import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CreateChatWidget extends StatefulWidget {
  const CreateChatWidget({super.key});


  @override
  State<CreateChatWidget> createState() => _CreateChatWidgetState();
}

class _CreateChatWidgetState extends State<CreateChatWidget> {
  late TextEditingController _controller;

  List<String> myList = List.generate(0, (index) => 'Sample Item - $index');

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _perform_chat_creation(BuildContext context) async {
    TextEditingController _usernameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chat erstellen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                controller: _usernameController,
                decoration: InputDecoration(hintText: 'Nutzername des Freundes'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () async {
                String targetUserName = _usernameController.text.trim();
                if (targetUserName.isNotEmpty) {
                  final url = 'http://localhost:8080/chats';
                  final response = await http.post(
                    Uri.parse(url),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({'targetUserName': targetUserName}),
                  );

                  if (response.statusCode == 201) {
                    // You can perform additional actions upon successful chat creation.
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Chat erfolgreich erstellt!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Fehler beim Erstellen des Chats!')),
                    );
                  }
                }

                Navigator.of(context).pop();
              },
              child: Text('Chat erstellen'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToNewChatPage(BuildContext context) {
    // This function is empty for now
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _perform_chat_creation(context),
          child: Icon(Icons.add),
        ),
      ],
    );
  }
}
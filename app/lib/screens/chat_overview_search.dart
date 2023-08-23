import 'package:flutter/material.dart';

import '../models/chat.dart';
import 'chat_screen.dart';

class ChatSearch extends SearchDelegate<String> {
  final List<Chat> chats;

  ChatSearch({required this.chats});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      primaryColor: Colors.blue,
      primaryIconTheme: const IconThemeData(color: Colors.white),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      query.isEmpty
          ? Container()
          : IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Chat> suggestions = query.isEmpty
        ? chats
        : chats
        .where(
            (chat) => chat.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        Chat chat = suggestions[index];
        int startIndex = chat.name.toLowerCase().indexOf(query.toLowerCase());

        return ListTile(
          leading: const Icon(Icons.chat),
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: chat.name.substring(0, startIndex),
                  style: const TextStyle(color: Colors.grey),
                ),
                TextSpan(
                  text: chat.name
                      .substring(startIndex, startIndex + query.length),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: chat.name.substring(startIndex + query.length),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          onTap: () {
            close(context, chat.name);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ChatScreen(chatTitle: chat.name, chatId: chat.id),
              ),
            );
          },
        );
      },
    );
  }
}
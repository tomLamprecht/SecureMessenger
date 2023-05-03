import 'package:flutter/material.dart';
import 'package:my_flutter_test/screens/Chat.dart';
import 'package:my_flutter_test/widgets/createChat.dart';



class ChatOverviewPage extends StatefulWidget {
  @override
  _ChatOverviewPageState createState() => _ChatOverviewPageState();
}

class _ChatOverviewPageState extends State<ChatOverviewPage> {
  List<String> chats = List.generate(10, (index) => 'Chat $index');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Overview'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              String? result = await showSearch<String>(
                context: context,
                delegate: ChatSearch(chats: chats),
              );

              if (result != null) {
                // Navigate to the chat when selected from search results
              }
            },
          ),
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(child: Text('New group')),
                PopupMenuItem(child: Text('Settings')),
              ];
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          String chat = chats[index];
          return Dismissible(
            key: UniqueKey(),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              setState(() {
                chats.removeAt(index);
              });
            },
            child: Hero(
              tag: 'chat-$chat',
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                  AssetImage('assets/images/avatar_placeholder.png'),
                ),
                title: Text(chat),
                subtitle: Text('Last message...'),
                trailing: Text('Time'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatWidget(),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement new chat creation here
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateChatWidget()),
          );
        },
        child: Icon(Icons.chat),
      ),
    );
  }
}



class ChatSearch extends SearchDelegate<String> {
  final List<String> chats;

  ChatSearch({required this.chats});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      primaryColor: Colors.green,
      primaryIconTheme: IconThemeData(color: Colors.white),
      primaryColorBrightness: Brightness.dark,
      textTheme: TextTheme(headline6: TextStyle(color: Colors.white)),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      query.isEmpty
          ? Container()
          : IconButton(
        icon: Icon(Icons.clear),
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
    final List<String> suggestions = query.isEmpty
        ? chats
        : chats
        .where((chat) => chat.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        String chat = suggestions[index];
        int startIndex = chat.toLowerCase().indexOf(query.toLowerCase());

        return ListTile(
          leading: Icon(Icons.chat),
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: chat.substring(0, startIndex),
                  style: TextStyle(color: Colors.grey),
                ),
                TextSpan(
                  text: chat.substring(startIndex, startIndex + query.length),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: chat.substring(startIndex + query.length),
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          onTap: () {
            close(context, chat);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatWidget(),
              ),
            );

          },
        );
      },
    );
  }
}

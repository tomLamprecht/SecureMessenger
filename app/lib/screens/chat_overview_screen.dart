import 'package:flutter/material.dart';
import 'package:my_flutter_test/models/chat.dart';
import 'package:my_flutter_test/screens/chat_screen.dart';
import 'package:my_flutter_test/services/chats_service.dart';
import 'package:my_flutter_test/widgets/create_chat.dart';


class ChatOverviewPage extends StatefulWidget {
  @override
  _ChatOverviewPageState createState() => _ChatOverviewPageState();
}

class _ChatOverviewPageState extends State<ChatOverviewPage> {
  ChatsService chatsService = ChatsService();
  List<Chat>? chats = [];

  @override
  void initState() {
    initialize();
    super.initState();
  }
  Future<void> initialize() async {
    chats = await chatsService.getChatsFromUser();
  }

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
                delegate: ChatSearch(chats: chats!),
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
        itemCount: chats?.length,
        itemBuilder: (context, index) {
          Chat chat = chats![index]; // ToDo: schauen ob wir prüfen müssen, dass auch wirklich Werte da sind (eigentlich beim Laden schon getan)
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
                // ToDo: wollen wir hier chat löschen (also User aus Chat entfernen) oder chat archivieren machen? Oder des wegswipen als Funktion entfernen?
                // chats?.removeAt(index);
              });
            },
            child: Hero(
              tag: 'chat-$chat',
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                  AssetImage('assets/images/avatar_placeholder.png'),
                ),
                title: Text(chat.name),
                // subtitle: Text('Last message...'), //ToDo: nicht im MVP
                // trailing: Text('Time'), //ToDo: nicht im MVP
                subtitle: Text(chat.description),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(chatTitle: chat.name, chatId: chat.id),
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
  List<String> getChatNames() {
    List<String> chatNames = [];
    chats?.forEach((chat) {chatNames.add(chat.name); });
    return chatNames;
  }
}



class ChatSearch extends SearchDelegate<String> {
  final List<Chat> chats;

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
    final List<Chat> suggestions = query.isEmpty
        ? chats
        : chats.where((chat) => chat.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        Chat chat = suggestions[index];
        int startIndex = chat.name.toLowerCase().indexOf(query.toLowerCase());

        return ListTile(
          leading: Icon(Icons.chat),
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: chat.name.substring(0, startIndex),
                  style: TextStyle(color: Colors.grey),
                ),
                TextSpan(
                  text: chat.name.substring(startIndex, startIndex + query.length),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: chat.name.substring(startIndex + query.length),
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          onTap: () {
            close(context, chat.name);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(chatTitle: chat.name, chatId: chat.id),
              ),
            );

          },
        );
      },
    );
  }
}
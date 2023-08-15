import 'package:flutter/material.dart';
import 'package:my_flutter_test/models/chat.dart';
import 'package:my_flutter_test/screens/chat_screen.dart';
import 'package:my_flutter_test/screens/friend_request_screen.dart';
import 'package:my_flutter_test/services/chats_service.dart';
import 'package:my_flutter_test/widgets/create_chat.dart';

class ChatOverviewPage extends StatefulWidget {
  @override
  _ChatOverviewPageState createState() => _ChatOverviewPageState();
}

class _ChatOverviewPageState extends State<ChatOverviewPage> {
  ChatsService chatsService = ChatsService();
  List<Chat> chats = [
    // Chat(1, "Chat Room 1", "This is chat room 1.",
    //     DateTime(2023, 7, 31, 10, 30)),
    // Chat(2, "Chat Room 2", "Welcome to chat room 2!",
    //     DateTime(2023, 8, 1, 15, 45)),
    // Chat(3, "General Chat", "A place for general discussions.",
    //     DateTime(2023, 8, 1, 9, 0)),
    // Chat(4, "Private Chat", "Private conversations here.",
    //     DateTime(2023, 7, 30, 18, 20)),
    // Chat(5, "Party Planning", "Organizing the upcoming party.",
    //     DateTime(2023, 7, 29, 20, 0)),
  ];

  // bool _isHovering = false;

  @override
  void initState() {
    initialize();
    super.initState();
  }

  Future<void> initialize() async {
    chats = await chatsService.getChatsFromUser();
    print("Chats: $chats");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              String? result = await showSearch<String>(
                context: context,
                delegate: ChatSearch(chats: chats),
              );

              if (result != null) {
                // Navigate to the chat when selected from search results //todo: macht es doch schon
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FriendRequestPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (chats.isEmpty)
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.yellow,
              child: Row(
                children: const [
                  Icon(Icons.info, color: Colors.black),
                  SizedBox(width: 8.0),
                  Text(
                    'No chats available.',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  Chat chat = chats[index];
                  return Dismissible(
                    key: UniqueKey(),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      setState(() async {
                        // ToDo: wollen wir hier chat löschen (also User aus Chat entfernen) oder chat archivieren machen? Oder des wegswipen als Funktion entfernen?
                        if(await chatsService.deleteChatFromUser(chat.id, 1)){ //TODO: accountId im backend über currentuser or what? Übergabe?
                          chats.removeAt(index);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Anfrage fehlgeschlagen.'),
                            ),
                          );
                        }

                      });
                    },
                    child: Hero(
                      tag: 'chat-$chat',
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blue, // Setze die gewünschte Hintergrundfarbe
                          child: Icon(
                            Icons.assist_walker_sharp, // Material Icon hinzufügen (kann beliebig angepasst werden)
                            color: Colors.white, // Farbe des Icons anpassen
                          ),
                        ),
                        title: Text(chat.name),
                        // subtitle: Text('Last message...'), //ToDo: nicht im MVP
                        // trailing: Text('Time'), //ToDo: nicht im MVP
                        subtitle: Text(chat.description),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                  chatTitle: chat.name, chatId: chat.id),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement new chat creation here
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateChatWidget()),
          );
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
// List<String> getChatNames() {
//   List<String> chatNames = [];
//   chats?.forEach((chat) {chatNames.add(chat.name); });
//   return chatNames;
// }
}

class ChatSearch extends SearchDelegate<String> {
  final List<Chat> chats;

  ChatSearch({required this.chats});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      primaryColor: Colors.green,
      primaryIconTheme: const IconThemeData(color: Colors.white),
      primaryColorBrightness: Brightness.dark,
      textTheme: const TextTheme(headline6: TextStyle(color: Colors.white)),
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

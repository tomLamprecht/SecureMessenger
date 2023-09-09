import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:my_flutter_test/models/chat.dart';
import 'package:my_flutter_test/screens/chat_screen.dart';
import 'package:my_flutter_test/screens/friend_request_screen.dart';
import 'package:my_flutter_test/services/chats_service.dart';
import 'package:my_flutter_test/widgets/create_chat.dart';

import '../services/encryption_service.dart';
import 'chat_overview_search.dart';
import 'manage_profil_screen.dart';

class ChatOverviewPage extends StatefulWidget {
  @override
  _ChatOverviewPageState createState() => _ChatOverviewPageState();
}

class _ChatOverviewPageState extends State<ChatOverviewPage> {
  ChatsService chatsService = ChatsService();
  List<Chat>? chats;

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    await initialize();
  }

  Future<void> initialize() async {
    var result = await chatsService.getChatsFromUser();
    setState(() {
      chats = result;
    });
  }

  Future<String?> _getImageFromDatabase(int chatId) async {
    var chatToAcc = await ChatsService().getChatToUser(chatId);
    String? encodedPic = chatToAcc?.chat.encodedGroupPic;
    if (chatToAcc != null && encodedPic != null) {
      return encodedPic;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (chats == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chat Overview'),
          backgroundColor: Colors.blue,

          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                String? result = await showSearch<String>(
                  context: context,
                  delegate: ChatSearch(chats: chats!),
                );

                if (result != null) {
                  // Navigate to the chat when selected from search results //todo: macht es doch schon
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_add_alt_1),
              onPressed: () async {
                final bool? shouldRefresh = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (context) => FriendRequestPage()),
                );
                log(shouldRefresh.toString());
                if (shouldRefresh ?? false) {
                  setState(() {

                  });
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.manage_accounts_sharp),
              onPressed: () async {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => ManageProfilPage()),
                // );

                final bool? shouldRefresh = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (context) => ManageProfilPage()),
                );
                log(shouldRefresh.toString());
                if (shouldRefresh ?? false) {
                  setState(() {

                  });
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () async {
                await initialize();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: const Text("Refresh", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 15),
            if (chats!.isEmpty)
              Column(
                  children: [
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
                    ),
                  ],
              )

            else
              Expanded(
                child: ListView.builder(
                  itemCount: chats!.length,
                  itemBuilder: (context, index) {
                    Chat chat = chats![index];
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
                          if (await chatsService.deleteChatFromUser(chat.id,
                              1)) { //TODO: accountId im backend über currentuser or what? Übergabe?
                            chats!.removeAt(index);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Anfrage fehlgeschlagen.'),
                              ),
                            );
                          }
                        });
                      },
                      child: ListTile(
                        leading: FutureBuilder<String?>(
                          future: _getImageFromDatabase(chat.id),
                          // Funktion zum Abrufen des Bildes aus der Datenbank
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              // Zeige eine Fehlermeldung, wenn ein Fehler auftritt
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData && snapshot.data != null) {
                              // Zeige das Bild aus der Datenbank
                              final encodedPic = snapshot.data!;
                              // final decryptPic = aesDecrypt(encodedPic, "password");
                              final imageData = Uint8List.fromList(base64Decode(encodedPic));
                              return CircleAvatar(
                                radius: 20,
                                backgroundImage: MemoryImage(imageData),
                              );
                            } else {
                              // Zeige das Icon, wenn kein Bild in der Datenbank vorhanden ist
                              return CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.blue,
                                child: Icon(
                                  Icons.supervised_user_circle,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              );
                            }
                          },
                        ),
                        title: Text(chat.name),
                        // subtitle: Text('Last message...'), //ToDo: nicht im MVP
                        // trailing: Text('Time'), //ToDo: nicht im MVP
                        subtitle: Text(chat.description),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatScreen(
                                      chatTitle: chat.name, chatId: chat.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
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
  }
// List<String> getChatNames() {
//   List<String> chatNames = [];
//   chats?.forEach((chat) {chatNames.add(chat.name); });
//   return chatNames;
// }
}



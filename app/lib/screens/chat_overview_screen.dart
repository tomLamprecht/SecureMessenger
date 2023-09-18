import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:securemessenger/models/chat.dart';
import 'package:securemessenger/screens/chat_screen.dart';
import 'package:securemessenger/screens/friend_request_screen.dart';
import 'package:securemessenger/services/chats_service.dart';
import 'package:securemessenger/services/stores/group_picture_store.dart';
import 'package:securemessenger/services/stores/who_am_i_store.dart';
import 'package:securemessenger/widgets/create_chat.dart';

import '../services/login_service.dart';
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
    if(WhoAmIStore().publicKey == null) {
      requestAndSaveWhoAmI();
    }
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
    var encodedPic = GroupPictureStore().getGroupChatPictureById(chatId);
    return encodedPic;
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
                await showSearch<String>(
                  context: context,
                  delegate: ChatSearch(chats: chats!),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_add_alt_1),
              onPressed: () async {
                final bool? shouldRefresh = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (context) => FriendRequestPage()),
                );
                if (shouldRefresh ?? false) {
                  setState(() {});
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.manage_accounts_sharp),
              onPressed: () async {
                final bool? shouldRefresh = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (context) => ManageProfilPage()),
                );
                if (shouldRefresh ?? false) {
                  setState(() {});
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
                      },
                      child: ListTile(
                        leading: FutureBuilder<String?>(
                          future: _getImageFromDatabase(chat.id),
                          builder: (context, snapshot) {
                             if (snapshot.hasData && snapshot.data != null) {
                              final encodedPic = snapshot.data!;
                              final imageData = Uint8List.fromList(base64Decode(encodedPic));
                              return CircleAvatar(
                                radius: 20,
                                backgroundImage: MemoryImage(imageData),
                              );
                            } else {
                              return const CircleAvatar(
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
                        subtitle: Text(chat.description),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatScreen(
                                      chatTitle: chat.name, chatId: chat.id),
                            ),
                          ).then((value) => initialize());
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateChatWidget()),
            ).then((value) => initialize());
          },
          child: const Icon(Icons.chat),
        ),
      );
    }
  }
}

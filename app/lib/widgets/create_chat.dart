import 'package:flutter/material.dart';
import 'package:securemessenger/models/account_id_to_encrypted_sym_key.dart';
import 'package:securemessenger/screens/chat_screen.dart';
import 'package:securemessenger/services/chats_service.dart';
import 'package:securemessenger/services/files/aes_helper.dart';
import 'package:securemessenger/services/files/ecc_helper.dart';
import 'package:securemessenger/services/friendship_service.dart';
import 'package:securemessenger/services/login_service.dart';
import 'package:securemessenger/services/stores/who_am_i_store.dart';

import '../models/account.dart';
import '../screens/friend_request_screen.dart';
import '../services/stores/ecc_key_store.dart';

class CreateChatWidget extends StatefulWidget {
  const CreateChatWidget({super.key});

  @override
  State<CreateChatWidget> createState() => _CreateChatWidgetState();
}

class _CreateChatWidgetState extends State<CreateChatWidget> {
  FriendshipService friendshipService = FriendshipService();
  List<Account>? accounts;

  TextEditingController _chatNameController = TextEditingController();
  FocusNode _chatNameFocusNode = FocusNode();

  TextEditingController _chatDescriptionController = TextEditingController();
  FocusNode _chatDescriptionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  Future<void> createChat() async {
    var chatName = _chatNameController.text.trim();
    var chatDescription = _chatDescriptionController.text.trim();

    if (WhoAmIStore().accountId == null) {
      await requestAndSaveWhoAmI();
    }

    if (EccKeyStore().publicKey == null || WhoAmIStore().accountId == null) {
      throw Exception("PublicKey or account is not stored locally.");
    }
    var eccHelper = ECCHelper();
    var symKey = AesHelper.createRandomBase64Key();

    if (accounts == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Data has not been loaded yet. Please be patient for a moment.'),
        ),
      );
      return;
    }
    var accountsInChat = accounts!.where((element) => element.isSelected);

    List<AccountIdToEncryptedSymKey> encryptedSymKeys = [];
    var ownEncryptedSymKey =
        eccHelper.encodeWithPubKey(EccKeyStore().publicKey!, symKey);
    encryptedSymKeys.add(AccountIdToEncryptedSymKey(
        accountId: WhoAmIStore().accountId!,
        encryptedSymmetricKey: ownEncryptedSymKey));
    for (var account in accountsInChat) {
      var encodedSymKey =
          eccHelper.encryptWithPubKeyStringUsingECDH(account.publicKey, symKey);
      encryptedSymKeys.add(AccountIdToEncryptedSymKey(
          accountId: account.accountId, encryptedSymmetricKey: encodedSymKey));
    }

    var chatId = await ChatsService()
        .createNewChat(chatName, chatDescription, encryptedSymKeys);
    if (chatId == null) {
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ChatScreen(chatId: chatId, chatTitle: chatName)),
    );
  }

  Future<void> fetchFriends() async {
    var result = await friendshipService.getFriendships();
    setState(() {
      accounts = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isChatNameValid = _chatNameController.text.trim().isNotEmpty;

    if (accounts == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Create Chat'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add_alt_1),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FriendRequestPage()),
                ).then((value) {
                  fetchFriends();
                });
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatNameController,
                        focusNode: _chatNameFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Chat Name',
                          errorText:
                              isChatNameValid ? null : "Chat name is required.",
                          border: const OutlineInputBorder(),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2.0,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            // Trigger a rebuild to update the UI.
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8.0),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatDescriptionController,
                        focusNode: _chatDescriptionFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Chat Description',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                  ],
                ),
              ),
              if (accounts!.isEmpty)
                Container(
                  color: Colors.yellow,
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.info, color: Colors.black),
                      SizedBox(width: 8.0),
                      Text(
                        'You have no friends to write with.',
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
                    itemCount: accounts!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Checkbox(
                          value: accounts![index].isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              accounts![index].isSelected =
                                  !accounts![index].isSelected;
                            });
                          },
                        ),
                        title: Text(accounts![index].userName),
                        subtitle: Text(accounts![index].publicKey),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: isChatNameValid
              ? () async {
                  await createChat();
                }
              : null,
          backgroundColor:
              isChatNameValid ? Theme.of(context).primaryColor : Colors.grey,
          child: const Icon(Icons.arrow_circle_right_outlined),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );
    }
  }
}

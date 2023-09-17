
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:my_flutter_test/models/account.dart';
import 'package:my_flutter_test/services/account_service.dart';
import 'package:my_flutter_test/services/stores/account_information_store.dart';
import '../services/friendship_service.dart';
import '../widgets/hoverable_button.dart';
import 'manage_profil_screen.dart';
import 'other_profil_screen.dart';



class FriendRequestPage extends StatefulWidget {
  @override
  _FriendRequestPageState createState() => _FriendRequestPageState();
}

class _FriendRequestPageState extends State<FriendRequestPage> {
  List<Account> _accountList = [];
  List<Account> _friendsList = [];

  final FriendshipService friendshipService = FriendshipService();
  final AccountService accountService = AccountService();

  List<bool> _isClearButtonHoveringList = [];
  List<bool> _isCheckButtonHoveringList = [];
  List<bool> _isClearButtonFriendHoveringList = [];

  final TextEditingController _usernameController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();

  Future<void> _getFriendshipRequests() async {
    _accountList = await friendshipService.getFriendshipRequests();
    _friendsList = await friendshipService.getFriendships();

    _isClearButtonHoveringList = List.generate(_accountList.length, (_) => false);
    _isCheckButtonHoveringList = List.generate(_accountList.length, (_) => false);
    _isClearButtonFriendHoveringList = List.generate(_friendsList.length, (_) => false);
  }

  void _removeFriendRequestItem(int index) {
    setState(() {
      _accountList.removeAt(index);
      _isClearButtonHoveringList.removeAt(index);
      _isCheckButtonHoveringList.removeAt(index);
    });
  }

  void _deleteFriendFromFriendlist(int index){
    setState(() {
      _friendsList.removeAt(index);
      _isClearButtonFriendHoveringList.removeAt(index);
    });
  }

  Future<String?> _getImageFromDatabase(String username) async {
    var account = await AccountInformationStore().getPublicInformationByUsername(username);
    String? encodedPic = account.encodedProfilePic;
    if (encodedPic != null) {
      return encodedPic;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getFriendshipRequests(),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Friend Requests'),
            backgroundColor: Colors.blue,
          ),
          body: Column(
            children: [
              if (_accountList.isEmpty)
                Container(
                  color: Colors.yellow, // Hintergrundfarbe des Banners
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.info, color: Colors.black),
                      SizedBox(width: 8.0),
                      Text(
                        'No one wants to be friends with you.',
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
                    itemCount: _accountList.length,
                    itemBuilder: (context, index) {
                      Account account = _accountList[index];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(account.userName),
                        subtitle: Text(account.publicKey),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HoverableIconButton(
                              icon: Icons.clear,
                              hoverColor: Colors.redAccent,
                              onPressed: () async {
                                if (await friendshipService
                                    .deleteFriendshipRequest(
                                    account.accountId)) {
                                  _removeFriendRequestItem(index);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${account
                                          .userName} erfolgreich abgelehnt.'),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Anfrage fehlgeschlagen.'),
                                    ),
                                  );
                                }
                              }
                            ),
                            HoverableIconButton(icon: Icons.check, hoverColor: Colors.greenAccent, onPressed: () async {
                              if(await friendshipService.postFriendshipRequest(account.accountId)){
                                _removeFriendRequestItem(index);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${account.userName} erfolgreich hinzugefuegt.'),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Anfrage fehlgeschlagen.'),
                                  ),
                                );
                              }
                            },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        controller: _usernameController,
                        focusNode: _usernameFocusNode,
                        decoration: const InputDecoration(
                          hintText: "Benutzername eingeben",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2.0,
                            ),
                          ),
                        ),
                        onSubmitted: (_) {
                          String username = _usernameController.text.trim();
                          sendFriendshipRequest(context, username);
                        },
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    HoverableIconButton(icon: Icons.add_circle, hoverColor: Colors.greenAccent, onPressed: () async {
                      String username = _usernameController.text.trim();
                      sendFriendshipRequest(context, username);
                    }
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _friendsList.length,
                  itemBuilder: (context, index) {
                    Account account = _friendsList[index];
                    return ListTile(
                      leading: FutureBuilder<String?>(
                        future: _getImageFromDatabase(account.userName),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            // Zeige eine Fehlermeldung, wenn ein Fehler auftritt
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData && snapshot.data != null) {
                            // Zeige das Bild aus der Datenbank
                            final encodedPic = snapshot.data!;
                            final imageData = Uint8List.fromList(base64Decode(encodedPic));
                            return CircleAvatar(
                              radius: 20,
                              backgroundImage: MemoryImage(imageData),
                            );
                          } else {

                            return const Icon(Icons.person);

                          }
                        },
                      ),
                      title: Text(account.userName),
                      // subtitle: Text(account.publicKey),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HoverableIconButton( //Löschen des freundes
                              icon: Icons.clear,
                              hoverColor: Colors.redAccent,
                              onPressed: () async {
                                if (await friendshipService.deleteFriendFromFriendlist(account.accountId)){
                                  _deleteFriendFromFriendlist(index);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${account
                                          .userName} erfolgreich gelöscht.'),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Anfrage fehlgeschlagen.'),
                                    ),
                                  );
                                }
                              }
                          ),
                          HoverableIconButton(icon: Icons.manage_accounts_sharp, hoverColor: Colors.greenAccent, onPressed: () async { //Profil aufrufen können
                            final bool? shouldRefresh = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(builder: (context) => OtherProfilScreen(username: account.userName, publicKey: account.publicKey)),
                            );
                            if (shouldRefresh ?? false) {
                              setState(() {

                              });
                            }
                          },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  void sendFriendshipRequest(BuildContext context, String username) async {
    username = username.trim();

    if (username.isNotEmpty) {
      var account = await AccountInformationStore().getPublicInformationByUsername(username);

      if (await friendshipService.postFriendshipRequest(account.accountId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Freundschaftsanfrage erfolgreich ${account.userName} gesendet.'),
          ),
        );
        _usernameController.text = "";
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anfrage fehlgeschlagen.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Benutzername ist Leer.'),
        ),
      );
    }
  }
}

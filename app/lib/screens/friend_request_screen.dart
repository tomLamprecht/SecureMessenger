import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_test/models/account.dart';
import 'package:my_flutter_test/services/account_service.dart';

import '../services/friendship_service.dart';
import '../widgets/hoverable_button.dart';



class FriendRequestPage extends StatefulWidget {
  @override
  _FriendRequestPageState createState() => _FriendRequestPageState();
}

class _FriendRequestPageState extends State<FriendRequestPage> {
  List<Account> _accountList = [];

  final FriendshipService friendshipService = FriendshipService();
  final AccountService accountService = AccountService();

  List<bool> _isClearButtonHoveringList = [];
  List<bool> _isCheckButtonHoveringList = [];

  final TextEditingController _usernameController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();

  Future<void> _getFriendshipRequests() async {
    _accountList = await friendshipService.getFriendshipRequests();

    _isClearButtonHoveringList = List.generate(_accountList.length, (_) => false);
    _isCheckButtonHoveringList = List.generate(_accountList.length, (_) => false);
  }

  void _removeFriend(int index) {
    setState(() {
      _accountList.removeAt(index);
      _isClearButtonHoveringList.removeAt(index);
      _isCheckButtonHoveringList.removeAt(index);
    });
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                                  _removeFriend(index);
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
                                _removeFriend(index);
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
                        // onChanged: (value) {
                        //   setState(() {
                        //     // Hier können weitere Aktionen ausgeführt werden, z.B. Validierung des Benutzernamens
                        //   });
                        // },
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
            ],
          ),
        );
      }
    );
  }

  void sendFriendshipRequest(BuildContext context, String username) async {
    username = username.trim();

    if (username.isNotEmpty) {
      Account? account = await accountService.getAccountByUsername(username);

      if (account != null) {

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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_test/models/account.dart';
import 'package:my_flutter_test/services/account_service.dart';

import '../services/friendship_service.dart';



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

  TextEditingController _usernameController = TextEditingController();
  FocusNode _usernameFocusNode = FocusNode();
  // Weitere Zustände, um den Hover-Zustand für den Button zu verfolgen
  bool _isAddButtonHovering = false;

  Future<void> _getFriendshipRequests() async {
    print("Friendshiprequests");
    _accountList = await friendshipService.getFriendshipRequests();
    print("AccountList: $_accountList");

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

  Future<void> _sendFriendRequest(int accountId) async {
    bool friendshipResponse = await friendshipService.postFriendshipRequest(accountId);

  }

  Future<void> _acceptedFriendRequest(int accountId) async {
    bool friendshipResponse = await friendshipService.postFriendshipRequest(accountId);

    if(friendshipResponse){
      _accountList = await friendshipService.getFriendshipRequests();
    } else {
      //Todo: Banner oder so.
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getFriendshipRequests(), // todo: durch den FutureBuilder wird beim hovern immer der Request geschickt
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Friend Requests'),
          ),
          body: Column(
            children: [
              if (_accountList.isEmpty)
                Container(
                  color: Colors.yellow, // Hintergrundfarbe des Banners
                  padding: EdgeInsets.all(8.0),
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
                            MouseRegion(
                              onEnter: (_) {
                                setState(() {
                                  _isClearButtonHoveringList[index] = true;
                                });
                              },
                              onExit: (_) {
                                setState(() {
                                  _isClearButtonHoveringList[index] = false;
                                });
                              },
                              child: IconButton(
                                icon: Icon(Icons.clear),
                                color: _isClearButtonHoveringList[index] ? Colors.red : Colors.black,
                                onPressed: () async {
                                  if(await friendshipService.deleteFriendshipRequest(account.accountId)){
                                    _removeFriend(index);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${account.userName} erfolgreich abgelehnt.'),
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
                            ),
                            MouseRegion(
                              onEnter: (_) {
                                setState(() {
                                  _isCheckButtonHoveringList[index] = true;
                                });
                              },
                              onExit: (_) {
                                setState(() {
                                  _isCheckButtonHoveringList[index] = false;
                                });
                              },
                              child: IconButton(
                                icon: const Icon(Icons.check),
                                color: _isCheckButtonHoveringList[index] ? Colors.green : Colors.black,
                                onPressed: () async {
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
                      ),
                    ),
                    SizedBox(width: 8.0),
                    MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          _isAddButtonHovering = true;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          _isAddButtonHovering = false;
                        });
                      },
                      child: IconButton(
                        icon: Icon(Icons.add_circle),
                        color: _isAddButtonHovering ? Colors.green : Colors.black, // || _usernameFocusNode.hasFocus
                        onPressed: () async {
                          String username = _usernameController.text.trim();
                          print(username);
                          if (username.isNotEmpty) {
                            Account? account = await accountService.getAccountByUsername(username);
                            print("Account: $account");
                            if(account != null){
                              print("Account_Id: ${account.accountId}");
                              if(await friendshipService.postFriendshipRequest(account.accountId)){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Freundschaftsanfrage erfolgreich ${account.userName} gesendet.'), //TODO: Benutzername evtl entfernen
                                  ),
                                );
                                setState(() {
                                  _usernameController.text = "";
                                });
                              }else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Anfrage fehlgeschlagen.'),
                                  ),
                                );
                              }

                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Anfrage fehlgeschlagen.'), // TODO: Maybe Alternative, um Benutzernamen zu benutzen
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
                        },
                      ),
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
}

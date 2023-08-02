import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FriendRequestUser {
  final String username;
  final String publicKey;

  FriendRequestUser({required this.username, required this.publicKey});
}

class FriendRequestPage extends StatefulWidget {
  @override
  _FriendRequestPageState createState() => _FriendRequestPageState();
}

class _FriendRequestPageState extends State<FriendRequestPage> {
  List<FriendRequestUser> friendRequests = [
    FriendRequestUser(username: "User1", publicKey: "Public Key 1"),
    FriendRequestUser(username: "User2", publicKey: "Public Key 2"),
    FriendRequestUser(username: "User3", publicKey: "Public Key 3"),
    FriendRequestUser(username: "User4", publicKey: "Public Key 4"),
    FriendRequestUser(username: "User5", publicKey: "Public Key 5"),
  ];

  List<bool> _isClearButtonHoveringList = [];
  List<bool> _isCheckButtonHoveringList = [];

  TextEditingController _usernameController = TextEditingController();
  FocusNode _usernameFocusNode = FocusNode();
  // Weitere Zustände, um den Hover-Zustand für den Button zu verfolgen
  bool _isAddButtonHovering = false;

  @override
  void initState() {
    super.initState();
    _initializeHoverStates(); // Hover-Zustände initialisieren
  }

  void _initializeHoverStates() {
    _isClearButtonHoveringList = List.generate(friendRequests.length, (_) => false);
    _isCheckButtonHoveringList = List.generate(friendRequests.length, (_) => false);
  }

  Future<void> _sendFriendRequest(String username) async {
    final url = Uri.parse("https://DEIN_BACKEND_URL/sendfriendrequest"); // todo: Hier die URL zum Backend-Endpunkt einsetzen

    try {
      final response = await http.post(
        url,
        body: {"username": username},
      );

      if (response.statusCode == 200) {
        // todo: Erfolgreiche Anfrage
        // Hier können weitere Aktionen durchgeführt werden, z.B. Anzeige einer Bestätigungsmeldung
        print("Freundschaftsanfrage erfolgreich gesendet.");
      } else {
        // todo: Anfrage fehlgeschlagen
        print("Anfrage fehlgeschlagen. Statuscode: ${response.statusCode}");
      }
    } catch (e) {
      // todo: Fehler beim Anfrageversuch
      print("Fehler bei der Anfrage: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend Requests'),
      ),
      body: Column(
        children: [
      Expanded(
      child: ListView.builder(
      itemCount: friendRequests.length,
        itemBuilder: (context, index) {
          FriendRequestUser friendRequest = friendRequests[index];
          return ListTile(
            leading: Icon(Icons.person),
            title: Text(friendRequest.username),
            subtitle: Text(friendRequest.publicKey),
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
                    onPressed: () {
                      // todo: Aktion für Ablehnen-Button
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
                    icon: Icon(Icons.check),
                    color: _isCheckButtonHoveringList[index] ? Colors.green : Colors.black,
                    onPressed: () {
                      // todo: Aktion für Akzeptieren-Button
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
                decoration: InputDecoration(
                  hintText: "Benutzername eingeben",
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    // Hier können weitere Aktionen ausgeführt werden, z.B. Validierung des Benutzernamens
                  });
                },
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
                color: _isAddButtonHovering || _usernameFocusNode.hasFocus ? Colors.green : Colors.black,
                onPressed: () {
                  // Hier den Benutzernamen an das Backend senden
                  String username = _usernameController.text.trim();
                  if (username.isNotEmpty) {
                    _sendFriendRequest(username);
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
}

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_flutter_test/models/account_id_to_encrypted_sym_key.dart';
import 'package:my_flutter_test/services/chats_service.dart';
import 'package:my_flutter_test/services/files/aes_helper.dart';
import 'package:my_flutter_test/services/files/ecc_helper.dart';
import 'package:my_flutter_test/services/stores/who_am_i_store.dart';

import '../screens/friend_request_screen.dart';
import '../services/stores/ecc_key_store.dart';

class CreateChatWidget extends StatefulWidget {
  const CreateChatWidget({super.key});


  @override
  State<CreateChatWidget> createState() => _CreateChatWidgetState();
}

class Account {
  final int id;
  final String username;
  final String publicKey;
  bool isSelected;

  Account(this.id, this.username, this.publicKey, this.isSelected);
}

class _CreateChatWidgetState extends State<CreateChatWidget> {
  List<Account> accounts = [
    Account(1, 'user1', 'public_key_1', false),
    Account(2, 'user2', 'public_key_2', false),
    Account(3, 'user3', 'public_key_3', false),
    Account(4, 'user4', 'public_key_4', false),
    Account(15, 'user5', 'public_key_5', false),
  ];
  List<Account> chatAccounts = [];

  @override
  void initState() {
    super.initState();
    fetchFriends(); // Fetch "Freunde" vom Backend
  }

  Future<void> createChat() async {
    var chatName = "";
    var chatDescription = "";

    if (EccKeyStore().publicKey == null || WhoAmIStore().accountId == null) {
      throw Error(); // todo: add message
    }
    var eccHelper = ECCHelper();
    // 1. create sym Key
    var symKey = AesHelper.createRandomBase64Key();

    // 2. get Accounts for chat
    var accountsInChat = accounts.where((element) => element.isSelected);

    // 3. create encrypted sym keys
    List<AccountIdToEncryptedSymKey> encryptedSymKeys = [];
    var ownEncryptedSymKey = eccHelper.encodeWithPubKey(EccKeyStore().publicKey!, symKey);
    encryptedSymKeys.add(AccountIdToEncryptedSymKey(accountId: WhoAmIStore().accountId!, encryptedSymmetricKey: ownEncryptedSymKey));
    for (var account in accountsInChat) {
      var encodedSymKey = eccHelper.encodeWithPubKeyString(account.publicKey, symKey);
      encryptedSymKeys.add(AccountIdToEncryptedSymKey(accountId: account.id, encryptedSymmetricKey: encodedSymKey));
    }

    // 4. Create chat
    await ChatsService().createChatNew(chatName, chatDescription, encryptedSymKeys);
  }

  Future<void> fetchFriends() async {
    final url = Uri.parse("https://DEIN_BACKEND_URL/getfriends"); // Hier die URL zum Backend-Endpunkt einsetzen

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Account> fetchedAccounts = data.map((item) => Account(item['id'], item['username'], item['publicKey'], false)).toList();

        setState(() {
          accounts = fetchedAccounts;
        });
      } else {
        print("Anfrage fehlgeschlagen. Statuscode: ${response.statusCode}");
      }
    } catch (e) {
      print("Fehler bei der Anfrage: $e");
    }
  }

  Future<void> sendChatAccountsToBackend(List<Account> chatAccounts) async {
    await createChat();
    final url = Uri.parse("https://DEIN_BACKEND_URL/sendchataccounts"); // Hier die URL zum Backend-Endpunkt einsetzen

    try {
      final List<String> selectedAccounts = chatAccounts.map((account) => account.username).toList();
      final response = await http.post(
        url,
        body: jsonEncode({"accounts": selectedAccounts}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        // Erfolgreiche Anfrage
        print("Chat-Accounts erfolgreich an das Backend gesendet.");
      } else {
        // Anfrage fehlgeschlagen
        print("Anfrage fehlgeschlagen. Statuscode: ${response.statusCode}");
      }
    } catch (e) {
      // Fehler beim Anfrageversuch
      print("Fehler bei der Anfrage: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Chat'),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt_1),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FriendRequestPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ListView.builder(
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Checkbox(
                value: accounts[index].isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    accounts[index].isSelected = value ?? false;
                    if (value ?? false) {
                      chatAccounts.add(accounts[index]);
                    } else {
                      chatAccounts.remove(accounts[index]);
                    }
                  });
                },
              ),
              title: Text(accounts[index].username),
              subtitle: Text(accounts[index].publicKey),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await createChat();
        },
        child: Icon(Icons.arrow_circle_right_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}


// class _CreateChatWidgetState extends State<CreateChatWidget> {
//   late TextEditingController _controller;
//
//   List<String> myList = List.generate(0, (index) => 'Sample Item - $index');
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   void _perform_chat_creation(BuildContext context) async {
//     TextEditingController _usernameController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Chat erstellen'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 autofocus: true,
//                 controller: _usernameController,
//                 decoration: InputDecoration(hintText: 'Nutzername des Freundes'),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text('Abbrechen'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 String targetUserName = _usernameController.text.trim();
//                 if (targetUserName.isNotEmpty) {
//                   final url = 'http://localhost:8080/chats';
//                   final response = await http.post(
//                     Uri.parse(url),
//                     headers: {'Content-Type': 'application/json'},
//                     body: json.encode({'targetUserName': targetUserName}),
//                   );
//
//                   if (response.statusCode == 201) {
//                     // You can perform additional actions upon successful chat creation.
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Chat erfolgreich erstellt!')),
//                     );
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Fehler beim Erstellen des Chats!')),
//                     );
//                   }
//                 }
//
//                 Navigator.of(context).pop();
//               },
//               child: Text('Chat erstellen'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _navigateToNewChatPage(BuildContext context) {
//     // This function is empty for now
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ElevatedButton(
//           onPressed: () => _perform_chat_creation(context),
//           child: Icon(Icons.add),
//         ),
//       ],
//     );
//   }
// }
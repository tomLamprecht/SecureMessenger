import 'dart:convert';

import 'dart:typed_data';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_test/screens/chat_overview_screen.dart';

import 'package:my_flutter_test/services/friendship_service.dart';
import 'package:my_flutter_test/services/stores/who_am_i_store.dart';

import '../models/account.dart';
import '../models/account_id_to_encrypted_sym_key.dart';

import '../models/chat_to_account.dart';
import '../models/chatkey.dart';
import '../services/chats_service.dart';
import '../services/encryption_service.dart';
import '../services/files/ecc_helper.dart';

ValueNotifier<List<Account>> membersNotifier = ValueNotifier<List<Account>>([]);

class Group {
  int chatId;
  String? title;
  String? description;
  DateTime creationDate;
  List<Account> members;
  List<Account> membersToShow = [];
  Account currentUser;
  Uint8List? encodedGroupPic;

  Group({
    required this.chatId,
    required this.title,
    required this.description,
    required this.creationDate,
    required this.members,
    required this.currentUser,
    this.encodedGroupPic,
  });
}

class Member {
  String name;
  bool isAdmin;

  Member({required this.name, this.isAdmin = false});
}

class ChatDetailsScreen extends StatefulWidget {
  final int chatId;

  const ChatDetailsScreen({Key? key, required this.chatId}) : super(key: key);

  @override
  _ChatDetailsScreenState createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  late Future<Group?> _groupFuture;
  bool? isAdmin;
  String title = "Group Overview";


  @override
  void initState() {
    super.initState();
    _groupFuture = _fetchData();
  }

  Future<Group?> _fetchData() async {
    var chatToUser = await ChatsService().getChatToUser(widget.chatId);
    if (chatToUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Failed to load chat details. Please try again.")));
      return null;
    }

    var members = await ChatsService().getAllAccountsInChat(widget.chatId);
    membersNotifier.value = members;

    setState(() {
      title = chatToUser.chat.name;
      isAdmin = chatToUser.isAdmin;
    });

    return Group(
      chatId: widget.chatId,
      title: chatToUser.chat.name,
      description: chatToUser.chat.description,
      creationDate: DateTime.now(),
      // Adjust based on your model
      members: members,
      currentUser: members.firstWhere(
          (element) => element.accountId == WhoAmIStore().accountId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<Group?>(
        future: _groupFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: ElevatedButton(
                onPressed: () => setState(() {
                  _groupFuture = _fetchData();
                }),
                child: const Text('Retry'),
              ),
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                GroupHeader(group: snapshot.data!),
                // Wrap AccountList with ValueListenableBuilder
                ValueListenableBuilder<List<Account>>(
                  valueListenable: membersNotifier,
                  builder: (context, members, child) {
                    return AccountList(
                        accounts: members,
                        isAdmin: isAdmin!,
                        chatId: widget.chatId);
                  },
                ),
                GroupActions(group: snapshot.data!),
              ],
            ),
          );
        },
      ),
    );
  }
}

class GroupHeader extends StatefulWidget {
  final Group group;

  GroupHeader({required this.group});

  @override
  _GroupHeaderState createState() => _GroupHeaderState();
}

class _GroupHeaderState extends State<GroupHeader> {
  Uint8List? _chosenFile;
  bool hasGroupPic = true;
  late String key;

  // GroupHeader({required this.group});

  Future<void> _pickFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      if (['jpg', 'jpeg', 'png', 'gif'].contains(file.extension!.toLowerCase())) {
        Uint8List imageBytes = file.bytes!;
        // Blob imageBlob = Blob(imageBytes);

        //Get Key from Backend and Decrypt it
        Chatkey? chatkey = await ChatsService().getOwnSymmetricKeyOfChat(widget.group.chatId);
        String? key = ECCHelper().decryptByAESAndECDHUsingString(chatkey!.encryptedByPublicKey, chatkey.value);

        if(key != null){
          this.key = key;
          // if(await ChatsService().updateGroupPicFromChat(aesEncrypt(base64Encode(imageBytes), "password"), widget.group.chatId))
          if(await ChatsService().updateGroupPicFromChat(base64Encode(imageBytes), widget.group.chatId)){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bild erfolgreich hochgeladen'),
              ),
            );
            setState(() {
              _chosenFile = imageBytes;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fehler beim speichern des Bildes.'),
              ),
            );
          }
        }
      } else {
        // Datei ist kein Bild mit erlaubter Erweiterung
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ungültige Dateierweiterung. Wählen Sie ein Bild aus.'),
          ),
        );
      }
    } else {
      // Der Benutzer hat die Auswahl abgebrochen
    }

  }

  Future<String?> _getImageFromDatabase() async {
    var chatToAcc = await ChatsService().getChatToUser(widget.group.chatId);
    String? encodedPic = chatToAcc?.chat?.encodedGroupPic;
    if (chatToAcc != null && chatToAcc.chat != null && encodedPic != null) {
      return encodedPic;
    }
    return null;
  }

  Future<void> _deleteFile(BuildContext context) async {
    if(await ChatsService().deleteGroupPicFromChat(widget.group.chatId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bild erfolgreich gelöscht'),
        ),
      );
      hasGroupPic = false;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fehler beim löschen des Bildes.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () { //bearbeiten von Bild
                _pickFile(context);
              },
              icon: Icon(Icons.edit),
              color: Colors.blue,
            ),
                FutureBuilder<String?>(
              future: _getImageFromDatabase(),
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
                    radius: 100,
                    backgroundImage: MemoryImage(imageData),
                  );
                } else {
                  // Zeige das Icon, wenn kein Bild in der Datenbank vorhanden ist
                  return const CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.blue,
                    child: Icon(
                      Icons.supervised_user_circle,
                      size: 60,
                      color: Colors.white,
                    ),
                  );
                }
              },
            ),
            // hasGroupPic
            //     ? CircleAvatar(
            //   radius: 80,
            //   backgroundColor: Colors.blue,
            //   child: Icon(
            //     Icons.supervised_user_circle,
            //     size: 60,
            //     color: Colors.white,
            //   ),
            // )
            //     : Container(),
            IconButton(
              onPressed: () {
                _deleteFile(context);
              },
              icon: Icon(Icons.delete),
              color: Colors.red,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.group.description ?? "",
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(
          'Created: ${widget.group.creationDate.toLocal()}',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    ));
  }
}

class AccountList extends StatefulWidget {
  final List<Account> accounts;
  final bool isAdmin;
  final int chatId;

  const AccountList(
      {super.key,
      required this.accounts,
      required this.isAdmin,
      required this.chatId});

  @override
  _AccountListState createState() => _AccountListState();
}

class _AccountListState extends State<AccountList> {
  TextEditingController controller = TextEditingController();
  String query = "";
  List<Account> accountsToShow = [];
  bool isAdmin = false;
  late int chatId;
  late List<Account> accounts;

  @override
  void initState() {
    super.initState();
    accountsToShow = widget.accounts;
    isAdmin = widget.isAdmin;
    accounts = widget.accounts;
    chatId = widget.chatId;
  }

  Future<void> refreshData() async {
    var membersInGroup = await ChatsService().getAllAccountsInChat(chatId);
    setState(() {
      accounts = membersInGroup;
      accountsToShow = membersInGroup
          .where((element) =>
              element.userName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
    membersNotifier.value = membersInGroup;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ChatsService().getAllChatToAccountsInChat(chatId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                  "Error while loading Chat Information. Try again later."),
            ));
          }
          List<ChatToAccount> accountsInChat = snapshot.data!;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: CustomSearchBar(
                  controller: controller,
                  onChanged: _handleSearch,
                  accounts: accounts,
                ),
              ),
              Text("${accountsToShow.length} / ${widget.accounts.length}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400.0),
                child: ListView.separated(
                  itemCount: accountsToShow.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: Colors.grey),
                  itemBuilder: (context, index) {
                    final account = accountsToShow[index];
                    int startIndex = account.userName.length;
                    if (query.isNotEmpty) {
                      startIndex = account.userName
                          .toLowerCase()
                          .indexOf(query.toLowerCase());
                    }
                    return ListTile(
                      onTap: () => {},
                      // add hover effect
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueGrey,
                        child: Text(account.userName[0].toUpperCase()),
                      ),
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: account.userName.substring(0, startIndex),
                            ),
                            TextSpan(
                              text: account.userName.substring(
                                  startIndex, startIndex + query.length),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: account.userName
                                  .substring(startIndex + query.length),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      trailing: isAdmin &&
                              account.accountId != WhoAmIStore().accountId
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Tooltip(
                                  message: "Kick out of chat",
                                  child: IconButton(
                                    icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.redAccent),
                                    onPressed: () async {
                                      var wasSuccessful = await ChatsService()
                                          .removeAccountFromChat(
                                              chatId, account.accountId);
                                      if (wasSuccessful) {
                                        setState(() {
                                          accountsToShow.remove(account);
                                          membersNotifier.value.remove(account);
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "Something went wrong! Please try again later.")));
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(
                                    width: 10), // Spacing between buttons
                                if (accountsInChat.any((element) =>
                                    element.account.accountId ==
                                        account.accountId &&
                                    element.isAdmin))
                                  Tooltip(
                                    message: "Remove admin permissions",
                                    child: IconButton(
                                      icon: const Icon(Icons.shield,
                                          color: Colors.redAccent),
                                      onPressed: () async {
                                        var wasSuccessful = await ChatsService()
                                            .updateAdminRoleSettingOfAccount(
                                                chatId,
                                                account.accountId,
                                                false);
                                        if (wasSuccessful) {
                                          setState(() {});
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      "Something went wrong! Please try again later.")));
                                        }
                                      },
                                    ),
                                  )
                                else
                                  Tooltip(
                                    message: "Grant admin permissions",
                                    child: IconButton(
                                      icon: const Icon(Icons.shield,
                                          color: Colors.blueAccent),
                                      onPressed: () async {
                                        var wasSuccessful = await ChatsService()
                                            .updateAdminRoleSettingOfAccount(
                                                chatId,
                                                account.accountId,
                                                true);
                                        if (wasSuccessful) {
                                          setState(() {});
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      "Something went wrong! Please try again later.")));
                                        }
                                      },
                                    ),
                                  )
                              ],
                            )
                          : null,
                    );
                  },
                ),
              ),
              if (isAdmin)
                AddMemberButton(
                  accounts: accounts,
                  chatId: chatId,
                  refreshData: refreshData,
                )
            ],
          );
        });
  }

  void _handleSearch(String text) {
    setState(() {
      query = text;
      accountsToShow = widget.accounts
          .where((element) =>
              element.userName.toLowerCase().contains(text.toLowerCase()))
          .toList();
    });
  }
}

class GroupActions extends StatelessWidget {
  final Group group;

  const GroupActions({required this.group});

  @override
  Widget build(BuildContext context) {
    return group.members.length == 1
        ? ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Delete Group'),
            onPressed: () async {
              await deleteGroup(context);
            },
            style: ElevatedButton.styleFrom(primary: Colors.red),
          )
        : ElevatedButton.icon(
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Leave Chat'),
            onPressed: () async {
              await leaveChat(context);
            },
            style: ElevatedButton.styleFrom(primary: Colors.blueGrey),
          );
  }

  Future<void> leaveChat(BuildContext context) async {
    var errorMessage = await ChatsService().leaveChat(group.chatId);
    if (errorMessage == "") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatOverviewPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  Future<void> deleteGroup(BuildContext context) async {
    var wasSuccessful = await ChatsService().deleteChat(group.chatId);
    if (wasSuccessful) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatOverviewPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Something went wrong! Please try again later.")));
    }
  }
}

class AddMemberButton extends StatelessWidget {
  final List<Account> accounts;
  final int chatId;
  final Function refreshData;

  const AddMemberButton({
    required this.accounts,
    required this.chatId,
    required this.refreshData,
  });

  Future<List<Account>?> showAccountSelectionModal(BuildContext context) async {
    var friends = await FriendshipService().getFriendships();
    var availableFriends = friends
        .where((element) =>
            !accounts.any((account) => account.accountId == element.accountId))
        .toList();
    return await showModalBottomSheet<List<Account>>(
      context: context,
      builder: (BuildContext bc) {
        return AccountSelectionModal(accounts: availableFriends);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () async {
          List<Account>? selectedAccounts =
              await showAccountSelectionModal(context);
          if (selectedAccounts != null && selectedAccounts.isNotEmpty) {
            var currentAccountToChat =
                await ChatsService().getChatToUser(chatId);
            List<AccountIdToEncryptedSymKey> encryptedSymKeys = [];
            var eccHelper = ECCHelper();
            for (var account in selectedAccounts) {
              var encodedSymKey = eccHelper.encryptWithPubKeyStringUsingECDH(
                  account.publicKey, eccHelper.decryptByAESAndECDHUsingString( currentAccountToChat!.encryptedBy.publicKey, currentAccountToChat.key) );
              encryptedSymKeys.add(AccountIdToEncryptedSymKey(
                  accountId: account.accountId,
                  encryptedSymmetricKey: encodedSymKey));
            }
            await ChatsService().addAccountsToGroup(chatId, encryptedSymKeys);

            refreshData();
          }
        },
        child: const Text('Add Member'),
      ),
    );
  }
}

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final List<Account> accounts;

  const CustomSearchBar(
      {required this.controller,
      required this.onChanged,
      required this.accounts});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search Members',
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
        ),
      ),
    );
  }
}

class AccountSelectionModal extends StatefulWidget {
  final List<Account> accounts;

  const AccountSelectionModal({required this.accounts});

  @override
  _AccountSelectionModalState createState() => _AccountSelectionModalState();
}

class _AccountSelectionModalState extends State<AccountSelectionModal> {
  late Map<int, bool> _selectedAccounts;

  @override
  void initState() {
    super.initState();
    _selectedAccounts = {};
    for (var account in widget.accounts) {
      _selectedAccounts[account.accountId] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...widget.accounts.map((account) => CheckboxListTile(
                title: Text(account.userName),
                value: _selectedAccounts[account.accountId],
                onChanged: (bool? value) {
                  setState(() {
                    _selectedAccounts[account.accountId] = value!;
                  });
                },
              )),
          const Spacer(flex: 2),
          ElevatedButton(
            onPressed: () {
              List<Account> selected = [];
              _selectedAccounts.forEach((id, isSelected) {
                if (isSelected) {
                  selected.add(widget.accounts
                      .firstWhere((account) => account.accountId == id));
                }
              });
              Navigator.pop(context, selected);
            },
            child: const Text('Add members'),
          ),
        ],
      ),
    );
  }
}

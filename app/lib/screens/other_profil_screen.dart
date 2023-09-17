import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_test/services/account_service.dart';
import 'package:my_flutter_test/services/stores/account_information_store.dart';
import '../services/chats_service.dart';
import '../services/stores/who_am_i_store.dart';

class OtherProfilScreen extends StatefulWidget {
  String username;
  String publicKey;

  OtherProfilScreen({required this.username, required this.publicKey});

  @override
  _OtherProfilScreenState createState() => _OtherProfilScreenState();
}

class _OtherProfilScreenState extends State<OtherProfilScreen> {

  Uint8List? _chosenFile;
  bool hasProfilPic = true;

  Future<String?> _getImageFromDatabase(String username) async {

    var account = await AccountInformationStore().getPublicInformationByUsername(username);

    if(account == null) {
      return null;
    }
    String? encodedPic = account.encodedProfilePic;

    if (encodedPic != null) {
      return encodedPic;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles Screen'),
      ),
      body: Material(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FutureBuilder<String?>(
                      future: _getImageFromDatabase(widget.username),
                      // Funktion zum Abrufen des Bildes aus der Datenbank
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          // Zeige eine Fehlermeldung, wenn ein Fehler auftritt
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData && snapshot.data != null) {
                          // Zeige das Bild aus der Datenbank
                          final encodedPic = snapshot.data!;
                          final imageData = Uint8List.fromList(base64Decode(encodedPic));
                          return CircleAvatar(
                            radius: 100,
                            backgroundImage: MemoryImage(imageData),
                          );
                        } else {
                          // Zeige das Icon, wenn kein Bild in der Datenbank vorhanden ist
                          return CircleAvatar(
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
                  ],
                ),
                SizedBox(height: 16),
                ProfileInfoItem(
                  title: 'Username',
                  value: widget.username ?? 'N/A',
                ),
                SizedBox(height: 16),
                ProfileInfoItem(
                  title: 'Public Key',
                  value: widget.publicKey ?? 'N/A',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileInfoItem extends StatelessWidget {
  final String title;
  final String value;

  ProfileInfoItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 8),
        Center(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(OtherProfilScreen(username: 'Test', publicKey: '',));
}

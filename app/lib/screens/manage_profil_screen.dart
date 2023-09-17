import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_test/services/account_service.dart';
import '../services/chats_service.dart';
import '../services/stores/account_information_store.dart';
import '../services/stores/who_am_i_store.dart';

class ManageProfilPage extends StatefulWidget {
  @override
  _ManageProfilPageState createState() => _ManageProfilPageState();
}

class _ManageProfilPageState extends State<ManageProfilPage> {

  Uint8List? _chosenFile;
  bool hasProfilPic = true;

  //TODO: Abänderung auf ACCount
  Future<void> _pickFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      if (['jpg', 'jpeg', 'png', 'gif'].contains(file.extension!.toLowerCase())) {
        Uint8List imageBytes = file.bytes!;

          if(await AccountService().updateProfilPic(base64Encode(imageBytes)))
          {
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

  Future<void> _deleteFile(BuildContext context) async {

      if(await AccountService().deleteProfilPic()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bild erfolgreich gelöscht'),
          ),
        );
        hasProfilPic = false;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler beim löschen des Bildes.'),
          ),
        );
    }
  }

  Future<String?> _getImageFromDatabase() async {
      var username = WhoAmIStore().username;

      if (username == null) {
        throw Exception("No user is signed in, but the regarding profile picture is requested.");
      }

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
          title: Text('Manage Profil'),
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
                      // hasProfilPic
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
                  SizedBox(height: 16),
                  ProfileInfoItem(
                    title: 'Your Username',
                    value: WhoAmIStore().username ?? 'N/A',
                  ),
                  SizedBox(height: 16),
                  ProfileInfoItem(
                    title: 'Your Public Key',
                    value: WhoAmIStore().publicKey ?? 'N/A',
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
  runApp(ManageProfilPage());
}

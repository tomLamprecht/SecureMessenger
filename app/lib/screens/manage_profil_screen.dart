import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:securemessenger/services/account_service.dart';
import '../services/stores/account_information_store.dart';
import '../services/stores/who_am_i_store.dart';

class ManageProfilPage extends StatefulWidget {
  @override
  _ManageProfilPageState createState() => _ManageProfilPageState();
}

class _ManageProfilPageState extends State<ManageProfilPage> {

  bool hasProfilPic = true;

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
                content: Text('Image uploaded successfully.'),
              ),
            );
            setState(() {
              AccountInformationStore().invalidateForUsername(WhoAmIStore().username!);
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error when saving the image.'),
              ),
            );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid file extension. Select an image.'),
          ),
        );
      }
    } else {
      // The user has canceled the selection.
    }
  }

  Future<void> _deleteFile(BuildContext context) async {

      if(await AccountService().deleteProfilPic()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image successfully deleted'),
          ),
        );
        hasProfilPic = false;
        setState(() {
          AccountInformationStore().invalidateForUsername(WhoAmIStore().username!);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error deleting the image.'),
          ),
        );
    }
  }

  Future<Uint8List?> _getImageFromDatabase() async {
      var username = WhoAmIStore().username;

      if (username == null) {
        throw Exception("No user is signed in, but the regarding profile picture is requested.");
      }

      var encodedPic = await AccountInformationStore().getProfilePicByUsername(username);

      if (encodedPic != null) {
        return encodedPic;
      }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Manage Profil'),
        ),
        body: Material(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          _pickFile(context);
                        },
                        icon: const Icon(Icons.edit),
                        color: Colors.blue,
                      ),
                      FutureBuilder<Uint8List?>(
                        future: _getImageFromDatabase(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text('An error occurred while loading the image from the database.');
                          } else if (snapshot.hasData && snapshot.data != null) {
                            final encodedPic = snapshot.data!;
                            final imageData = encodedPic;
                            return CircleAvatar(
                              radius: 100,
                              backgroundImage: MemoryImage(imageData),
                            );
                          } else {
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
                      IconButton(
                        onPressed: () {
                          _deleteFile(context);
                        },
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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

  const ProfileInfoItem({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}

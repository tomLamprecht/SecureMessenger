import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:securemessenger/services/stores/account_information_store.dart';

class OtherProfilScreen extends StatefulWidget {
  String username;
  String publicKey;

  OtherProfilScreen({super.key, required this.username, required this.publicKey});

  @override
  _OtherProfilScreenState createState() => _OtherProfilScreenState();
}

class _OtherProfilScreenState extends State<OtherProfilScreen> {

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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FutureBuilder<String?>(
                      future: _getImageFromDatabase(widget.username),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text('An error occurred while loading the image from the database.');
                        } else if (snapshot.hasData && snapshot.data != null) {
                          final encodedPic = snapshot.data!;
                          final imageData = Uint8List.fromList(base64Decode(encodedPic));
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
                  ],
                ),
                const SizedBox(height: 16),
                ProfileInfoItem(
                  title: 'Username',
                  value: widget.username ?? 'N/A',
                ),
                const SizedBox(height: 16),
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

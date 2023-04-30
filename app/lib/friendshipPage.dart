import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'friendship.dart';

class FriendshipPage extends StatefulWidget {
  @override
  _FriendshipPageState createState() => _FriendshipPageState();
}

class _FriendshipPageState extends State<FriendshipPage> {
  final _friendIdController = TextEditingController();
  List<Friendship> _friendshipList = [];

  void _getFriendshipRequests() async {
    final response =
    await http.get(Uri.parse('http://localhost:8080/friendships/'));
    if (response.statusCode == 200) {
      List<Friendship> friendshipRequests = [];
      final jsonList = json.decode(response.body);
      for (var json in jsonList) {
        friendshipRequests.add(Friendship.fromJson(json));
      }
      setState(() {
        _friendshipList = friendshipRequests;
      });
    } else {
      throw Exception('Failed to load friendship requests');
    }
  }

  void _createFriendshipRequest() async {
    final response = await http.post(Uri.parse(
        'http://localhost:8080/friendships/${_friendIdController.text}'));
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friendship request sent successfully')));
      _friendIdController.clear();
      _getFriendshipRequests();
    } else {
      throw Exception('Failed to create friendship request');
    }
  }

  void _deleteFriendshipRequest(int toUserId) async {
    final response =
    await http.delete(Uri.parse('http://localhost:8080/friendships/$toUserId'));
    if (response.statusCode == 204) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Friendship request deleted')));
      _getFriendshipRequests();
    } else {
      throw Exception('Failed to delete friendship request');
    }
  }

  @override
  void initState() {
    super.initState();
    _getFriendshipRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Freundschaftsanfragen'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Wie heißt dein potenzieller Freund?'),
              keyboardType: TextInputType.number,
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createFriendshipRequest,
              child: const Text('Freundschaftsanfrage senden'),
            ),
            const SizedBox(height: 32),
            const Text('Deine offnen Freundschaftsanfragen:'),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _friendshipList.length,
                itemBuilder: (context, index) {
                  final friendshipRequest = _friendshipList[index];
                  return ListTile(
                    title: Text('From: ${friendshipRequest.fromUserId}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () =>
                          _deleteFriendshipRequest(friendshipRequest.toUserId),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

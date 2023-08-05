import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_flutter_test/services/files/rsa_helper.dart';

import '../services/encryption_service.dart';
import '../services/message_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatTitle;
  final int chatId;

  const ChatScreen({super.key, required this.chatTitle, required this.chatId});

  @override
  ChatScreenState createState() => ChatScreenState(chatId: chatId);
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final FocusNode _textFieldFocus = FocusNode();
  final int chatId;
  late final String chatKey;


  bool _isComposing = false;

  ChatScreenState({required this.chatId});

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) { _textFieldFocus.requestFocus(); });
    getKeyOfChat(chatId).then((value) => _saveChatKeyAndGetAllMessages(value!));
  }

  @override
  void dispose() {
    for (ChatMessage message in _messages) {
      message.animationController.dispose();
    }
    super.dispose();
  }

  void _saveChatKeyAndGetAllMessages(String chatKey) async {

    //TODO Key is still RSA encrypted at this point. So we first gotta decrypt the key! However i assume Tim and Valerie gonna do this in their branch. So i first wait...

    //this.chatKey = chatKey;
    this.chatKey = "Ekwp0wkd0PE2aasuEb1Z4oNKX1y36TCy3dRF47H+DCs="; //DUMMY DATA TODO DELETE FOR PRODUCTION

    var temp = await readAllMessages(chatId);

    _messages.addAll(temp.map((e) => ChatMessage(text: aesDecrypt(e.value, chatKey), animationController: AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 0),
    ))));
  }

  void _sendMessageEncrypted(String message) {
    sendMessage(chatId, aesEncrypt(message, chatKey));
  }

  void _handleSubmitted(String text) {
    _sendMessageEncrypted(text);

    _textController.clear();
    setState(() {
      _isComposing = false;
    });

    ChatMessage message = ChatMessage(
      text: text,
      animationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );

    setState(() {
      _messages.insert(0, message);
    });

    message.animationController.forward();

    _textFieldFocus.requestFocus();
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: _textController,
              focusNode: _textFieldFocus,
              onChanged: (String text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: _handleSubmitted,
              decoration: const InputDecoration.collapsed(hintText: 'Send a message'),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: const Icon(Icons.send),
              onPressed: _isComposing
                  ? () => _handleSubmitted(_textController.text)
                  : null,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatTitle),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _messages[index],
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

}

class ChatMessage extends StatelessWidget {
  final String text;
  final AnimationController animationController;

  const ChatMessage({super.key, required this.text, required this.animationController});


  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor:
      CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: const CircleAvatar(
                foregroundColor: Colors.cyan,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Username',
                      style: Theme.of(context).textTheme.subtitle1),
                  Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: Text(text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
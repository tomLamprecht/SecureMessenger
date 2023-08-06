import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_flutter_test/models/message.dart';
import 'package:my_flutter_test/services/api/api_config.dart';
import 'package:my_flutter_test/services/files/rsa_helper.dart';
import 'package:my_flutter_test/services/websocket/websocket_service.dart';

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
    getSessionKey(chatId).then((value) => createWebsocketConnection(value));
  }

  @override
  void dispose() {
    for (ChatMessage message in _messages) {
      message.animationController.dispose();
    }
    super.dispose();
  }

  void createWebsocketConnection(String sessionKey) async{
    String url = '${ApiConfig.websocketBaseUrl}/sub';
    log("trying to get a connection to the websocket $url ...");
    var session = WebSocketService();
    await session.connect(url, sessionKey);
    session.messages.listen((jsonMessage) {
      log("incomming message from Websocket: $jsonMessage");
      var parsedMessage = Message.fromJson(json.decode(jsonMessage), chatId);

      AnimationController animationControllerForIncommingMessages = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      );

      var chatMessage = _parseMessageToChatMessage(parsedMessage, animationControllerForIncommingMessages);

      setState(() {
        _messages.insert(0, chatMessage);
      });

      animationControllerForIncommingMessages.forward();
    });
  }


  ChatMessage _parseMessageToChatMessage(Message message, AnimationController animationController){
    return ChatMessage(fromUserName: message.fromUserName, timestamp: message.timestamp, text: aesDecrypt(message.value, this.chatKey), animationController: animationController);

  }

  void _saveChatKeyAndGetAllMessages(String chatKey) async {

    //TODO Key is still RSA encrypted at this point. So we first gotta decrypt the key! However i assume Tim and Valerie gonna do this in their branch. So i first wait...

    //this.chatKey = chatKey;
    this.chatKey = "Ekwp0wkd0PE2aasuEb1Z4oNKX1y36TCy3dRF47H+DCs="; //DUMMY DATA TODO DELETE FOR PRODUCTION

    AnimationController animationControllerForInitialLoading = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    var temp = await readAllMessages(chatId);
    Iterable<ChatMessage> chatMessages = [];
    setState(() {
      chatMessages = temp.map((e) => _parseMessageToChatMessage(e, animationControllerForInitialLoading));
      _messages.addAll(chatMessages);
    });

    animationControllerForInitialLoading.forward();
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
  final String fromUserName;
  final String text;
  final DateTime timestamp;
  final AnimationController animationController;

  const ChatMessage({Key? key, required this.fromUserName, required this.timestamp, required this.text, required this.animationController}): super(key: key);

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
              child: CircleAvatar(
                backgroundColor: _getColorFromUserName(fromUserName),
                foregroundColor: Colors.white, // Just in case you put any child widget in your avatar that need to contrast with the background
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(fromUserName,
                          style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(width: 10), // Add some space between the username and timestamp
                      Text(
                        timestamp.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
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

  Color _getColorFromUserName(String userName) {
    final int hash = userName.hashCode.abs();
    final double hue = (hash % 360).toDouble();
    return HSVColor.fromAHSV(1.0, hue, 0.7, 0.9).toColor();
  }
}
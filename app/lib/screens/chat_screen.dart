import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_flutter_test/models/message.dart';
import 'package:my_flutter_test/services/api/api_config.dart';
import 'package:my_flutter_test/services/websocket/websocket_service.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../services/encryption_service.dart';
import '../services/message_service.dart';
import '../services/stores/who_am_i_store.dart';

class ChatScreen extends StatefulWidget {
  final String chatTitle;
  final int chatId;

  const ChatScreen({super.key, required this.chatTitle, required this.chatId});

  @override
  ChatScreenState createState() => ChatScreenState(chatId: chatId);
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  int REQUEST_SIZE_OF_MESSAGES = 1;

  final TextEditingController _textController = TextEditingController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final List<ChatMessage> _messages = [];
  final FocusNode _textFieldFocus = FocusNode();
  final int chatId;
  late final String chatKey;
  bool fullyFetched = false;

  bool _isComposing = false;

  ChatScreenState({required this.chatId});

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textFieldFocus.requestFocus();
    });
    getKeyOfChat(chatId).then((value) => _saveChatKeyAndGetAllMessages(value!));
    getSessionKey(chatId).then((value) => createWebsocketConnection(value));
    itemPositionsListener.itemPositions.addListener(_scrollingListener);
  }

  @override
  void dispose() {
    for (ChatMessage message in _messages) {
      message.animationController.dispose();
    }
    super.dispose();
  }

  void _scrollingListener() {
    if (fullyFetched) return;

    var currentVisibleItems = itemPositionsListener.itemPositions.value;
    if (currentVisibleItems.isNotEmpty &&
        currentVisibleItems.last.index == _messages.length - 1) {
      log("reached latest value of scrolling. Fetching new data...");
      getAndDisplayMessagesFromBackend(_messages.last.id);
    }
  }

  void createWebsocketConnection(String sessionKey) async {
    String url = '${ApiConfig.websocketBaseUrl}/sub';
    log("trying to get a connection to the websocket $url ...");
    var session = WebSocketService();
    await session.connect(url, sessionKey);
    session.messages.listen((jsonMessage) {
      log("incomming message from Websocket: $jsonMessage");
      var jsonObject = json.decode(jsonMessage);
      bool isDeleteMessage = jsonObject['deleteMessage'];

      if (isDeleteMessage) {
        handleIncommingDeleteMessageFromWebsocket(jsonObject);
      } else {
        handleIncommingMessageFromWebsocket(jsonObject);
      }
    });
  }

  void handleIncommingMessageFromWebsocket(jsonObject) {
    var parsedMessage = Message.fromJson(jsonObject, chatId);

    AnimationController animationControllerForIncommingMessages =
        AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    var chatMessage = _parseMessageToChatMessage(
        parsedMessage, animationControllerForIncommingMessages);

    setState(() {
      _messages.insert(0, chatMessage);
    });

    animationControllerForIncommingMessages.forward();
  }

  void handleIncommingDeleteMessageFromWebsocket(jsonObject) {
    int id = jsonObject['id'];
    setState(() {
      _messages.removeWhere((element) => element.id == id);
    });
  }

  ChatMessage _parseMessageToChatMessage(
      Message message, AnimationController animationController) {
    return ChatMessage(
      id: message.id,
      fromUserName: message.fromUserName,
      timestamp: message.timestamp,
      text: aesDecrypt(message.value, chatKey),
      animationController: animationController,
      deleteMessage: _deleteMessage,
    );
  }

  Future<void> _deleteMessage(ChatMessage message) async {
    setState(() {
      _messages.remove(message);
    });
    deleteMessage(chatId, message.id);
  }

  void _saveChatKeyAndGetAllMessages(String chatKey) async {
    //TODO Key is still RSA encrypted at this point. So we first gotta decrypt the key! However i assume Tim and Valerie gonna do this in their branch. So i first wait...

    //this.chatKey = chatKey;
    this.chatKey = chatKey;
    await getAndDisplayMessagesFromBackend(-1);
  }

  Future<void> getAndDisplayMessagesFromBackend(int latestMessageId) async {
    AnimationController animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    var temp = await readAllMessages(
        chatId, REQUEST_SIZE_OF_MESSAGES, latestMessageId);
    log("fetched ${temp.length} messages from backend");
    if (temp.length < REQUEST_SIZE_OF_MESSAGES) {
      log("Fully fetched chat. No need to fetch any old messages anymore");
      fullyFetched = true;
    }
    Iterable<ChatMessage> chatMessages = [];
    setState(() {
      chatMessages = temp.map((e) => _parseMessageToChatMessage(e, animation));
      _messages.addAll(chatMessages);
    });

    animation.forward();
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
              decoration:
                  const InputDecoration.collapsed(hintText: 'Send a message'),
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
            child: ScrollablePositionedList.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _messages[index],
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionsListener,
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
  final int id;
  final String fromUserName;
  final String text;
  final DateTime timestamp;
  final AnimationController animationController;
  final Function deleteMessage;

  const ChatMessage(
      {Key? key,
      required this.id,
      required this.fromUserName,
      required this.timestamp,
      required this.text,
      required this.animationController,
      required this.deleteMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isCurrentUser = fromUserName == WhoAmIStore().username!;

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
              margin: const EdgeInsets.only(left: 8.0, right: 16.0),
              child: CircleAvatar(
                backgroundColor: _getColorFromUserName(fromUserName),
                foregroundColor: Colors.white,
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
                      const SizedBox(width: 10),
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
            if (isCurrentUser)
              IconButton(
                icon: const Icon(Icons.delete, size: 20.0),
                onPressed: () async {
                   deleteMessage(this);
                },
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

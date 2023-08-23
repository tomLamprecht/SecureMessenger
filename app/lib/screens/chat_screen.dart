import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_flutter_test/models/message.dart';
import 'package:my_flutter_test/screens/chat_details_screen.dart';
import 'package:my_flutter_test/services/api/api_config.dart';
import 'package:my_flutter_test/services/websocket/websocket_service.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../models/webserver_message_type.dart';
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
  int REQUEST_SIZE_OF_MESSAGES = 20;

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
      // message.animationController.dispose();
    }
    super.dispose();
  }

  void _scrollingListener() {
    if (fullyFetched) return;

    var currentVisibleItems = itemPositionsListener.itemPositions.value;
    if (currentVisibleItems.isNotEmpty &&
        currentVisibleItems.last.index == _messages.length - 1) {
      getAndDisplayMessagesFromBackend(_messages.last.id);
    }
  }

  void createWebsocketConnection(String sessionKey) async {
    String url = '${ApiConfig.websocketBaseUrl}/sub';
    var session = WebSocketService();
    await session.connect(url, sessionKey);
    session.messages.listen((jsonMessage) {
      var jsonObject = json.decode(jsonMessage);
      WebsocketMessageType messageType =
          WebsocketMessageTypeExtension.fromString(jsonObject['messageType']);
      if (messageType == WebsocketMessageType.DELETE) {
        handleIncommingDeleteMessageFromWebsocket(jsonObject);
      } else if (messageType == WebsocketMessageType.CREATE) {
        handleIncommingMessageFromWebsocket(jsonObject);
      } else if (messageType == WebsocketMessageType.UPDATE) {
        handleIncommingUpdateMessageFromWebsocket(jsonObject);
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

  void handleIncommingUpdateMessageFromWebsocket(jsonObject) {
    var parsedMessage = Message.fromJson(jsonObject, chatId);
    int index =
        _messages.indexWhere((element) => element.id == parsedMessage.id);
    var oldMessage = _messages[index];
    var newMessage = ChatMessage(
      id: oldMessage.id,
      fromUserName: oldMessage.fromUserName,
      timestamp: oldMessage.timestamp,
      text: aesDecrypt(parsedMessage.value, chatKey),
      animationController: oldMessage.animationController,
      deleteMessage: _deleteMessage,
      updateMessage: _updateMessage,
      lastTimeUpdated: parsedMessage.lastTimeUpdated,
    );
    setState(() {
      _messages[index] = newMessage;
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
      updateMessage: _updateMessage,
      lastTimeUpdated: null,
    );
  }

  Future<void> _deleteMessage(ChatMessage message) async {
    setState(() {
      _messages.remove(message);
    });
    await deleteMessage(chatId, message.id);
  }

  Future<void> _updateMessage(ChatMessage message, String newContent) async {
    int index = _messages.indexWhere((element) => element.id == message.id);
    var encryptedMessage = aesEncrypt(newContent, chatKey);
    var newMessage = ChatMessage(
        id: message.id,
        fromUserName: message.fromUserName,
        timestamp: message.timestamp,
        text: newContent,
        animationController: message.animationController,
        deleteMessage: _deleteMessage,
        updateMessage: _updateMessage,
        lastTimeUpdated: DateTime.now());
    setState(() {
      _messages[index] = newMessage;
    });
    await updateMessage(message.id, chatId, encryptedMessage);
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
    if (temp.length < REQUEST_SIZE_OF_MESSAGES) {
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
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChatDetailsScreen(chatId: chatId),
            ));
          },
          child: Text(widget.chatTitle),
        ),
        backgroundColor: Colors.blue,
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

class ChatMessage extends StatefulWidget {
  final int id;
  final String fromUserName;
  final String text;
  final DateTime timestamp;
  final DateTime? lastTimeUpdated;
  final AnimationController animationController;
  final Function deleteMessage;
  final Function updateMessage;

  const ChatMessage(
      {Key? key,
      required this.id,
      required this.fromUserName,
      required this.timestamp,
      required this.text,
      required this.animationController,
      required this.deleteMessage,
      required this.updateMessage,
      required this.lastTimeUpdated})
      : super(key: key);

  @override
  _ChatMessageState createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  bool isEditing = false;
  late TextEditingController editingController;

  @override
  void initState() {
    super.initState();
    editingController = TextEditingController(text: widget.text);
  }

  Color _getColorFromUserName(String userName) {
    final int hash = userName.hashCode.abs();
    final double hue = (hash % 360).toDouble();
    return HSVColor.fromAHSV(1.0, hue, 0.7, 0.9).toColor();
  }

  @override
  Widget build(BuildContext context) {
    bool isCurrentUser = widget.fromUserName == WhoAmIStore().username!;

    return SizeTransition(
      sizeFactor:
      CurvedAnimation(
          parent: widget.animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 8.0, right: 16.0),
              child: CircleAvatar(
                backgroundColor: _getColorFromUserName(widget.fromUserName),
                foregroundColor: Colors.white,
                child: Text(widget.fromUserName[0].toUpperCase()),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(widget.fromUserName,
                          style: Theme
                              .of(context)
                              .textTheme
                              .titleMedium),
                      const SizedBox(width: 10),
                      Text(
                        widget.lastTimeUpdated == null ? widget.timestamp.toString() : widget.lastTimeUpdated.toString() + " (edited)",
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodySmall,
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: isEditing ?
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: editingController,
                            autofocus: true,
                            onSubmitted: (value) async {
                              setState(() {
                                isEditing = false;
                              });
                              await widget.updateMessage(widget, editingController.text);
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isEditing = false;
                              editingController.text = widget.text;
                            });
                          },
                          icon: const Icon(Icons.close, color: Colors.red),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              isEditing = false;
                            });
                            await widget.updateMessage(widget, editingController.text);
                          },
                          icon: const Icon(Icons.check, color: Colors.green),
                        ),
                      ],
                    )
                        : Text(widget.text),
                  ),
                ],
              ),
            ),
            if (isCurrentUser && !isEditing)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20.0),
                onSelected: (value) async {
                  switch (value.toLowerCase()) {
                    case 'delete':
                      await widget.deleteMessage(widget);
                      break;
                    case 'edit':
                      setState(() {
                        isEditing = true;
                      });
                      break;
                  }
                },
                itemBuilder: (BuildContext context) =>
                [
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
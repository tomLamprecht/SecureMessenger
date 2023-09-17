import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_flutter_test/models/AttachedFile.dart';
import 'package:my_flutter_test/models/message.dart';
import 'package:my_flutter_test/screens/chat_details_screen.dart';
import 'package:my_flutter_test/services/api/api_config.dart';
import 'package:my_flutter_test/services/files/ecc_helper.dart';
import 'package:my_flutter_test/services/stores/account_information_store.dart';
import 'package:my_flutter_test/services/websocket/websocket_service.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:file_picker/file_picker.dart';
import '../models/chatkey.dart';
import '../models/webserver_message_type.dart';
import '../services/chats_service.dart';
import '../services/encryption_service.dart';
import '../services/files/download_service/download_service.dart';
import '../services/message_service.dart';
import '../services/stores/who_am_i_store.dart';
import 'package:my_flutter_test/models/chat.dart';

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
  List<ChatMessage> _messages = [];
  final FocusNode _textFieldFocus = FocusNode();
  final int chatId;

  late final String chatKey;
  List<PlatformFile> _chosenFiles = [];
  bool fullyFetched = false;
  String? encodedGroupPicture;

  bool _isComposing = false;
  int? expirationTimerSecs;

  WebSocketService? websocketSession;

  ChatScreenState({required this.chatId});

  bool loadedAllImages = false;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textFieldFocus.requestFocus();
    });
    itemPositionsListener.itemPositions.addListener(_scrollingListener);
    getKeyOfChat(chatId).then((value) => _saveChatKeyAndGetAllMessages(value!));
    getSessionKey(chatId).then((value) => createWebsocketConnection(value));
    _requestAllPicturesInitially().then((value) => setState(() {
          loadedAllImages = true;
        }));

  }

  Future<void> _requestAllPicturesInitially() async {
    Set<String> uniqueUsernames = {};
    for (var message in _messages) {
      uniqueUsernames.add(message.fromUserName);
    }
    List<Future> futures = [];
    for (var username in uniqueUsernames) {
      futures.add(AccountInformationStore().getProfilePicByUsername(username));
    }

    await Future.wait(futures);
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
        currentVisibleItems.last.index == 0) {
      print(
          "Lazy loading messages with lastLoadedMsgId: ${_messages.first.id}");
      getAndDisplayMessagesFromBackend(_messages.first.id);
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        _chosenFiles = result.files;
      });
    } else {
      // User canceled the picker
    }
  }

  void _deleteSelectedFile(PlatformFile fileToDelete) {
    setState(() {
      _chosenFiles.remove(fileToDelete);
    });
  }

  Future<void> _captureImage() async {
    // todo
  }

  void createWebsocketConnection(String sessionKey) async {
    String url = '${ApiConfig.websocketBaseUrl}/sub';
    websocketSession = WebSocketService();
    await websocketSession!.connect(url, sessionKey);
    websocketSession!.messages.listen((jsonMessage) {
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
      duration: const Duration(milliseconds: 0),
    );

    var chatMessage = _parseMessageToChatMessage(
        parsedMessage, animationControllerForIncommingMessages);

    setState(() {
      _messages.add(chatMessage);
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
        files: oldMessage.files,
        animationController: oldMessage.animationController,
        deleteMessage: _deleteMessage,
        updateMessage: _updateMessage,
        lastTimeUpdated: parsedMessage.lastTimeUpdated,
        symKey: chatKey);
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
        files: message.attachedFiles,
        animationController: animationController,
        deleteMessage: _deleteMessage,
        updateMessage: _updateMessage,
        lastTimeUpdated: null,
        symKey: chatKey);
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
        files: message.files,
        animationController: message.animationController,
        deleteMessage: _deleteMessage,
        updateMessage: _updateMessage,
        lastTimeUpdated: DateTime.now(),
        symKey: chatKey);
    setState(() {
      _messages[index] = newMessage;
    });
    await updateMessage(message.id, chatId, encryptedMessage);
  }

  void _saveChatKeyAndGetAllMessages(Chatkey chatKey) async {
    this.chatKey = ECCHelper().decryptByAESAndECDHUsingString(
        chatKey.encryptedByPublicKey, chatKey.value);
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
      chatMessages =
          temp.map((e) => _parseMessageToChatMessage(e, animation)).toList();
      _messages.insertAll(0, chatMessages);
    });

    animation.forward();
  }

  void _handleSubmitted(String text) {
    _chosenFiles.removeWhere((element) => element.bytes == null);
    var attachedFiles = _chosenFiles
        .map((e) => AttachedFile(
            fileName: e.name,
            encodedFileContent: aesEncrypt(base64Encode(e.bytes!), chatKey)))
        .toList();
    sendMessage(
        chatId, aesEncrypt(text, chatKey), attachedFiles, expirationTimerSecs);

    _textController.clear();
    setState(() {
      _isComposing = false;
      _chosenFiles = [];
    });

    _textFieldFocus.requestFocus();
  }

  void timerButtonClicked(BuildContext context) async {
    // if enabled -> disable
    if (expirationTimerSecs != null) {
      setState(() {
        expirationTimerSecs = null;
      });
    } else {
      final selectedDuration = await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          int? selectedValue;
          return AlertDialog(
            title: const Text('Self Destruction'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    selectedValue = int.tryParse(value) ?? 0;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Seconds until Self Destruction of messages',
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
              ),
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(selectedValue);
                },
              ),
            ],
          );
        },
      );
      if (selectedDuration != null && selectedDuration > 0) {
        setState(() {
          expirationTimerSecs = selectedDuration;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid duration'),
          ),
        );
      }
    }
  }

  Widget _buildTextComposer() {
    // Check if there's at least one non-image file in the chosen files
    bool containsNonImageFile = _chosenFiles.any(
      (file) => !['jpg', 'jpeg', 'png', 'gif']
          .contains(file.extension!.toLowerCase()),
    );

    return Column(
      children: <Widget>[
        ..._chosenFiles.map(
          (file) => FileView(
            file: AttachedFile(
                fileName: file.name,
                encodedFileContent: base64Encode(file.bytes!),
                createdAt: DateTime.now()),
            forceFileView: containsNonImageFile,
            icon: const Icon(Icons.delete),
            symKey: chatKey,
            onClick: () => _deleteSelectedFile(file),
          ),
        ),
        Row(
          children: <Widget>[
            IconButton(icon: const Icon(Icons.add), onPressed: _pickFile),
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
                icon: expirationTimerSecs != null
                    ? const Icon(Icons.timer)
                    : const Icon(Icons.timer_off),
                onPressed: () => timerButtonClicked(context),
                color: expirationTimerSecs != null
                    ? Colors.red
                    : Theme.of(context).disabledColor,
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
      ],
    );
  }

  Future<String?> _getImageFromDatabase() async {
    if (encodedGroupPicture != null) {
      return encodedGroupPicture;
    }
    var chatToAcc = await ChatsService().getChatToUser(widget.chatId);
    String? encodedPic = chatToAcc?.chat.encodedGroupPic;
    if (chatToAcc != null && encodedPic != null) {
      encodedGroupPicture = encodedPic;
      return encodedPic;
    }

    encodedGroupPicture = "";
    return encodedGroupPicture;
  }

  @override
  Widget build(BuildContext context) {
    print(_messages.map((e) => e.text).toList());
    if (!loadedAllImages) {
      return const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2,
          ));
    }
    return WillPopScope(
      onWillPop: () async {
        if (websocketSession != null) {
          websocketSession!.close();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatDetailsScreen(chatId: chatId),
              ));
            },
            child: Row(
              children: [
                FutureBuilder<String?>(
                  future: _getImageFromDatabase(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data != "") {
                      final encodedPic = snapshot.data!;
                      final imageData =
                          Uint8List.fromList(base64Decode(encodedPic));
                      return CircleAvatar(
                        radius: 20,
                        backgroundImage: MemoryImage(imageData),
                      );
                    } else {
                      return const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.supervised_user_circle,
                          size: 30,
                          color: Colors.white,
                        ),
                      );
                    }
                  },
                ),
                SizedBox(width: 8),
                // placeholder between avatar and chat title
                Text(widget.chatTitle),
              ],
            ),
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
                itemBuilder: (_, int index) => _messages.reversed.toList()[index],
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
      ),
    );
  }
}

class ChatMessage extends StatefulWidget {
  final int id;
  final String fromUserName;
  final String text;
  final List<AttachedFile>? files;
  final DateTime timestamp;
  final DateTime? lastTimeUpdated;
  final AnimationController animationController;
  final Function deleteMessage;
  final Function updateMessage;
  final String symKey;

  const ChatMessage(
      {Key? key,
      required this.id,
      required this.fromUserName,
      required this.timestamp,
      required this.text,
      required this.files,
      required this.animationController,
      required this.deleteMessage,
      required this.updateMessage,
      required this.lastTimeUpdated,
      required this.symKey})
      : super(key: key);

  @override
  _ChatMessageState createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  bool isEditing = false;
  List<FileView> attachedFilesView = [];
  late TextEditingController editingController;
  MemoryImage? encodedPic;

  @override
  void initState() {
    super.initState();
    editingController = TextEditingController(text: widget.text);

    _getImageFromDatabase(widget.fromUserName);
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
        sizeFactor: CurvedAnimation(
            parent: widget.animationController, curve: Curves.easeOut),
        axisAlignment: 0.0,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildUserAvatar(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildMessageHeader(),
                    if (widget.files != null) ..._buildAttachedFiles(),
                    _buildMessageContent(),
                  ],
                ),
              ),
              if (isCurrentUser && !isEditing) _buildMessageActions(),
            ],
          ),
        ));
  }

  _getImageFromDatabase(String username) async {
    await AccountInformationStore()
        .getProfilePicByUsername(username)
        .then((value) => setState(() {
              encodedPic = value;
            }));
  }

  Widget _buildUserAvatar() {
    if (encodedPic != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        child: CircleAvatar(
          radius: 20,
          backgroundImage: encodedPic,
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        child: CircleAvatar(
          backgroundColor: _getColorFromUserName(widget.fromUserName),
          foregroundColor: Colors.white,
          child: Text(widget.fromUserName[0].toUpperCase()),
        ),
      );
    }
  }

  Widget _buildMessageHeader() {
    return Row(
      children: <Widget>[
        Text(
          widget.fromUserName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(width: 10),
        Text(
          widget.lastTimeUpdated == null
              ? widget.timestamp.toString()
              : '${widget.lastTimeUpdated} (edited)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  List<Widget> _buildAttachedFiles() {
    return attachedFilesView = widget.files!
        .map((file) => FileView(
              file: file,
              forceFileView: widget.files!.any((element) => ![
                    'jpg',
                    'jpeg',
                    'png',
                    'gif'
                  ].contains(element.fileName.split('.').last.toLowerCase())),
              icon: const Icon(Icons.download),
              symKey: widget.symKey,
              onClick: () {
                var encryptedFileContent =
                    aesDecrypt(file.encodedFileContent, widget.symKey);
                DownloadService.instance.downloadFile(
                    encodedContent: encryptedFileContent,
                    filename: file.fileName);
              },
            ))
        .toList();
  }

  Widget _buildMessageContent() {
    return Container(
      margin: const EdgeInsets.only(top: 5.0),
      child: isEditing ? _buildEditingField() : Text(widget.text),
    );
  }

  Widget _buildEditingField() {
    return Row(
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
    );
  }

  Widget _buildMessageActions() {
    return PopupMenuButton<String>(
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
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'edit',
          child: Text('Edit'),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text('Delete'),
        ),
      ],
    );
  }
}

class FileView extends StatefulWidget {
  final AttachedFile file;
  final bool forceFileView;
  final VoidCallback onClick;
  final Icon icon;
  final String symKey;

  const FileView({
    Key? key,
    required this.file,
    required this.forceFileView,
    required this.onClick,
    required this.icon,
    required this.symKey,
  }) : super(key: key);

  @override
  _FileViewState createState() => _FileViewState();
}

class _FileViewState extends State<FileView> {
  bool _showImage = false;
  late Uint8List _decryptedImage;
  bool _loadImage = false;

  @override
  Widget build(BuildContext context) {
    String fileExtension = _getFileExtension(widget.file.fileName);
    return Row(
      children: <Widget>[
        if (widget.forceFileView ||
            !['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension))
          _showFileWidget()
        else
          _showImageWidget(),
        IconButton(
          icon: widget.icon,
          onPressed: widget.onClick,
        ),
      ],
    );
  }

  Uint8List decryptImage() {
    return base64Decode(
        aesDecrypt(widget.file.encodedFileContent, widget.symKey));
  }

  Widget _showFileWidget() {
    return Row(
      children: <Widget>[
        const Icon(Icons.insert_drive_file),
        Text(widget.file.fileName),
      ],
    );
  }

  Widget _showImageWidget() {
    if (_loadImage) {
      return const Text("Decrypting image...");
    }

    if (_showImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 200.0,
            maxHeight: 200.0,
          ),
          child: Image.memory(
            _decryptedImage,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: () async {
        setState(() {
          _loadImage = true;
        });

        setState(() {
          _decryptedImage = decryptImage();
          _showImage = true;
          _loadImage = false;
        });
      },
      child: const Text('Show Image'),
    );
  }

  String _getFileExtension(String fileName) {
    List<String> parts = fileName.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return '';
  }
}

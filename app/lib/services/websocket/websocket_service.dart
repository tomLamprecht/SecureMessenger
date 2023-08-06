import 'dart:async';

import 'package:web_socket_channel/html.dart';

class WebSocketService {
  late HtmlWebSocketChannel _webSocketChannel;
  final _streamController = StreamController<String>();

  Stream<String> get messages => _streamController.stream;

  Future<void> connect(String url, String sessionKey) async {
    _webSocketChannel = HtmlWebSocketChannel.connect(url);

    _webSocketChannel.sink.add(sessionKey);

    _webSocketChannel.stream.listen((event) {
      _streamController.add(event as String);
    }, onError: (error) {
      _streamController.addError(error);
    }, onDone: () {
      _streamController.close();
    });
  }

  void send(String message) {
    _webSocketChannel.sink.add(message);
  }

  void close() {
    _webSocketChannel.sink.close();
  }
}
import 'dart:typed_data';

class ChatDecryptedImageStore {
  static final ChatDecryptedImageStore _instance = ChatDecryptedImageStore._();

  factory ChatDecryptedImageStore() => _instance;

  Map<int, Uint8List?> _cachedPictures = {};

  ChatDecryptedImageStore._();

  Uint8List? getDecryptedChatImageById(int messageId) {
    if (_cachedPictures.containsKey(messageId)) {
      return _cachedPictures[messageId];
    }
  }

  void loadDecryptedChatImageForId(int messageId, Uint8List decryptedImage){
    _cachedPictures[messageId] = decryptedImage;
  }

  void invalidateCache() {
    _cachedPictures = {};
  }
}
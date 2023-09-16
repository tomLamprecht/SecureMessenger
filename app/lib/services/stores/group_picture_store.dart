
import 'package:my_flutter_test/services/chats_service.dart';

class GroupPictureStore {
  static final GroupPictureStore _instance = GroupPictureStore._();

  factory GroupPictureStore() => _instance;

  Map<int, String?> cachedPictures = {};

  GroupPictureStore._();

  Future<String?> getGroupChatPictureById(int groupChatId) async {
    if (cachedPictures.containsKey(groupChatId)) {
      return cachedPictures[groupChatId]!;
    } else {
      var chatToAcc = await ChatsService().getChatToUser(groupChatId);
      String? encodedPic = chatToAcc?.chat.encodedGroupPic;
      cachedPictures.putIfAbsent(groupChatId, () => encodedPic);
      return encodedPic;
    }
  }

  void updatePictureForGroupChat(int groupChatId, String picture) {
    cachedPictures[groupChatId] = picture;
  }

  void invalidateCache() {
    cachedPictures = {};
  }
}
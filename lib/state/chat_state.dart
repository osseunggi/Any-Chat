import 'package:anychat/model/chat.dart';
import 'package:anychat/service/database_service.dart';
import 'package:anychat/service/translate_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatRoomInfoNotifier extends StateNotifier<List<ChatRoomInfo>> {
  ChatRoomInfoNotifier(super.state);

  List<ChatRoomInfo> save = [];

  void set(List<ChatRoomInfo> chatRoomInfo) {
    state = chatRoomInfo..sort((a, b) => b.lastMessageUpdatedAt.compareTo(a.lastMessageUpdatedAt));
    save = chatRoomInfo..sort((a, b) => b.lastMessageUpdatedAt.compareTo(a.lastMessageUpdatedAt));
  }

  void allRead(String chatRoomId) {
    DatabaseService.update('ChatRoomInfo', {'unreadCount': 0}, 'id = ?', [chatRoomId]);

    final tmp = state.map((e) => e.id == chatRoomId ? e.copyWith(unreadCount: 0) : e).toList();
    state = tmp;
    save = tmp;
  }

  void update(ChatRoomInfo chatRoomInfo) {
    state = [...state.where((e) => e != chatRoomInfo), chatRoomInfo]
      ..sort((a, b) => b.lastMessageUpdatedAt.compareTo(a.lastMessageUpdatedAt));
    save = [...save.where((e) => e != chatRoomInfo), chatRoomInfo]
      ..sort((a, b) => b.lastMessageUpdatedAt.compareTo(a.lastMessageUpdatedAt));
  }

  void remove(String chatRoomId) {
    state = state.where((e) => e.id != chatRoomId).toList();
    save = save.where((e) => e.id != chatRoomId).toList();
  }

  void sortByUpdatedAt() {
    state = [...state]..sort((a, b) => b.lastMessageUpdatedAt.compareTo(a.lastMessageUpdatedAt));
    save = [...save]..sort((a, b) => b.lastMessageUpdatedAt.compareTo(a.lastMessageUpdatedAt));
  }

  void sortByUnreadCount() {
    state = [...state]..sort((a, b) {
        if (a.unreadCount == 0 && b.unreadCount == 0) {
          return b.lastMessageUpdatedAt.compareTo(a.lastMessageUpdatedAt);
        } else if (a.unreadCount == 0) {
          return 1;
        } else if (b.unreadCount == 0) {
          return -1;
        } else {
          return b.lastMessageUpdatedAt.compareTo(a.lastMessageUpdatedAt);
        }
      });

    save = [...save]..sort((a, b) {
        if (a.unreadCount == 0 && b.unreadCount == 0) {
          return b.lastMessageUpdatedAt.compareTo(a.lastMessageUpdatedAt);
        } else if (a.unreadCount == 0) {
          return 1;
        } else if (b.unreadCount == 0) {
          return -1;
        } else {
          return b.lastMessageUpdatedAt.compareTo(a.lastMessageUpdatedAt);
        }
      });
  }

  void search(String keyword) {
    state = save.where((e) => e.name.contains(keyword)).toList();
  }

  Future<void> updateLanguage() async {
    final List<ChatRoomInfo> chatRoomInfos = [];

    for (final chatRoomInfo in save) {
      if (chatRoomInfo.language != null && chatRoomInfo.lastMessage != '') {
        await translateService
            .translateLastMessage(chatRoomInfo.lastMessage, chatRoomInfo.language!)
            .then((value) {
          chatRoomInfos.add(chatRoomInfo.copyWith(targetLastMessage: value));
        });
      } else {
        chatRoomInfos.add(chatRoomInfo);
      }
    }

    save = chatRoomInfos..sort((a, b) => b.lastMessageUpdatedAt.compareTo(a.lastMessageUpdatedAt));
    state = chatRoomInfos..sort((a, b) => b.lastMessageUpdatedAt.compareTo(a.lastMessageUpdatedAt));
  }
}

final chatRoomInfoProvider = StateNotifierProvider<ChatRoomInfoNotifier, List<ChatRoomInfo>>((ref) {
  return ChatRoomInfoNotifier([]);
});

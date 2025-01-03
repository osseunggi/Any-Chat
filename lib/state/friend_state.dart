import 'package:anychat/model/friend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendsNotifier extends StateNotifier<List<Friend>> {
  FriendsNotifier(super.state);

  void setFriends(List<Friend> friends) {
    state = friends.sortByName();
  }

  void addFriends(List<Friend> friends) {
    final List<Friend> updateFriends = [];
    final List<Friend> newFriends = [];
    for (final friend in friends) {
      if (!state.any((e) => e == friend)) {
        newFriends.add(friend);
      } else {
        updateFriends.add(friend);
      }
    }
    state = [
      ...state.where((e) => !updateFriends.any((f) => f == e)),
      ...updateFriends,
      ...newFriends
    ].sortByName();
  }

  void addFriend(Friend friend) {
    state = [...state, friend].sortByName();
  }

  void removeFriend(int id) {
    state = state.where((e) => e.id != id).toList();
  }

  void pinned(int id) {
    state = state.map((e) {
      if (e.id == id) {
        return e.copyWith(isPinned: true);
      }
      return e;
    }).toList();
  }

  void unpinned(int id) {
    state = state.map((e) {
      if (e.id == id) {
        return e.copyWith(isPinned: false);
      }
      return e;
    }).toList();
  }

  void update(Friend friend) {
    state = state.map((e) {
      if (e.id == friend.id) {
        return friend;
      }
      return e;
    }).toList();
  }
}

class PinnedFriendsNotifier extends StateNotifier<List<Friend>> {
  PinnedFriendsNotifier(super.state);

  void setPinned(List<Friend> friends) {
    state = friends;
  }

  void pinned(WidgetRef ref, int id) {
    final Friend friend = ref.read(friendsProvider).firstWhere((e) => e.id == id);

    state = [...state, friend].sortByName();
  }

  void unpinned(int id) {
    state = state.where((e) => e.id != id).toList();
  }
}

class HiddenFriendsNotifier extends StateNotifier<List<Friend>> {
  HiddenFriendsNotifier(super.state);

  void setHidden(List<Friend> friends) {
    final List<Friend> updateFriends = [];
    final List<Friend> newFriends = [];
    for (final friend in friends) {
      if (!state.any((e) => e == friend)) {
        newFriends.add(friend);
      } else {
        updateFriends.add(friend);
      }
    }
    state = [
      ...state.where((e) => !updateFriends.any((f) => f == e)),
      ...updateFriends,
      ...newFriends
    ].sortByName();
  }

  void hide(WidgetRef ref, int id) {
    final Friend friend = ref.read(friendsProvider).firstWhere((e) => e.id == id);
    ref.read(friendsProvider.notifier).removeFriend(id);
    ref.read(pinnedFriendsProvider.notifier).unpinned(id);
    state = [...state, friend].sortByName();
  }

  void unHide(WidgetRef ref, int id) {
    ref.read(friendsProvider.notifier).addFriend(state.firstWhere((e) => e.id == id));
    state = state.where((e) => e.id != id).toList();
  }

  void block(int id) {
    state = state.where((e) => e.id != id).toList();
  }
}

class BlockFriendsNotifier extends StateNotifier<List<Friend>> {
  BlockFriendsNotifier(super.state);

  void setBlocked(List<Friend> friends) {
    final List<Friend> updateFriends = [];
    final List<Friend> newFriends = [];
    for (final friend in friends) {
      if (!state.any((e) => e == friend)) {
        newFriends.add(friend);
      } else {
        updateFriends.add(friend);
      }
    }
    state = [
      ...state.where((e) => !updateFriends.any((f) => f == e)),
      ...updateFriends,
      ...newFriends
    ].sortByName();
  }

  void block(WidgetRef ref, int id) {
    final Friend? hiddenFriend =
        ref.read(hiddenFriendsProvider).where((e) => e.id == id).firstOrNull;
    final Friend friend = hiddenFriend ?? ref.read(friendsProvider).firstWhere((e) => e.id == id);

    if (hiddenFriend != null) {
      ref.read(hiddenFriendsProvider.notifier).block(id);
    } else {
      ref.read(friendsProvider.notifier).removeFriend(id);
    }
    state = [...state, friend].sortByName();
  }

  void unBlock(WidgetRef ref, int id) {
    ref.read(friendsProvider.notifier).addFriend(state.firstWhere((e) => e.id == id));
    state = state.where((e) => e.id != id).toList();
  }
}

final friendsProvider = StateNotifierProvider<FriendsNotifier, List<Friend>>((ref) {
  return FriendsNotifier([]);
});

final pinnedFriendsProvider = StateNotifierProvider<PinnedFriendsNotifier, List<Friend>>((ref) {
  return PinnedFriendsNotifier([]);
});

final hiddenFriendsProvider = StateNotifierProvider<HiddenFriendsNotifier, List<Friend>>((ref) {
  return HiddenFriendsNotifier([]);
});

final blockFriendsProvider = StateNotifierProvider<BlockFriendsNotifier, List<Friend>>((ref) {
  return BlockFriendsNotifier([]);
});

final friendCountProvider = StateProvider<int>((ref) => 0);

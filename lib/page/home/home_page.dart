import 'package:anychat/model/friend.dart';
import 'package:anychat/page/home/show_setting_menu.dart';
import 'package:anychat/page/router.dart';
import 'package:anychat/service/friend_service.dart';
import 'package:anychat/state/friend_state.dart';
import 'package:anychat/state/user_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../main_layout.dart';
import '../user/profile_page.dart';
import 'add_freind.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldFavorites = useState<bool>(false);
    final foldFriends = useState<bool>(false);

    return Column(
      children: [
        Container(
            height: 50,
            alignment: Alignment.center,
            child: Row(
              children: [
                SizedBox(width: 20.w),
                Text('friend'.tr(),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3B3B3B))),
                const Spacer(),
                GestureDetector(
                    onTap: () {
                      addFriendPopup(context, ref);
                    },
                    child: SvgPicture.asset('assets/images/friend_add.svg', width: 24)),
                SizedBox(width: 7.w),
                GestureDetector(
                    onTap: () {
                      showSettingMenu(context);
                    },
                    child: SvgPicture.asset('assets/images/settings.svg', width: 24)),
                SizedBox(width: 20.w),
              ],
            )),
        Expanded(
            child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification &&
                      notification.metrics.extentAfter == 0) {
                    FriendService().getFriends(ref).then((value) {
                      friendsCursor = value;
                    });
                  }

                  return false;
                },
                child: SingleChildScrollView(
                    child: Column(children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFFE0E2E4), width: 1))),
                    child: Text('profile'.tr(),
                        style: TextStyle(
                            fontSize: 12.r,
                            color: const Color(0xFF7C4DFF),
                            fontWeight: FontWeight.w500)),
                  ),
                  SizedBox(height: 8.h),
                  _profileWidget(ref),
                  SizedBox(height: 8.h),
                  InkWell(
                      onTap: () {
                        foldFavorites.value = !foldFavorites.value;
                      },
                      child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                          decoration: const BoxDecoration(
                              border:
                                  Border(bottom: BorderSide(color: Color(0xFFE0E2E4), width: 1))),
                          child: Row(
                            children: [
                              Text('like'.tr(),
                                  style: TextStyle(
                                      fontSize: 12.r,
                                      color: const Color(0xFF7C4DFF),
                                      fontWeight: FontWeight.w500)),
                              const Spacer(),
                              Icon(
                                  foldFavorites.value
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  size: 12.r,
                                  color: const Color(0xFF3B3B3B))
                            ],
                          ))),
                  if (!foldFavorites.value && ref.watch(pinnedFriendsProvider).isNotEmpty)
                    Column(children: [
                      SizedBox(height: 8.h),
                      ...ref
                          .watch(pinnedFriendsProvider)
                          .map((friend) => _profileWidget(ref, friend: friend)),
                      SizedBox(height: 8.h)
                    ]),
                  InkWell(
                      onTap: () {
                        foldFriends.value = !foldFriends.value;
                      },
                      child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                          decoration: const BoxDecoration(
                              border:
                                  Border(bottom: BorderSide(color: Color(0xFFE0E2E4), width: 1))),
                          child: Row(
                            children: [
                              Text(
                                  'friend_count'.tr(namedArgs: {
                                    'friend_count': ref.watch(friendCountProvider).toString()
                                  }),
                                  style: TextStyle(
                                      fontSize: 12.r,
                                      color: const Color(0xFF7C4DFF),
                                      fontWeight: FontWeight.w500)),
                              const Spacer(),
                              Icon(
                                  foldFriends.value
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  size: 12.r,
                                  color: const Color(0xFF3B3B3B))
                            ],
                          ))),
                  if (!foldFriends.value && ref.watch(friendsProvider).isNotEmpty)
                    Column(children: [
                      SizedBox(height: 8.h),
                      ...ref
                          .watch(friendsProvider)
                          .map((friend) => _profileWidget(ref, friend: friend))
                    ]),
                  SizedBox(height: 100.h),
                ]))))
      ],
    );
  }

  Widget _profileWidget(WidgetRef ref, {Friend? friend}) {
    return InkWell(
        onTap: () {
          if (friend != null) {
            FriendService().getFriendInfo(ref, friend.id).then((detail) {
              ref.read(friendsProvider.notifier).update(detail);
              router.push(ProfilePage.routeName, extra: detail);
            });
          } else {
            router.push(ProfilePage.routeName);
          }
        },
        child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
            child: Row(
              children: [
                ClipOval(
                    child: (friend == null
                            ? ref.watch(userProvider)?.userInfo.profileImg == null
                                ? null
                                : Image.file(ref.watch(userProvider)!.userInfo.profileImg!,
                                    width: 44.r, height: 44.r, fit: BoxFit.fill)
                            : friend.friend.profileImg == null
                                ? null
                                : Image.file(friend.friend.profileImg!,
                                    width: 44.r, height: 44.r, fit: BoxFit.fill)) ??
                        Image.asset('assets/images/default_profile.png', width: 44.r)),
                SizedBox(width: 11.w),
                Text(friend?.nickname ?? ref.watch(userProvider)?.name ?? '',
                    style: TextStyle(
                        fontSize: 16.r,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF3B3B3B)))
              ],
            )));
  }
}

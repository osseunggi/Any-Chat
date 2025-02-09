import 'package:anychat/common/toast.dart';
import 'package:anychat/model/chat.dart';
import 'package:anychat/page/router.dart';
import 'package:anychat/page/user/show_image_picker.dart';
import 'package:anychat/page/user/show_profile_more.dart';
import 'package:anychat/service/chat_service.dart';
import 'package:anychat/service/friend_service.dart';
import 'package:anychat/service/user_service.dart';
import 'package:anychat/state/friend_state.dart';
import 'package:anychat/state/user_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/friend.dart';

class ChatProfilePage extends HookConsumerWidget {
  static const String routeName = '/chat/profile';

  const ChatProfilePage({required this.chatUser, super.key});

  final ChatUserInfo chatUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditMode = useState<bool>(false);
    final user = ref.watch(userProvider)!;
    final nameClicked = useState<bool>(false);
    final messageClicked = useState<bool>(false);

    final nameFocus = useFocusNode();
    final messageFocus = useFocusNode();

    final nameController = useTextEditingController();
    final messageController = useTextEditingController();

    return GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! > 15) {
            router.pop();
          }
        },
        child: Container(
            decoration: BoxDecoration(
              image: (chatUser.id == user.id
                      ? user.userInfo.backgroundImg == null
                          ? null
                          : DecorationImage(
                              fit: BoxFit.cover, image: FileImage(user.userInfo.backgroundImg!))
                      : chatUser.backgroundImg == null
                          ? null
                          : DecorationImage(
                              fit: BoxFit.cover, image: FileImage(chatUser.backgroundImg!))) ??
                  const DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/images/default_profile_background.png')),
            ),
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.black.withOpacity(0.6),
                body: Stack(children: [
                  SafeArea(
                      child: Column(
                    children: [
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          SizedBox(width: 10.w),
                          GestureDetector(
                              onTap: () {
                                if (isEditMode.value) {
                                  isEditMode.value = false;
                                } else {
                                  router.pop();
                                }
                              },
                              child: Container(
                                  color: Colors.transparent,
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                  child: const Icon(Icons.close, color: Colors.white, size: 24))),
                          const Spacer(),
                          if (chatUser.id != user.id &&
                              ref
                                  .watch(friendsProvider)
                                  .map((e) => e.friend.userId)
                                  .contains(chatUser.id))
                            GestureDetector(
                                onTap: () {
                                  final Friend friend = ref.read(friendsProvider).firstWhere(
                                      (element) => element.friend.userId == chatUser.id);
                                  if (friend.isPinned) {
                                    FriendService().unpinFriend(ref, friend.id);
                                  } else {
                                    FriendService().pinFriend(ref, friend.id);
                                  }
                                },
                                child: Container(
                                    color: Colors.transparent,
                                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
                                    child: SvgPicture.asset(
                                      'assets/images/star.svg',
                                      width: 24,
                                      colorFilter: ref
                                              .watch(friendsProvider)
                                              .firstWhere(
                                                  (element) => element.friend.userId == chatUser.id)
                                              .isPinned
                                          ? const ColorFilter.mode(Colors.yellow, BlendMode.srcIn)
                                          : null,
                                    ))),
                          if (chatUser.id != user.id)
                            GestureDetector(
                                onTap: () {
                                  showProfileMore(context, ref, null, chatUser);
                                },
                                child: Container(
                                    color: Colors.transparent,
                                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
                                    child: SvgPicture.asset('assets/images/more.svg', width: 24))),
                          SizedBox(width: 10.w)
                        ],
                      ),
                      if (isEditMode.value)
                        Row(
                          children: [
                            SizedBox(width: 10.w),
                            GestureDetector(
                                onTap: () {
                                  showImagePicker(
                                      ref: ref,
                                      context: context,
                                      onSelected: (file) {
                                        userService.updateProfile(backgroundImage: file);
                                      });
                                },
                                child: Container(
                                    color: Colors.transparent,
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                    child: SvgPicture.asset('assets/images/camera.svg', width: 24)))
                          ],
                        ),
                      const Spacer(),
                      GestureDetector(
                          onTap: () {
                            if (isEditMode.value) {
                              showImagePicker(
                                  ref: ref,
                                  context: context,
                                  onSelected: (file) {
                                    userService.updateProfile(profileImage: file);
                                  });
                            }
                          },
                          child: Stack(
                            children: [
                              ClipOval(
                                child: (chatUser.id == user.id
                                        ? user.userInfo.profileImg == null
                                            ? null
                                            : Image.file(user.userInfo.profileImg!,
                                                width: 140, height: 140, fit: BoxFit.fill)
                                        : chatUser.profileImg == null
                                            ? null
                                            : Image.file(chatUser.profileImg!,
                                                width: 140, height: 140, fit: BoxFit.fill)) ??
                                    Image.asset('assets/images/default_profile.png',
                                        width: 140, height: 140),
                              ),
                              if (isEditMode.value)
                                Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: SvgPicture.asset('assets/images/camera.svg', width: 24))
                            ],
                          )),
                      SizedBox(height: 16.h),
                      GestureDetector(
                          onTap: () {
                            if (isEditMode.value) {
                              nameController.text = user.name;
                              nameClicked.value = true;
                              FocusScope.of(context).requestFocus(nameFocus);
                            }
                          },
                          child: Container(
                              padding: EdgeInsets.only(bottom: 6.h, top: 4.h),
                              margin: EdgeInsets.only(left: 30.w, right: 22.w),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border(
                                  bottom: BorderSide(
                                    color: isEditMode.value
                                        ? const Color(0xFFE0E2E4)
                                        : Colors.transparent,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Spacer(),
                                  SizedBox(
                                    width: 48.w,
                                    height: 18,
                                  ),
                                  Text(
                                    chatUser.id == user.id ? user.name : chatUser.name,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFFF5F5F5),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  Container(
                                      width: 38.w,
                                      height: 18,
                                      margin: EdgeInsets.only(right: 10.w),
                                      alignment: Alignment.centerRight,
                                      child: isEditMode.value
                                          ? SvgPicture.asset('assets/images/pen.svg', height: 18)
                                          : null)
                                ],
                              ))),
                      SizedBox(height: 12.h),
                      GestureDetector(
                          onTap: () {
                            if (isEditMode.value) {
                              messageController.text = user.userInfo.stateMessage ?? '';
                              messageClicked.value = true;
                              FocusScope.of(context).requestFocus(messageFocus);
                            }
                          },
                          child: Container(
                              padding: EdgeInsets.only(bottom: 6.h, top: 4.h),
                              margin: EdgeInsets.only(left: 30.w, right: 22.w),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border(
                                  bottom: BorderSide(
                                    color: isEditMode.value
                                        ? const Color(0xFFE0E2E4)
                                        : Colors.transparent,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: 48.w),
                                  const Spacer(),
                                  Text(
                                    chatUser.id == user.id
                                        ? user.userInfo.stateMessage ?? 'status_msg'.tr()
                                        : chatUser.stateMessage ?? '',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFF5F5F5)),
                                    textAlign: TextAlign.center,
                                  ),
                                  const Spacer(),
                                  Container(
                                      width: 38.w,
                                      height: 18,
                                      margin: EdgeInsets.only(right: 10.w),
                                      alignment: Alignment.centerRight,
                                      child: isEditMode.value
                                          ? SvgPicture.asset('assets/images/pen.svg', height: 18)
                                          : null)
                                ],
                              ))),
                      SizedBox(height: 28.h),
                      Divider(
                          color: isEditMode.value ? Colors.transparent : const Color(0xFFE0E2E4),
                          thickness: 1),
                      SizedBox(height: 10.h),
                      SizedBox(
                          height: 74 + 92.h,
                          child: isEditMode.value
                              ? null
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(width: 20.w),
                                    if (chatUser.id == user.id)
                                      Column(
                                        children: [
                                          GestureDetector(
                                              onTap: () {
                                                isEditMode.value = true;
                                              },
                                              child: Container(
                                                  color: Colors.transparent,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.w, vertical: 10.h),
                                                  child: SvgPicture.asset(
                                                      'assets/images/pen_circle.svg',
                                                      width: 60))),
                                          SizedBox(height: 4.h),
                                          SizedBox(
                                              width: 60 + 24.w,
                                              child: Text(
                                                'profile_edit'.tr(),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                    color: Color(0xFFF5F5F5)),
                                                textAlign: TextAlign.center,
                                              ))
                                        ],
                                      ),
                                    if (chatUser.id != user.id) ...[
                                      Column(
                                        children: [
                                          GestureDetector(
                                              onTap: () {
                                                chatService.makeRoom([chatUser.id]);
                                              },
                                              child: Container(
                                                  color: Colors.transparent,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.w, vertical: 10.h),
                                                  child: SvgPicture.asset('assets/images/chat.svg',
                                                      width: 60))),
                                          SizedBox(height: 4.h),
                                          SizedBox(
                                              width: 60 + 24.w,
                                              child: Text(
                                                'profile_chat'.tr(),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                    color: Color(0xFFF5F5F5)),
                                                textAlign: TextAlign.center,
                                              )),
                                          SizedBox(height: 9.h)
                                        ],
                                      ),
                                      // Column(
                                      //   children: [
                                      //     GestureDetector(
                                      //         onTap: () {},
                                      //         child: Container(
                                      //             color: Colors.transparent,
                                      //             padding: EdgeInsets.symmetric(
                                      //                 horizontal: 10.w, vertical: 10.h),
                                      //             child: SvgPicture.asset(
                                      //                 'assets/images/voice_call.svg',
                                      //                 width: 60))),
                                      //     SizedBox(height: 4.h),
                                      //     SizedBox(
                                      //         width: 60 + 24.w,
                                      //         child: Text(
                                      //           'profile_voicechat'.tr(),
                                      //           style: const TextStyle(
                                      //               fontWeight: FontWeight.w500,
                                      //               fontSize: 14,
                                      //               color: Color(0xFFF5F5F5)),
                                      //           textAlign: TextAlign.center,
                                      //         )),
                                      //     SizedBox(height: 9.h)
                                      //   ],
                                      // ),
                                      // Column(
                                      //   children: [
                                      //     GestureDetector(
                                      //         onTap: () {},
                                      //         child: Container(
                                      //             color: Colors.transparent,
                                      //             padding: EdgeInsets.symmetric(
                                      //                 horizontal: 10.w, vertical: 10.h),
                                      //             child: SvgPicture.asset(
                                      //                 'assets/images/face_call.svg',
                                      //                 width: 60))),
                                      //     SizedBox(height: 4.h),
                                      //     SizedBox(
                                      //         width: 60 + 24.w,
                                      //         child: Text(
                                      //           'profile_videochat'.tr(),
                                      //           style: const TextStyle(
                                      //               fontWeight: FontWeight.w500,
                                      //               fontSize: 14,
                                      //               color: Color(0xFFF5F5F5)),
                                      //           textAlign: TextAlign.center,
                                      //         )),
                                      //     SizedBox(height: 9.h)
                                      //   ],
                                      // )
                                    ],
                                    SizedBox(width: 20.w)
                                  ],
                                ))
                    ],
                  )),
                  if (nameClicked.value || messageClicked.value) ...[
                    GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                        },
                        child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.black.withOpacity(0.7))),
                    Positioned(
                        left: 10.w,
                        top: 10.h,
                        child: SafeArea(
                            child: GestureDetector(
                                onTap: () {
                                  nameClicked.value = false;
                                  messageClicked.value = false;
                                },
                                child: Container(
                                    color: Colors.transparent,
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                    child:
                                        const Icon(Icons.close, color: Colors.white, size: 24))))),
                    Container(
                        width: 393.w,
                        height: 600.h,
                        padding: EdgeInsets.symmetric(horizontal: 30.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                SizedBox(width: 8.w),
                                Expanded(
                                    child: TextField(
                                  controller:
                                      nameClicked.value ? nameController : messageController,
                                  focusNode: nameClicked.value ? nameFocus : messageFocus,
                                  textAlign: TextAlign.center,
                                  onSubmitted: (value) {
                                    if (nameClicked.value) {
                                      if (value.trim().isEmpty || value.trim() == user.name) {
                                        nameClicked.value = false;
                                      } else if (value.trim().length > 12) {
                                        errorToast(message: '닉네임은 12자 이내로 입력해주세요');
                                      } else {
                                        userService.updateProfile(name: value.trim()).then((_) {
                                          nameClicked.value = false;
                                        });
                                      }
                                    } else {
                                      if (value.trim().isEmpty ||
                                          value.trim() == user.userInfo.stateMessage) {
                                        messageClicked.value = false;
                                      } else if (value.trim().length > 60) {
                                        errorToast(message: '상태메세지는 60자 이내로 입력해주세요');
                                      } else {
                                        userService
                                            .updateProfile(stateMessage: value.trim())
                                            .then((_) {
                                          messageClicked.value = false;
                                        });
                                      }
                                    }
                                  },
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                      hintText: nameClicked.value ? '닉네임' : '상태메세지',
                                      hintStyle: const TextStyle(
                                          color: Color(0xFFDBDBDB),
                                          fontSize: 18,
                                          fontWeight: FontWeight.normal),
                                      border: InputBorder.none),
                                )),
                                SizedBox(width: 4.w),
                                GestureDetector(
                                    onTap: () {
                                      if (nameClicked.value) {
                                        nameController.text = '';
                                      } else {
                                        messageController.text = '';
                                      }
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5),
                                      child: const Icon(Icons.close, color: Colors.white, size: 24),
                                    ))
                              ],
                            ),
                            const Divider(color: Colors.white, thickness: 1, height: 1),
                          ],
                        ))
                  ]
                ]))));
  }
}

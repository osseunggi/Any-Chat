import 'dart:io';

import 'package:anychat/main.dart';
import 'package:anychat/model/chat.dart';
import 'package:anychat/model/friend.dart';
import 'package:anychat/page/chat/camera_page.dart';
import 'package:anychat/page/chat/chat_page.dart';
import 'package:anychat/page/chat/invite_friend_page.dart';
import 'package:anychat/page/home/add_friend_by_id_page.dart';
import 'package:anychat/page/home/block_friend_page.dart';
import 'package:anychat/page/home/edit_friend_page.dart';
import 'package:anychat/page/home/hide_friend_page.dart';
import 'package:anychat/page/home/qr_view_page.dart';
import 'package:anychat/page/image_close_page.dart';
import 'package:anychat/page/login/consent_page.dart';
import 'package:anychat/page/login/language_select_page.dart';
import 'package:anychat/page/login/login_page.dart';
import 'package:anychat/page/login/login_with_email_page.dart';
import 'package:anychat/page/login/privacy_page.dart';
import 'package:anychat/page/login/register_page.dart';
import 'package:anychat/page/login/set_nickname_page.dart';
import 'package:anychat/page/login/set_profile_id_page.dart';
import 'package:anychat/page/login/terms_page.dart';
import 'package:anychat/page/setting/anychat_id_page.dart';
import 'package:anychat/page/setting/set_anychat_id_page.dart';
import 'package:anychat/page/user/chat_profile_page.dart';
import 'package:anychat/page/user/profile_page.dart';
import 'package:anychat/page/video_player_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../model/auth.dart';
import '../model/language.dart';
import 'main_layout.dart';

final router = GoRouter(
  initialLocation: MainLayout.routeName,
  routes: [
    GoRoute(
        path: LoginPage.routeName, builder: (context, state) => LoginPage(state.extra as Language)),
    GoRoute(
        path: LoginWithEmailPage.routeName,
        builder: (context, state) => LoginWithEmailPage(state.extra as Language)),
    GoRoute(
        path: RegisterPage.routeName,
        builder: (context, state) => RegisterPage(state.extra as Language)),
    GoRoute(
        path: SetNicknamePage.routeName,
        builder: (context, state) => SetNicknamePage(state.extra as Language)),
    GoRoute(path: CameraPage.routeName, builder: (context, state) => const CameraPage()),
    GoRoute(path: TermsPage.routeName, builder: (context, state) => const TermsPage()),
    GoRoute(path: PrivacyPage.routeName, builder: (context, state) => const PrivacyPage()),
    GoRoute(
        path: LanguageSelectPage.routeName,
        builder: (context, state) => const LanguageSelectPage()),
    GoRoute(
        path: ConsentPage.routeName,
        builder: (context, state) => ConsentPage(state.extra as Language)),
    GoRoute(
        path: SetProfileIdPage.routeName,
        builder: (context, state) => SetProfileIdPage(state.extra as Language)),
    GoRoute(path: MainLayout.routeName, builder: (context, state) => MainLayout()),
    GoRoute(
        path: ProfilePage.routeName,
        pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: ProfilePage(friend: state.extra as Friend?),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(position: offsetAnimation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300))),
    GoRoute(
        path: AddFriendByIdPage.routeName, builder: (context, state) => const AddFriendByIdPage()),
    GoRoute(
        path: QrViewPage.routeName, builder: (context, state) => QrViewPage(state.extra as int)),
    GoRoute(
        path: ChatPage.routeName,
        builder: (context, state) => ChatPage(state.extra as ChatRoomHeader)),
    GoRoute(
        path: ChatProfilePage.routeName,
        pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: ChatProfilePage(chatUser: state.extra as ChatUserInfo),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(position: offsetAnimation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300))),
    GoRoute(path: HideFriendPage.routeName, builder: (context, state) => const HideFriendPage()),
    GoRoute(path: BlockFriendPage.routeName, builder: (context, state) => const BlockFriendPage()),
    GoRoute(
        path: InviteFriendPage.routeName,
        builder: (context, state) =>
            InviteFriendPage(arguments: state.extra as Map<String, dynamic>?)),
    GoRoute(
        path: ImageClosePage.routeName,
        builder: (context, state) => ImageClosePage(file: state.extra as File)),
    GoRoute(
        path: VideoPlayerPage.routeName,
        builder: (context, state) => VideoPlayerPage(state.extra as File)),
    GoRoute(path: AnychatIdPage.routeName, builder: (context, state) => const AnychatIdPage()),
    GoRoute(
        path: SetAnychatIdPage.routeName, builder: (context, state) => const SetAnychatIdPage()),
    GoRoute(
      path: EditFriendPage.routeName,
      pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const EditFriendPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
          transitionDuration: Duration.zero),
    )
  ],
  redirect: (BuildContext context, GoRouterState state) {
    final allowRoute = [
      LoginPage.routeName,
      LanguageSelectPage.routeName,
      RegisterPage.routeName,
      LoginWithEmailPage.routeName,
      SetNicknamePage.routeName,
      ConsentPage.routeName,
      SetProfileIdPage.routeName,
      TermsPage.routeName,
      PrivacyPage.routeName
    ];

    final String? accessToken = prefs.getString('access_token');
    final String? refreshToken = prefs.getString('refresh_token');

    if (accessToken != null && refreshToken != null) {
      auth = Auth(accessToken: accessToken, refreshToken: refreshToken);
      return null;
    } else if (allowRoute.contains(state.fullPath)) {
      return null;
    } else {
      return LanguageSelectPage.routeName;
    }
  },
);

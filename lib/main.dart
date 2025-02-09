import 'dart:async';
import 'dart:ui';

import 'package:anychat/model/auth.dart';
import 'package:anychat/model/language.dart';
import 'package:anychat/page/main_layout.dart';
import 'package:anychat/page/router.dart';
import 'package:anychat/service/chat_service.dart';
import 'package:anychat/service/database_service.dart';
import 'package:anychat/service/friend_service.dart';
import 'package:anychat/service/launcher_service.dart';
import 'package:anychat/service/login_service.dart';
import 'package:anychat/service/translate_service.dart';
import 'package:anychat/service/user_service.dart';
import 'package:anychat/state/user_state.dart';
import 'package:anychat/state/util_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:toastification/toastification.dart';

import 'common/multi_lang_asset_loader.dart';
import 'firebase_options.dart';

late final SharedPreferences prefs;
Socket? socket;
bool internetConnected = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  prefs = await SharedPreferences.getInstance();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await DatabaseService.getDatabase();

  await LauncherService().launcher();

  runApp(EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ko', 'KR'),
        Locale('ja', 'JP'),
        Locale('id', 'ID'),
        Locale('th', 'TH'),
        Locale('zh', 'CN'),
        Locale('zh', 'TW'),
        Locale('es', 'ES'),
        Locale('fr', 'FR'),
        Locale('de', 'DE'),
        Locale('vi', 'VN'),
        Locale('ru'),
        Locale('ar', 'SA'),
        Locale('tl', 'PH'),
        Locale('kz'),
        Locale('mn', 'MN'),
        Locale('ms', 'MY'),
        Locale('pt', 'PT'),
        Locale('tr', 'TR'),
        Locale('uz', 'UZ'),
        Locale('ms', 'MY')
      ],
      path: 'assets/translations/translations.json',
      startLocale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      assetLoader: MultiLangAssetLoader(),
      child: const ProviderScope(child: MyApp())));
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLifecycleState = useAppLifecycleState();

    _initService(ref);

    useEffect(() {
      late final StreamSubscription<List<ConnectivityResult>> subscription;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ref.read(userProvider) != null) {
          context.setLocale(Language.fromCode(ref.read(userProvider)!.userInfo.lang).locale);
        } else {
          final language = Language.values
              .where((e) => e.name.toUpperCase() == PlatformDispatcher.instance.locale.countryCode)
              .firstOrNull;

          context.setLocale(language?.locale ?? Language.us.locale);
        }

        subscription =
            Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
          if (result.contains(ConnectivityResult.mobile) ||
              result.contains(ConnectivityResult.wifi)) {
            if (!internetConnected) {
              if (auth != null) {
                chatService.connectSocket();

                FriendService().getFriends(ref, isInit: true).then((value) {
                  friendsCursor = value;
                });

                FriendService().getPinned(ref);
                chatService.getRooms();
              }

              internetConnected = true;
            }
          } else {
            internetConnected = false;
          }
        });
      });

      return () {
        DatabaseService.close();
        subscription.cancel();
      };
    }, []);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (auth != null &&
            appLifecycleState == AppLifecycleState.resumed &&
            internetConnected &&
            ref.read(userProvider)?.auto == false) {
          chatService.connectSocket();

          FriendService().getFriends(ref, isInit: true).then((value) {
            friendsCursor = value;
          });
          FriendService().getPinned(ref);
          chatService.getRooms();
        }
      });

      return () {
        if (auth == null && socket?.connected == true) {
          chatService.disposeSocket();
        }
      };
    }, [ref.watch(userProvider)?.id, ref.watch(userProvider)?.auto, appLifecycleState]);

    return ScreenUtilInit(
        designSize: const Size(393, 852),
        splitScreenMode: false,
        builder: (_, child) => ToastificationWrapper(
            child: MaterialApp.router(
                theme: ThemeData(
                    useMaterial3: false,
                    scaffoldBackgroundColor: Colors.white,
                    fontFamily: 'Pretendard'),
                locale: context.locale,
                supportedLocales: context.supportedLocales,
                localizationsDelegates: context.localizationDelegates,
                routerConfig: router,
                debugShowCheckedModeBanner: false,
                builder: (context, child) {
                  return Stack(children: [
                    child!,
                    if (ref.watch(loadingProvider))
                      Container(
                          color: Colors.black.withOpacity(0.35),
                          child: SpinKitRing(
                              color: const Color(0xFF7C4DFF),
                              duration: const Duration(milliseconds: 1600),
                              lineWidth: 6.r,
                              size: 50.r))
                  ]);
                })));
  }

  void _initService(WidgetRef ref) {
    translateService = TranslateService(ref);
    chatService = ChatService(ref);
    loginService = LoginService(ref);
    userService = UserService(ref);
  }
}

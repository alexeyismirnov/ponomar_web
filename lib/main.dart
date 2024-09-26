import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:easy_localization/easy_localization.dart';

import 'dart:core';
import 'dart:io';

import 'animated_tabs.dart';
import 'main_page.dart';
import 'library_page.dart';
import 'translations.dart';
import 'restart_widget.dart';
import 'globals.dart';
import 'config_param.dart';
import 'church_fasting.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  await EasyLocalization.ensureInitialized();
  await ConfigParam.initSharedParams(initFontSize: 22);

  ConfigParamExt.bookmarks = ConfigParam<List<String>>('bookmarks', initValue: []);
  ConfigParamExt.fastingLevel = ConfigParam<int>('fastingLevel', initValue: 0);
  ChurchFasting.fastingLevel = FastingLevel.values[ConfigParamExt.fastingLevel.val()];

  await JSON.load();

  try {
    if (TelegramWebApp.instance.isSupported) {
      await TelegramWebApp.instance.ready();
      await TelegramWebApp.instance.disableVerticalSwipes();
      Future.delayed(const Duration(seconds: 1), TelegramWebApp.instance.expand);
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error happened in Flutter while loading Telegram $e");
    }
    // add delay for 'Telegram not loading sometimes' bug
    await Future.delayed(const Duration(milliseconds: 200));
    main();
    return;
  }

  runApp(EasyLocalization(
      supportedLocales: const [Locale('ru', 'RU')],
      path: 'ui,cal,reading,library',
      assetLoader: DirectoryAssetLoader(basePath: "assets/translations"),
      fallbackLocale: const Locale('ru', 'RU'),
      startLocale: const Locale('ru', 'RU'),
      child: RestartWidget(ContainerPage(tabs: [
        AnimatedTab(icon: const Icon(Icons.home), title: 'homepage', content: MainPage()),
        AnimatedTab(
            icon: const ImageIcon(
              AssetImage('assets/images/library.png'),
            ),
            title: 'library',
            content: LibraryPage()),
      ]))));
}

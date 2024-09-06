import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:easy_localization/easy_localization.dart';

import 'animated_tabs.dart';
import 'main_page.dart';
import 'library_page.dart';
import 'translations.dart';
import 'restart_widget.dart';
import 'globals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await JSON.load();

  try {
    if (TelegramWebApp.instance.isSupported) {
      await TelegramWebApp.instance.ready();
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

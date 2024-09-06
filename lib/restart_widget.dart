import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:easy_localization/easy_localization.dart';

class RestartWidget extends StatefulWidget {
  final Widget content;
  RestartWidget(this.content);

  @override
  RestartWidgetState createState() => RestartWidgetState();

  static restartApp(BuildContext context) {
    final RestartWidgetState? state = context.findAncestorStateOfType<RestartWidgetState>();
    state?.restartApp();
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

class RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        key = UniqueKey();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: key,
      scrollBehavior: AppScrollBehavior(),
      theme: TelegramThemeUtil.getTheme(TelegramWebApp.instance),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => "title".tr(),
      home: widget.content,
    );
  }
}

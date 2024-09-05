import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:easy_localization/easy_localization.dart';

class RestartWidget extends StatefulWidget {
  static restartApp(BuildContext context) {
    final _RestartWidgetState? state = context.findAncestorStateOfType<_RestartWidgetState>();
    state?.restartApp();
  }

  final Widget content;

  RestartWidget(this.content);

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    Future.delayed(const Duration(milliseconds: 500), () {
      this.setState(() {
        key = UniqueKey();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: key,
      theme: TelegramThemeUtil.getTheme(TelegramWebApp.instance),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      onGenerateTitle: (context) => "title".tr(),
      home: widget.content,
      debugShowCheckedModeBanner: false,
    );
  }
}

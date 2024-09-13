import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:sprintf/sprintf.dart';
import 'package:easy_localization/easy_localization.dart';

extension StringFormatExtension on String {
  String format(var arguments) => sprintf(this, arguments);
}

extension DateTimeDiff on DateTime {
  int operator >>(DateTime other) => other.difference(this).inDays;
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

Iterable<int> getRange(int low, int high, [int step = 1]) sync* {
  for (int i = low; i < high; i += step) {
    yield i;
  }
}

extension Capitalize on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}

extension ShowWidget on Widget {
  Future push(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => this,
      ));

  Future pushReplacement(BuildContext context) =>
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => this,
      ));

  Future<T?> show<T>(BuildContext context, {canDismiss = true}) =>
      showDialog<T>(barrierDismissible: canDismiss, context: context, builder: (_) => this);
}

extension ScreenDimensions on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isTablet => false; // screenWidth > 500;
}

extension LocaleContext on BuildContext {
  String get languageCode => locale.toString().split("_").first;
  String get countryCode => locale.toString().split("_").last.toLowerCase();
}

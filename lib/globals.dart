import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:easy_localization/easy_localization.dart';

import 'dart:convert';

extension LocaleContext on BuildContext {
  String get languageCode => locale.toString().split("_").first;
  String get countryCode => locale.toString().split("_").last.toLowerCase();
}


class DateChangedNotification extends Notification {
  late DateTime newDate;
  DateChangedNotification(this.newDate) : super();
}


class JSON {
  static late String calendar;
  static late String apostle,
      readingsJohn,
      gospelMatthew,
      gospelLuke,
      readingsLent;
  static late Function(String?) dateParser;

  static late String OldTestamentItems, OldTestamentFilenames;
  static late String NewTestamentItems, NewTestamentFilenames;

  static Map<String, Map<String, String>> bibleTrans = {};
  static Map<String, Map<String, String>> fastingComments = {};

  static translateReading(String s, {required String lang}) => bibleTrans[lang]!
      .entries
      .fold(s, (String prev, e) => prev.replaceAll(e.key, e.value));

  static Future load() async {
    calendar = await rootBundle.loadString("assets/calendar/calendar.json");
    apostle =
    await rootBundle.loadString("assets/calendar/ReadingApostle.json");
    readingsJohn =
    await rootBundle.loadString("assets/calendar/ReadingJohn.json");
    gospelMatthew =
    await rootBundle.loadString("assets/calendar/ReadingMatthew.json");
    gospelLuke =
    await rootBundle.loadString("assets/calendar/ReadingLuke.json");
    readingsLent =
    await rootBundle.loadString("assets/calendar/ReadingLent.json");

    OldTestamentItems =
    await rootBundle.loadString("assets/bible/OldTestamentItems.json");
    OldTestamentFilenames =
    await rootBundle.loadString("assets/bible/OldTestamentFilenames.json");
    NewTestamentItems =
    await rootBundle.loadString("assets/bible/NewTestamentItems.json");
    NewTestamentFilenames =
    await rootBundle.loadString("assets/bible/NewTestamentFilenames.json");

    bibleTrans['ru'] = Map<String, String>.from(jsonDecode(
        await rootBundle.loadString("assets/translations/ru-RU/reading.json")));

    fastingComments['ru'] = Map<String, String>.from(jsonDecode(
        await rootBundle.loadString("assets/translations/ru-RU/fasting.json")));
  }
}


extension Capitalize on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}
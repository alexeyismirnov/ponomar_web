import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'dart:convert';
import 'config_param.dart';
import 'book_model.dart';

class DateChangedNotification extends Notification {
  late DateTime newDate;
  DateChangedNotification(this.newDate) : super();
}

class BookPositionNotification extends Notification {
  late BookPosition pos;
  BookPositionNotification(this.pos) : super();
}

extension ConfigParamExt on ConfigParam {
  static var fastingLevel;
  static var bookmarks;
}

String hostURL = "ponomarserver-production.up.railway.app";

class JSON {
  static late String calendar;
  static Map<String, String> lives_calendar = {};

  static late String apostle, readingsJohn, gospelMatthew, gospelLuke, readingsLent;
  static late Function(String?) dateParser;

  static late String OldTestamentItems, OldTestamentFilenames;
  static late String NewTestamentItems, NewTestamentFilenames;

  static Map<String, Map<String, String>> bibleTrans = {};
  static Map<String, Map<String, String>> fastingComments = {};

  static translateReading(String s, {required String lang}) =>
      bibleTrans[lang]!.entries.fold(s, (String prev, e) => prev.replaceAll(e.key, e.value));

  static Future load() async {
    calendar = await rootBundle.loadString("assets/calendar/calendar.json");
    lives_calendar['en'] = await rootBundle.loadString("assets/calendar/saints_lives_en.json");
    lives_calendar['ru'] = await rootBundle.loadString("assets/calendar/saints_lives_ru.json");

    apostle = await rootBundle.loadString("assets/calendar/ReadingApostle.json");
    readingsJohn = await rootBundle.loadString("assets/calendar/ReadingJohn.json");
    gospelMatthew = await rootBundle.loadString("assets/calendar/ReadingMatthew.json");
    gospelLuke = await rootBundle.loadString("assets/calendar/ReadingLuke.json");
    readingsLent = await rootBundle.loadString("assets/calendar/ReadingLent.json");

    OldTestamentItems = await rootBundle.loadString("assets/bible/OldTestamentItems.json");
    OldTestamentFilenames = await rootBundle.loadString("assets/bible/OldTestamentFilenames.json");
    NewTestamentItems = await rootBundle.loadString("assets/bible/NewTestamentItems.json");
    NewTestamentFilenames = await rootBundle.loadString("assets/bible/NewTestamentFilenames.json");

    bibleTrans['ru'] = Map<String, String>.from(
        jsonDecode(await rootBundle.loadString("assets/translations/ru-RU/reading.json")));
    bibleTrans['en'] = Map<String, String>.from(
        jsonDecode(await rootBundle.loadString("assets/translations/en-EN/reading.json")));
    bibleTrans['hk'] = Map<String, String>.from(
        jsonDecode(await rootBundle.loadString("assets/translations/zh-HK/reading.json")));

    fastingComments['ru'] = Map<String, String>.from(
        jsonDecode(await rootBundle.loadString("assets/translations/ru-RU/fasting.json")));
    fastingComments['en'] = Map<String, String>.from(
        jsonDecode(await rootBundle.loadString("assets/translations/en-EN/fasting.json")));
    fastingComments['hk'] = Map<String, String>.from(
        jsonDecode(await rootBundle.loadString("assets/translations/zh-HK/fasting.json")));
  }
}

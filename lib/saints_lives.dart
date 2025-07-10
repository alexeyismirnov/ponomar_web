import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:supercharged/supercharged.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:html' as html;

import 'custom_list_tile.dart';
import 'globals.dart';
import 'church_day.dart';
import 'church_calendar.dart';
import 'extensions.dart';

class SaintsLivesModel {
  final String title;
  final String text;

  SaintsLivesModel(this.title, this.text);

  SaintsLivesModel.fromJson(Map<String, dynamic> json)
      : title = "${json['title']}",
        text = "${json['text']}";

  @override
  String toString() {
    return "$title $text";
  }
}

class SaintsCalendar {
  int year;
  String lang;
  List<ChurchDay> days = [];
  late Future initFuture;

  static Map<String, SaintsCalendar> calendars = {};

  SaintsCalendar._(this.year, this.lang) {
    initFuture = loadBook();
  }

  ChurchDay day(String name) => days.where((e) => e.name == name).first;

  Future loadBook() async {
    final cal = ChurchCalendar.fromDate(DateTime.utc(year, 1, 1));
    JSON.dateParser = cal.dateParser;

    List<dynamic> parsed = jsonDecode(JSON.lives_calendar[lang]!);
    days = List<ChurchDay>.from(parsed.map((i) => ChurchDay.fromJson(i)));

    final pascha = Cal.paschaDay(year);
    final pentecost = pascha + 49.days;
    final greatLentStart = pascha - 48.days;
    final isLeapYear = Cal.isLeap(year: year);

    day("findingOfHead").date = isLeapYear ? DateTime.utc(year, 3, 8) : DateTime.utc(year, 3, 9);
    day("holyFathersSixCouncils").date = Cal.nearestSunday(DateTime.utc(year, 7, 29));
    day("holyFathersSeventhCouncil").date = Cal.nearestSunday(DateTime.utc(year, 10, 24));

    day("saturdayOfFathers").date = greatLentStart - 2.days;
    day("sunday4GreatLent").date = greatLentStart + 27.days;

    day("beginningOfGreatLent").date = greatLentStart;
    day("saturday1GreatLent").date = greatLentStart + 5.days;
    day("sunday1GreatLent").date = greatLentStart + 6.days;
    day("sunday3GreatLent").date = greatLentStart + 20.days;

    day("sunday5GreatLent").date = greatLentStart + 34.days;
    day("palmSunday").date = pascha - 7.days;
    day("greatWednesday").date = pascha - 4.days;

    day("greatMonday").date = pascha - 6.days;
    day("greatTuesday").date = pascha - 5.days;
    day("greatSaturday").date = pascha - 1.days;

    day("ascension").date = pascha + 39.days;
    day("pentecost").date = pentecost;
    day("sunday1AfterPentecost").date = pentecost + 7.days;
    day("sunday3AfterPascha").date = pascha + 14.days;
    day("sunday4AfterPascha").date = pascha + 21.days;
    day("sunday7AfterPascha").date = pascha + 42.days;
    day("kurskTheotokos").date = pentecost + 12.days;

    day("sundayOfZacchaeus").date = greatLentStart - 29.days;
    day("sundayOfProdigalSon").date = greatLentStart - 15.days;
    day("saturdayOfDeparted").date = greatLentStart - 9.days;

    day("sunday4GreatLent").date = greatLentStart + 27.days;
    day("friday5GreatLent").date = greatLentStart + 32.days;
    day("saturday5GreatLent").date = greatLentStart + 33.days;

    day("lazarusDeath").date = pascha - 11.days;
    day("lazarusSaturday").date = pascha - 8.days;
    day("greatFriday").date = pascha - 2.days;

    day("pascha").date = pascha;
    day("brightMonday").date = pascha + 1.days;
    day("brightFriday").date = pascha + 5.days;
    day("sunday2AfterPascha").date = pascha + 7.days;
    day("radonitsa").date = pascha + 9.days;
    day("sunday5AfterPascha").date = pascha + 28.days;
    day("sunday6AfterPascha").date = pascha + 35.days;
    day("apodosis_pascha").date = pascha + 38.days;
    day("saturdayTrinity").date = pascha + 48.days;

    day("apodosisOfPentecost").date = pentecost + 6.days;
    day("sunday2AfterPentecost").date = pentecost + 14.days;

    var nativity = DateTime.utc(year, 1, 7);
    if (nativity.weekday == DateTime.sunday) {
      day("josephBetrothed").date = nativity + 1.days;
    } else {
      day("josephBetrothed").date = Cal.nearestSundayAfter(nativity);
    }
  }

  factory SaintsCalendar.fromDate(DateTime d, {required String lang}) {
    var year = d.year;

    if (!SaintsCalendar.calendars.containsKey("$year-$lang")) {
      SaintsCalendar.calendars["$year-$lang"] = SaintsCalendar._(year, lang);
    }

    return SaintsCalendar.calendars["$year-$lang"]!;
  }
}

class SaintsLivesView extends StatelessWidget {
  final DateTime date;

  SaintsLivesView(this.date);

  Future<Widget?> fetch(BuildContext context) async {
    var baseURL = 'https://fr-augustine.gitbook.io/lives-of-saints';
    if (context.languageCode == "ru") baseURL += '/zhitiya-svyatykh';

    final cal = SaintsCalendar.fromDate(date, lang: context.languageCode);
    final cc = ChurchCalendar.fromDate(date);
    DateTime d = date;
    List<Widget> res = [];

    await cal.initFuture;

    if (cc.isLeapYear && date.isBetween(cc.leapStart, cc.leapEnd - 1.days)) {
      d = date + 1.days;
    }

    final days = cal.days.where((e) => e.date == d).toList();

    if (days.isEmpty) return null;

    for (var s in days) {
      res.add(CustomListTile(
          padding: 10,
          title: s.comment!,
          subtitle: 'lives_of_saints'.tr(),
          onTap: () {
            html.window.open("$baseURL/${s.reading}", '');
          }));
    }

    return Column(children: res + [const SizedBox(height: 5)]);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Widget?>(
      future: fetch(context),
      builder: (BuildContext context, AsyncSnapshot<Widget?> snapshot) {
        final result = snapshot.data;
        return result ?? Container();
      });
}

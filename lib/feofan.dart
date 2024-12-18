import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';

import 'church_calendar.dart';
import 'custom_list_tile.dart';
import 'book_page_single.dart';
import 'globals.dart';
import 'church_reading.dart';
import 'book_cell.dart';
import 'config_param.dart';
import 'extensions.dart';

class FeofanView extends StatefulWidget {
  final DateTime date;
  final Cal cal;
  final double fontSize;

  FeofanView(this.date, {Key? key})
      : cal = Cal.fromDate(date),
        fontSize = ConfigParam.fontSize.val(),
        super(key: key);

  @override
  FeofanViewState createState() => FeofanViewState();
}

class FeofanViewState extends State<FeofanView> {
  late String savedContent;

  DateTime get date => widget.date;
  Cal get cal => widget.cal;
  double get fontSize => widget.fontSize;

  Widget getListTile(BuildContext context, String content,
      {String? subtitle, String title = "everyday_thoughts"}) {
    savedContent = content;
    return Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: CustomListTile(
            title: title.tr(),
            subtitle: subtitle,
            onTap: () =>
                BookPageSingle(title.tr(), builder: () => BookCellText(content)).push(context)));
  }

  Future<String> getFeofan(String id) async {
    final payload =
        jsonEncode(<String, dynamic>{'id': id, 'fuzzy': false, 'lang': context.languageCode});

    final r = await http.post(Uri.parse('https://$hostURL/feofan'), body: payload);

    if (r.statusCode == 200) {
      var data = utf8.decode(r.bodyBytes);
      return data;
    } else {
      return "";
    }
  }

  Future<String> getFeofanGospel(String id) async {
    final payload =
        jsonEncode(<String, dynamic>{'id': id, 'fuzzy': true, 'lang': context.languageCode});

    final r = await http.post(Uri.parse('https://$hostURL/feofan'), body: payload);

    if (r.statusCode == 200) {
      var data = utf8.decode(r.bodyBytes);
      return data;
    } else {
      return "";
    }
  }

  String readingTranslate(String str) =>
      JSON.bibleTrans["ru"]!.entries.fold(str, (String prev, e) => prev.replaceAll(e.key, e.value));

  String getId(String pericope) =>
      context.languageCode == "en" ? pericope : pericope.replaceAll(" ", "");

  Future<List<Widget>> fetch(BuildContext context) async {
    List<Widget> result = [];

    if (date == cal.d("meetingOfLord")) {
      return [getListTile(context, (await getFeofan("33")))];
    } else if (date == DateTime.utc(cal.year, 9, 21) || date == DateTime.utc(cal.year, 10, 14)) {
      return [];
    } else if (date == DateTime.utc(cal.year, 12, 4)) {
      return [getListTile(context, (await getFeofan("325")))];
    } else if (date == DateTime.utc(cal.year, 8, 19)) {
      return [getListTile(context, (await getFeofan("218")))];
    } else if (date == DateTime.utc(cal.year, 8, 28)) {
      return [getListTile(context, (await getFeofan("227")))];
    } else if (date == cal.greatLentStart - 3.days) {
      return [getListTile(context, (await getFeofan("36")))];
    } else if (date == cal.greatLentStart - 5.days) {
      return [getListTile(context, (await getFeofan("34")))];
    } else if (date == cal.pascha - 3.days || date == cal.pascha - 2.days) {
      return [];
    } else if (date == cal.d("sundayBeforeNativity1") || date == cal.d("sundayBeforeNativity2")) {
      return [getListTile(context, (await getFeofan("346")))];
    } else if (date.isBetween(cal.greatLentStart, cal.pascha - 1.days)) {
      final num = (cal.greatLentStart >> date) + 39;
      result = [getListTile(context, (await getFeofan("$num")))];
    }

    final readings = ChurchReading.forDate(date);

    for (final r in readings) {
      var pericope = r.split("#")[0];

      if (context.languageCode == "ru") {
        pericope = readingTranslate(pericope);
      }

      var f = await getFeofan(getId(pericope));
      if (f.isNotEmpty) result.add(getListTile(context, f, subtitle: pericope));
    }

    if (result.isEmpty) {
      for (final r in readings) {
        final str = r.split("#")[0];
        final p = str.split(" ");

        for (final i in getRange(0, p.length, 2)) {
          if (["John", "Luke", "Mark", "Matthew"].contains(p[i])) {
            var pericope = "${p[i]} ${p[i + 1]}";

            if (context.languageCode == "ru") {
              pericope = readingTranslate(pericope);
            }

            var f = await getFeofanGospel(getId(pericope));
            if (f.isNotEmpty) result.add(getListTile(context, f, subtitle: pericope));
          }
        }
      }
    }

    if (result.length == 1) {
      return [getListTile(context, savedContent)];
    }

    return result;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Widget>>(
      future: fetch(context),
      builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
        if (snapshot.hasData) {
          final result = List<Widget>.from(snapshot.data!);

          if (result.isNotEmpty) {
            return Column(children: result);
          }
        }

        return Container();
      });
}

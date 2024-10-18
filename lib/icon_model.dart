import 'package:supercharged/supercharged.dart';

import 'church_day.dart';
import 'church_calendar.dart';
import 'globals.dart';

import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';

class SaintIcon {
  final int id;
  final String name;

  SaintIcon(this.id, this.name);

  SaintIcon.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = "${json['name']}";
}

class IconModel {
  static Future<List<SaintIcon>> fetch(DateTime d) async {
    List<SaintIcon> icons = [];
    final cal = ChurchCalendar.fromDate(d);

    List<ChurchDay> movable = [
      ChurchDay("100001", FeastType.great, date: cal.d("palmSunday"), comment: "palmSunday"),
      ChurchDay("100000", FeastType.great, date: cal.pascha, comment: "pascha"),
      ChurchDay("100002", FeastType.great, date: cal.d("ascension"), comment: "ascension"),
      ChurchDay("100003", FeastType.great, date: cal.pentecost, comment: "pentecost"),
      ChurchDay("2250", FeastType.none, date: cal.pascha + 2.days, comment: "theotokosIveron"),
      ChurchDay("100100", FeastType.none,
          date: cal.pascha + 5.days, comment: "theotokosLiveGiving"),
      ChurchDay("100101", FeastType.none,
          date: cal.pascha + 24.days, comment: "theotokosDubenskaya"),
      ChurchDay("100103", FeastType.none,
          date: cal.pascha + 42.days, comment: "theotokosChelnskaya"),
      ChurchDay("100105", FeastType.none, date: cal.pascha + 56.days, comment: "theotokosWall"),
      ChurchDay("100106", FeastType.none,
          date: cal.pascha + 56.days, comment: "theotokosSevenArrows"),
      ChurchDay("100108", FeastType.none, date: cal.pascha + 61.days, comment: "theotokosTabynsk"),
      ChurchDay("100114", FeastType.none, date: cal.pascha + 61.days, comment: "theotokosKursk"),
    ];

    final movIcons = movable.where((e) => e.date == d).toList();

    for (final icon in movIcons) {
      icons.add(SaintIcon(int.parse(icon.name),""));
    }

    final url = "https://$hostURL/icons/${d.day}/${d.month}/${d.year}";

    try {
      final r = await http.get(Uri.parse(url));

      if (r.statusCode == 200) {
        final data = utf8.decode(r.bodyBytes);
        icons.addAll(
            (jsonDecode(data) as List<dynamic>).map<SaintIcon>((b) => SaintIcon.fromJson(b)));
        return icons;
      } else {
        throw Exception('Failed to load ');
      }
    } catch (e) {
      print(e);
      return [];
    }
  }
}

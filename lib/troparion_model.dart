import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'custom_list_tile.dart';
import 'troparion_view.dart';
import 'globals.dart';
import 'extensions.dart';
import 'church_calendar.dart';

class Troparion {
  String title = "";
  String content = "";
  String? glas;

  Troparion.fromJson(Map<String, dynamic> json)
      : title = "${json['title']}",
        content = "${json['content']}",
        glas = "${json['comment']}";

  Troparion.fromJsonShort(Map<String, dynamic> json)
      : title = "${json['title']}",
        content = "${json['content']}",
        glas = "";
}

class TroparionWidget extends StatelessWidget {
  final DateTime date;
  final Cal cal;

  TroparionWidget(this.date) : cal = Cal.fromDate(date);

  Future<List<Troparion>> getData(String url) async {
    final short = url.contains("tropfeast");
    final r = await http.get(Uri.parse(url));

    if (r.statusCode == 200) {
      final data = utf8.decode(r.bodyBytes);
      return ((jsonDecode(data) as List<dynamic>)
              .map<Troparion>((b) => short ? Troparion.fromJsonShort(b) : Troparion.fromJson(b)))
          .toList();
    } else {
      throw Exception('Failed to load ');
    }
  }

  Future<List<Troparion>> fetchSunday(String lang) async {
    List<Troparion> results = [];

    if (date.weekday == DateTime.sunday) {
      final tone = cal.getTone(date);
      if (tone != null) {
        results.addAll(await getData("https://$hostURL/tropfeast?id=sundayGlas$tone&lang=$lang"));
      }
    }
    return results;
  }

  Future<List<Troparion>> fetchFeast(String lang) async {
    List<Troparion> results = [];
    var feastsCodes = [
      "sundayOfPublicianAndPharisee",
      "sundayOfProdigalSon",
      "sundayOfDreadJudgement",
      "cheesefareSunday",
      "sunday1GreatLent",
      "sunday2GreatLent",
      "sunday3GreatLent",
      "sunday4GreatLent",
      "sunday5GreatLent",
      "sunday2AfterPascha",
      "sunday3AfterPascha",
      "sunday4AfterPascha",
      "sunday5AfterPascha",
      "sunday6AfterPascha",
      "sunday7AfterPascha",
      "sunday1AfterPentecost",
      "holyFathersSixCouncils",
      "holyFathersSeventhCouncil",
      "eveOfTheophany",
      "eveOfNativityOfGod",
      "saturday1GreatLent",
      "saturday2GreatLent",
      "saturday3GreatLent",
      "saturday4GreatLent",
      "saturday5GreatLent",
      "greatMonday",
      "greatTuesday",
      "greatWednesday",
      "greatThursday",
      "greatFriday",
      "greatSaturday"
    ];

    if (lang == "ru") {
      feastsCodes.add("midPentecost");
    }

    final descr = cal.getDayDescription(date).map<String>((f) => f.name);
    final feasts = feastsCodes.toSet().intersection(descr.toSet());

    for (final feast in feasts) {
      results.addAll(await getData("https://$hostURL/tropfeast?id=$feast&lang=$lang"));
    }

    return results;
  }

  Future<List<Troparion>> fetch(String lang) async {
    List<Troparion> results = [];
    var greatFeasts = Cal.getGreatFeast(date);

    try {
      if (greatFeasts.isNotEmpty) {
        for (final feast in greatFeasts) {
          results.addAll(await getData("https://$hostURL/tropfeast?id=${feast.name}&lang=$lang"));

          final otherGreatFeasts = [
            "veilOfTheotokos",
            "nativityOfJohn",
            "beheadingOfJohn",
            "peterAndPaul",
            "dormition",
            "nativityOfTheotokos",
            "annunciation",
            "entryIntoTemple"
          ];

          if (otherGreatFeasts.contains(feast.name) && date.weekday == DateTime.sunday) {
            results.addAll(await fetchSunday(lang));
            results.addAll(await fetchFeast(lang));
          }
        }
      } else {
        results.addAll(await fetchSunday(lang));
        results.addAll(await fetchFeast(lang));

        final url = "https://$hostURL/tropsaint/$lang/${date.day}/${date.month}/${date.year}";
        results.addAll(await getData(url));
      }
    } catch (e) {
      print(e);
    }

    return results;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Troparion>>(
      future: fetch(context.languageCode),
      builder: (BuildContext context, AsyncSnapshot<List<Troparion>> snapshot) {
        if (snapshot.hasData) {
          final troparia = List<Troparion>.from(snapshot.data!);

          if (troparia.isNotEmpty) {
            return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: CustomListTile(
                    title: "troparia_kontakia".tr(),
                    onTap: () => TroparionView(troparia).push(context)));
          }
        }

        return Container();
      });
}

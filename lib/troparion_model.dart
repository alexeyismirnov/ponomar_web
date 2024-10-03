import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'custom_list_tile.dart';
import 'troparion_view.dart';
import 'globals.dart';
import 'extensions.dart';

class Troparion {
  String title = "";
  String content = "";
  String? glas;

  Troparion.fromJson(Map<String, dynamic> json)
      : title = "${json['title']}",
        content = "${json['content']}",
        glas = "${json['comment']}";
}

class SaintTroparion extends StatelessWidget {
  final DateTime date;

  SaintTroparion(this.date);

  Future<List<Troparion>> fetch() async {
    final url = "$hostURL/tropsaint/${date.day}/${date.month}/${date.year}";

    try {
      final r = await http.get(Uri.parse(url));

      if (r.statusCode == 200) {
        final data = utf8.decode(r.bodyBytes);
        return (jsonDecode(data) as List<dynamic>)
            .map<Troparion>((b) => Troparion.fromJson(b))
            .toList();
      } else {
        throw Exception('Failed to load ');
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Troparion>>(
      future: fetch(),
      builder: (BuildContext context, AsyncSnapshot<List<Troparion>> snapshot) {
        if (snapshot.hasData) {
          final troparia = List<Troparion>.from(snapshot.data!);

          if (troparia.isNotEmpty) {
            return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: CustomListTile(
                    title: "Тропари и кондаки",
                    onTap: () => TroparionView(troparia).push(context)));
          }
        }

        return Container();
      });
}

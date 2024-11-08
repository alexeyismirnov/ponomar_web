import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'custom_list_tile.dart';
import 'book_page_single.dart';
import 'book_cell.dart';
import 'globals.dart';
import 'extensions.dart';

import 'dart:async';
import 'dart:convert';

class TaushevView extends StatelessWidget {
  final String r;
  final author = "Архиеп. Аверкий (Таушев)";

  TaushevView(this.r);

  Future<Widget?> fetch(BuildContext context) async {
    final str = r.split("#")[0];
    final p = str.trim().split(" ");

    for (final i in getRange(0, p.length, 2)) {
      if (["John", "Luke", "Mark", "Matthew"].contains(p[i])) {
        final id = JSON.translateReading("${p[i]} ${p[i + 1]}", lang: context.languageCode);

        final payload = jsonEncode(<String, dynamic>{
          'id': id,
        });

        final r = await http.post(Uri.parse('https://$hostURL/taushev'), body: payload);

        if (r.statusCode == 200) {
          var data = jsonDecode(utf8.decode(r.bodyBytes));

          return CustomListTile(
              title: data["subtitle"] as String,
              subtitle: author,
              onTap: () => BookPageSingle(id, builder: () => BookCellText(data["text"] as String))
                  .push(context));
        } else {
          return null;
        }
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Widget?>(
      future: fetch(context),
      builder: (BuildContext context, AsyncSnapshot<Widget?> snapshot) {
        final result = snapshot.data;

        if (result != null) {
          return Column(children: [result, const SizedBox(height: 5)]);
        }

        return Container();
      });
}

import 'package:group_list_view/group_list_view.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';

import 'book_model.dart';
import 'globals.dart';

class EbookModel extends BookModel {
  @override
  late String code;

  @override
  late BookContentType contentType;

  @override
  late String title;

  @override
  late String? author;

  @override
  late String lang;

  @override
  bool get hasChapters => false;

  @override
  late Future initFuture;

  late List<String> sections;
  late Map<int, List<String>> items = {};

  String filename;

  EbookModel(this.filename) {
    initFuture = loadBook(filename);
  }

  Future loadBook(String filename) async {
    final r = await http.get(Uri(
        scheme: 'https', host: hostURL, path: "bookdata", queryParameters: {"filename": filename}));

    if (r.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(utf8.decode(r.bodyBytes));
      code = data["code"];
      title = data["title"];
      author = data["author"];
      lang = "ru";
      contentType = BookContentType.values[int.parse(data["contentType"])];

      sections = List<String>.from(data["sections"]);

      for (final (i, _) in sections.indexed) {
        items[i] = List<String>.from(data["items"][i]);
      }
    } else {
      throw Exception('Failed to load ');
    }
  }

  @override
  List<String> getSections() {
    return sections;
  }

  @override
  List<String> getItems(int section) {
    return items[section]!;
  }

  @override
  String getTitle(BookPosition pos) => items[pos.index!.section]![pos.index!.index];

  @override
  Future getContent(BookPosition pos) async {
    final r = await http.get(Uri(
        scheme: 'https',
        host: hostURL,
        path: "bookcontent",
        queryParameters: {
          "filename": filename,
          "section": "${pos.index!.section}",
          "item": "${pos.index!.index}"
        }));

    if (r.statusCode == 200) {
      var data = utf8.decode(r.bodyBytes);
      return data;
    } else {
      return "";
    }

  }

  @override
  Future<String?> getComment(int commentId) async {
    return "";
    /*
    return SqfliteExt.firstStringValue(
        await db.query("comments", columns: ["text"], where: "id=?", whereArgs: [commentId]));

     */
  }

  @override
  BookPosition? getNextSection(BookPosition pos) {
    final index = pos.index!;
    final sections = getSections();
    final items = getItems(index.section);

    if (index.index + 1 == items.length) {
      if (index.section + 1 == sections.length) {
        return null;
      } else {
        return BookPosition.modelIndex(this, IndexPath(section: index.section + 1, index: 0));
      }
    } else {
      return BookPosition.modelIndex(
          this, IndexPath(section: index.section, index: index.index + 1));
    }
  }

  @override
  BookPosition? getPrevSection(BookPosition pos) {
    final index = pos.index!;

    if (index.index == 0) {
      if (index.section == 0) {
        return null;
      } else {
        final items = getItems(index.section - 1);

        return BookPosition.modelIndex(
            this, IndexPath(section: index.section - 1, index: items.length - 1));
      }
    } else {
      return BookPosition.modelIndex(
          this, IndexPath(section: index.section, index: index.index - 1));
    }
  }

  @override
  String? getBookmark(BookPosition pos) {
    final index = pos.index!;
    return "${code}_${index.section}_${index.index}";
  }

  @override
  String getBookmarkName(String bookmark) {
    final comp = bookmark.split("_");
    if (comp[0] != code) return "";

    final section = int.parse(comp[1]);
    final row = int.parse(comp[2]);

    final item_title = items[section]![row];
    return "$title — $item_title";
  }
}

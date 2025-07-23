import 'package:flutter/material.dart';
import 'package:group_list_view/group_list_view.dart';
import 'package:easy_localization/easy_localization.dart';

import 'book_model.dart';
import 'ebook_model.dart';
import 'custom_list_tile.dart';
import 'book_toc.dart';
import 'extensions.dart';
import 'bible_model.dart';

class LibraryPage extends StatefulWidget {
  @override
  LibraryPageState createState() => LibraryPageState();
}

class LibraryPageState extends State<LibraryPage> {
  List<List<BookModel>> books = [];
  List<String> sections = [];
  bool ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (ready) return;

    sections.add("Bible");
    books.add([
      OldTestamentModel(context.countryCode),
      NewTestamentModel(context.countryCode),
    ]);

    if (context.languageCode != "zh") {
      sections.add("prayerbook");
      books.add([
        EbookModel("prayerbook_${context.languageCode}.sqlite"),
      ]);

      sections.add("liturgical_books");
      books.add([
        EbookModel("vigil_${context.languageCode}.sqlite"),
        EbookModel("liturgy_${context.languageCode}.sqlite"),
      ]);
    }

    if (context.languageCode == "ru") {
      sections.add("Разное");
      books.add([
        EbookModel("taushev.sqlite"),
        EbookModel("zerna.sqlite"),
      ]);
    }

    var futures = <Future>[];
    for (final model in books.expand((e) => e)) {
      futures.add(model.initFuture);
    }

    try {
      Future.wait(futures).then((_) => setState(() => ready = true));
    } catch (e) {
      print(e);
    }
  }

  Widget getContent() {
    if (!ready) return Container();

    return GroupListView(
      padding: const EdgeInsets.all(0),
      shrinkWrap: true,
      sectionsCount: sections.length,
      countOfItemInSection: (int section) => books[section].length,
      itemBuilder: (BuildContext context, IndexPath index) {
        return CustomListTile(
          padding: 10,
          reversed: true,
          lang: books[index.section][index.index].lang,
          onTap: () => BookTOC(books[index.section][index.index]).push(context),
          title: books[index.section][index.index].title,
          subtitle: books[index.section][index.index].author ?? "",
        );
      },
      groupHeaderBuilder: (BuildContext context, int section) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(sections[section].tr().toUpperCase(), style: Theme.of(context).textTheme.labelLarge),
          const Divider(thickness: 1)
        ]);
      },
      separatorBuilder: (context, index) => const SizedBox(),
      sectionSeparatorBuilder: (context, section) => const SizedBox(height: 15),
    );
  }

  @override
  Widget build(BuildContext context) =>
      SafeArea(child: Padding(padding: const EdgeInsets.all(15), child: getContent()));
}

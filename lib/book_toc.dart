import 'package:flutter/material.dart';

import 'package:group_list_view/group_list_view.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

import 'book_model.dart';
import 'globals.dart';
import 'book_page_multiple.dart';
import 'extensions.dart';

class _ChaptersView extends StatefulWidget {
  final BookPosition pos;
  final TextStyle style;
  const _ChaptersView(this.pos, this.style);

  @override
  _ChaptersViewState createState() => _ChaptersViewState();
}

class _ChaptersViewState extends State<_ChaptersView> {
  bool ready = false;
  BookPosition get pos => widget.pos;
  late int numChapters;

  @override
  void initState() {
    super.initState();

    pos.model!.getNumChapters(pos.index!).then((_numChapters) => setState(() {
          numChapters = _numChapters;
          ready = true;
        }));
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) return Container();

    return Wrap(
        spacing: 0.0,
        runSpacing: 0.0,
        children: List<int>.generate(numChapters, (i) => i + 1)
            .map((i) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => BookPositionNotification(
                        BookPosition.modelIndex(pos.model, pos.index, chapter: i - 1))
                    .dispatch(context),
                child: SizedBox(
                    width: 50, height: 50, child: Center(child: Text("$i", style: widget.style)))))
            .toList());
  }
}

class BookTOC extends StatefulWidget {
  final BookModel model;
  const BookTOC(this.model);

  @override
  _BookTOCState createState() => _BookTOCState();
}

class _BookTOCState extends State<BookTOC> {
  BookModel get model => widget.model;
  List<String> get sections => model.getSections();

  Widget getContent() {
    var fontTitleOrig = Theme.of(context).textTheme.titleLarge!;
    var fontLabelOrig = Theme.of(context).textTheme.labelLarge!;

    return NotificationListener<Notification>(
        onNotification: (n) {
          if (n is BookPositionNotification) {
            BookPosition? pos = n.pos;
            BookPageMultiple(pos).push(context).then((_) => setState(() {}));
          }
          return true;
        },
        child: sections.isEmpty
            ? Container()
            : GroupListView(
                shrinkWrap: true,
                sectionsCount: sections.length,
                countOfItemInSection: (int section) => model.getItems(section).length,
                itemBuilder: (BuildContext context, IndexPath index) {
                  final item = model.getItems(index.section)[index.index];
                  var fontTitle = fontTitleOrig;

                  return ListTileTheme(
                      contentPadding: const EdgeInsets.all(0),
                      dense: true,
                      child: model.hasChapters
                          ? Theme(
                              data: ThemeData().copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                  childrenPadding: const EdgeInsets.all(10),
                                  expandedAlignment: Alignment.topLeft,
                                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                                  trailing: const Icon(null),
                                  title: Text(item, style: fontTitle),
                                  children: [
                                    _ChaptersView(BookPosition.modelIndex(model, index), fontTitle)
                                  ]))
                          : ListTile(
                              title: Text(item, style: fontTitle),
                              onTap: () =>
                                  BookPositionNotification(BookPosition.modelIndex(model, index))
                                      .dispatch(context)));
                },
                groupHeaderBuilder: (BuildContext context, int section) =>
                    sections[section].isNotEmpty
                        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(sections[section].toUpperCase(), style: fontLabelOrig),
                            const Divider(thickness: 1)
                          ])
                        : Container(),
                separatorBuilder: (context, index) => const SizedBox(),
                sectionSeparatorBuilder: (context, section) => const SizedBox(height: 15),
              ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: TelegramWebApp.instance.backgroundColor,
        appBar: AppBar(
            elevation: 0.0,
            toolbarHeight: 50.0,
            title: Text(model.title,
                textAlign: TextAlign.left, style: Theme.of(context).textTheme.titleLarge)),
        body: SafeArea(child: Padding(padding: const EdgeInsets.all(15), child: getContent())));
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'book_model.dart';
import 'bible_model.dart';
import 'book_page_single.dart';


class BibleChapterView extends StatefulWidget {
  final BookPosition pos;
  final bool safeBottom;
  const BibleChapterView(this.pos, {required this.safeBottom});

  @override
  _BibleChapterViewState createState() => _BibleChapterViewState();
}

class _BibleChapterViewState extends State<BibleChapterView> {
  BookPosition get pos => widget.pos;

  bool ready = false;
  String title = "";
  late BibleUtil content;

  @override
  void initState() {
    super.initState();

    title = pos.model!.getTitle(pos);

    pos.model!.getContent(pos).then((_result) {
      content = _result;

      setState(() {
        ready = true;
      });
    });
  }

  Widget getContent() =>
      ready ? RichText(text: TextSpan(children: content.getTextSpan(context))) : Container();

  @override
  Widget build(BuildContext context) => BookPageSingle(title,
      bookmark: pos.model!.getBookmark(pos),
      builder: () => getContent(),
      safeBottom: widget.safeBottom);
}

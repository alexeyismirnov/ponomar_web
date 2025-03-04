import 'package:flutter/material.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

import 'globals.dart';
import 'font_size_dialog.dart';
import 'extensions.dart';
import 'config_param.dart';

typedef WidgetCallback = Widget Function();

class BookPageSingle extends StatefulWidget {
  final String title;
  final WidgetCallback builder;
  final double padding;
  final bool safeBottom;
  final bool showActions;
  final String? bookmark;

  const BookPageSingle(this.title,
      {required this.builder,
      this.bookmark,
      this.padding = 15,
      this.safeBottom = true,
      this.showActions = true});

  @override
  _BookPageSingleState createState() => _BookPageSingleState();
}

class _BookPageSingleState extends State<BookPageSingle> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(() => setState(() {}));
  }

  addBookmark() {
    final bookmarks = List<String>.from(ConfigParamExt.bookmarks.val());
    bookmarks.add(widget.bookmark!);
    ConfigParamExt.bookmarks.set(bookmarks);

    setState(() {});
  }

  removeBookmark() {
    final bookmarks = List<String>.from(ConfigParamExt.bookmarks.val());
    bookmarks.remove(widget.bookmark);
    ConfigParamExt.bookmarks.set(bookmarks);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    IconButton? bookmarkButton;

    /*
    if (widget.bookmark != null) {
      if (ConfigParamExt.bookmarks.val().contains(widget.bookmark)) {
        bookmarkButton = IconButton(
            icon: const Icon(Icons.bookmark, size: 30.0), onPressed: () => removeBookmark());
      } else {
        bookmarkButton = IconButton(
            icon: const Icon(Icons.bookmark_outline, size: 30.0), onPressed: () => addBookmark());
      }
    }

     */

    return Scaffold(
        backgroundColor: TelegramWebApp.instance.backgroundColor,
        body: SafeArea(
            bottom: false,
            child: Scrollbar(
                controller: _scrollController,
                child: SafeArea(
                    bottom: widget.safeBottom,
                    child: CustomScrollView(
                        controller: _scrollController,
                        physics: const ClampingScrollPhysics(),
                        slivers: [
                          SliverAppBar(
                            elevation: 0.0,
                            floating: true,
                            toolbarHeight: 50.0,
                            pinned: false,
                            actions: widget.showActions
                                ? [
                                    IconButton(
                                        icon: const Icon(Icons.zoom_in_outlined, size: 30.0),
                                        onPressed: () => FontSizeDialog()
                                            .show(context)
                                            .then((value) => setState(() {}))),
                                    if (bookmarkButton != null) ...[bookmarkButton],
                                  ]
                                : [],
                            title: Text(widget.title,
                                textAlign: TextAlign.left,
                                style: Theme.of(context).textTheme.titleLarge),
                          ),
                          SliverToBoxAdapter(
                              key: ValueKey(ConfigParam.fontSize.val()),
                              child: Padding(
                                  padding: EdgeInsets.all(widget.padding), child: widget.builder()))
                        ])))));
  }
}

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

  bool _isLoading = false;
  bool _isLoaded = false;
  String title = "";
  BibleUtil? content;

  // Static cache to store loaded content across widget instances
  static final Map<String, BibleUtil> _contentCache = {};

  // Unique key for this chapter
  late String _cacheKey;

  @override
  void initState() {
    super.initState();
    title = pos.model!.getTitle(pos);
    _cacheKey = "${pos.model!.code}_${pos.index?.section}_${pos.index?.index}_${pos.chapter}";

    // Check if content is already in cache
    if (_contentCache.containsKey(_cacheKey)) {
      content = _contentCache[_cacheKey];
      _isLoaded = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load content when widget becomes visible, but only if not already loaded or loading
    if (!_isLoaded && !_isLoading) {
      _loadContent();
    }
  }

  void _loadContent() {
    // Set loading flag to prevent multiple simultaneous loads
    _isLoading = true;

    // Load content only if not in cache
    pos.model!.getContent(pos).then((_result) {
      if (mounted) {
        setState(() {
          content = _result;
          // Store in cache for future use
          _contentCache[_cacheKey] = _result;
          _isLoaded = true;
          _isLoading = false;
        });
      }
    });
  }

  Widget _getContent() {
    if (!_isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    return RichText(text: TextSpan(children: content!.getTextSpan(context)));
  }

  @override
  Widget build(BuildContext context) => BookPageSingle(title,
      bookmark: pos.model!.getBookmark(pos),
      builder: () => _getContent(),
      safeBottom: widget.safeBottom);
}

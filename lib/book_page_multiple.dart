import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:group_list_view/group_list_view.dart';

import 'dart:math';

import 'book_model.dart';
import 'bible_model.dart';
import 'book_page_single.dart';
import 'book_cell.dart';
import 'bible_view.dart';

// Global cache for book content to prevent duplicate API calls
class BookContentCache {
  static final Map<String, dynamic> _cache = {};
  static final Map<String, Future<dynamic>> _futures = {};

  static String _getCacheKey(BookPosition pos) {
    return "${pos.model!.code}_${pos.index?.section}_${pos.index?.index}_${pos.chapter}";
  }

  static Future<dynamic> getContent(BookPosition pos) {
    final key = _getCacheKey(pos);

    // If we already have the content cached, return it immediately as a resolved future
    if (_cache.containsKey(key)) {
      return Future.value(_cache[key]);
    }

    // If we have a future in progress, return that
    if (_futures.containsKey(key)) {
      return _futures[key]!;
    }

    // Otherwise, create a new future and cache it
    final future = pos.model!.getContent(pos).then((content) {
      // Store the result in the cache
      _cache[key] = content;
      return content;
    });

    _futures[key] = future;
    return future;
  }
}

class BookPageMultiple extends StatefulWidget {
  final BookPosition pos;

  BookPageMultiple(this.pos);

  @override
  _BookPageMultipleState createState() => _BookPageMultipleState();
}

class _BookPageMultipleState extends State<BookPageMultiple> {
  BookModel get model => widget.pos.model!;
  BookPosition get pos => widget.pos;

  List<BookPosition> bookPos = [];
  late int currentIndex;
  int totalChapters = 0;

  // PageController instead of TabController for more control
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    BookPosition? curPos = (model.hasChapters)
        ? BookPosition.modelIndex(model, pos.index!, chapter: 0)
        : BookPosition.modelIndex(model, pos.index);

    do {
      bookPos.add(curPos!);

      if (curPos == pos) {
        currentIndex = totalChapters;
      }

      totalChapters++;
      curPos = model.getNextSection(curPos);
    } while (curPos != null);

    _pageController = PageController(initialPage: currentIndex);

    // Only prefetch the initial content
    BookContentCache.getContent(bookPos[currentIndex]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Calculate the position for the dots indicator
  int getDotsPosition(int currentIndex) {
    final int maxDots = 10;

    if (totalChapters <= maxDots) {
      return currentIndex;
    } else {
      if (currentIndex < maxDots / 2) {
        return currentIndex;
      } else if (currentIndex >= totalChapters - maxDots / 2) {
        return maxDots - (totalChapters - currentIndex);
      } else {
        return (maxDots / 2).round();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int maxDots = 10;
    final int dotsCount = min(totalChapters, maxDots);

    return Scaffold(
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: PageView.builder(
          controller: _pageController,
          itemCount: totalChapters,
          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });

            // Prefetch adjacent pages when page changes
            if (index > 0) {
              BookContentCache.getContent(bookPos[index - 1]);
            }
            if (index < totalChapters - 1) {
              BookContentCache.getContent(bookPos[index + 1]);
            }
          },
          itemBuilder: (context, index) {
            // Only build pages that are visible or adjacent
            if (index == currentIndex || index == currentIndex - 1 || index == currentIndex + 1) {
              return _buildPageContent(index);
            } else {
              // Return a placeholder for non-visible pages
              return Container(color: Theme.of(context).scaffoldBackgroundColor);
            }
          },
        ),
      ),
      if (totalChapters > 1) ...[
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: DotsIndicator(
              dotsCount: dotsCount,
              position: min(dotsCount - 1, max(0, getDotsPosition(currentIndex))),
              decorator: const DotsDecorator(
                color: Colors.grey, // Inactive color
                activeColor: Colors.grey,
              ),
            ),
          ),
        )
      ]
    ]));
  }

  Widget _buildPageContent(int index) {
    if (model is BibleModel) {
      return BibleChapterView(bookPos[index], safeBottom: totalChapters == 1);
    } else {
      return FutureBuilder<dynamic>(
          future: BookContentCache.getContent(bookPos[index]),
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            String title = model.getTitle(bookPos[index]);
            var text = snapshot.data;

            if (model.contentType == BookContentType.html) {
              return BookPageSingle(title,
                  bookmark: model.getBookmark(bookPos[index]),
                  builder: () => BookCellHTML(text, model),
                  padding: 5,
                  safeBottom: totalChapters == 1);
            } else {
              return BookPageSingle(title,
                  bookmark: model.getBookmark(bookPos[index]),
                  builder: () => BookCellText(text),
                  safeBottom: totalChapters == 1);
            }
          });
    }
  }
}

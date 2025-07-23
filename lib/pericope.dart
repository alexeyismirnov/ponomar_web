import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ponomar_web/bible_model.dart';

import 'book_page_single.dart';
import 'globals.dart';
import 'config_param.dart';
import 'custom_list_tile.dart';
import 'pericope_model.dart';
import 'extensions.dart';
import 'clipboard.dart';

class PericopeView extends StatefulWidget {
  final String str;
  const PericopeView(this.str, {super.key});

  @override
  _PericopeViewState createState() => _PericopeViewState();
}

class _PericopeViewState extends State<PericopeView> {
  // Add a future field to store the result
  Future<List<dynamic>>? _pericopeFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize the future only once
    _pericopeFuture ??=
        PericopeModel(context.countryCode, widget.str).getPericope(PericopeFormat.widget);
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = ConfigParam.fontSize.val();
    final family = Theme.of(context).textTheme.bodyLarge!.fontFamily!;

    return FutureBuilder<List<dynamic>>(
        future: _pericopeFuture,
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("network error"));
          }
          if (snapshot.hasData) {
            List<Widget> content = [];

            for (List<dynamic> values in snapshot.data!) {
              var title = values[0] as String;
              content.add(Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: RichText(
                      text: TextSpan(
                          text: "$title\n",
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold, fontFamily: family, fontSize: fontSize)),
                      textAlign: TextAlign.center,
                    ))
                  ]));

              var bu = values[1] as BibleUtil;
              content.add(CopyToClipboard(bu.getText(),
                  child: RichText(text: TextSpan(children: bu.getTextSpan(context)))));
            }

            return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: content);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}

class ReadingView extends StatefulWidget {
  final String r;
  const ReadingView(this.r);

  @override
  _ReadingViewState createState() => _ReadingViewState();
}

class _ReadingViewState extends State<ReadingView> {
  late String title;
  late String? subtitle;
  late List<String> currentReading;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    currentReading = widget.r.split("#");
    title = JSON.translateReading(currentReading[0], lang: context.countryCode);
    subtitle = currentReading.length > 1 ? currentReading[1].trim().tr() : null;
  }

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: CustomListTile(
          title: title,
          subtitle: subtitle,
          onTap: () => BookPageSingle("Reading of the day".tr(),
              builder: () => PericopeView(currentReading[0])).push(context)));
}

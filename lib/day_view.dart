import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'church_day.dart';
import 'card_view.dart';
import 'globals.dart';
import 'church_calendar.dart';
import 'church_fasting.dart';
import 'book_cell.dart';
import 'saint_model.dart';
import 'icon_model.dart';
import 'extensions.dart';
import 'calendar_selector.dart';
import 'church_reading.dart';
import 'pericope.dart';
import 'feofan.dart';
import 'troparion_model.dart';
import 'taushev.dart';
import 'zerna.dart';
import 'saints_lives.dart';
import 'clipboard.dart';

class _FeastWidget extends StatelessWidget {
  final ChurchDay d;
  final TextStyle? style;
  final bool translate;

  const _FeastWidget(this.d, {this.style, this.translate = true});

  @override
  Widget build(BuildContext context) {
    if (d.type == FeastType.great) {
      return Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(children: [
            SvgPicture.asset("assets/images/great.svg", height: 30),
            const SizedBox(width: 10),
            Expanded(
                child: Text(translate ? d.name.tr() : d.name,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.red)))
          ]));
    } else {
      var textStyle =
          style ?? Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w500);

      if (d.type.name != "none") {
        Color signColor = Colors.red;
        if (d.type == FeastType.noSign || d.type == FeastType.sixVerse) {
          signColor = Theme.of(context).textTheme.titleMedium!.color!;
        }

        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
            child: RichText(
                text: TextSpan(children: [
              WidgetSpan(
                  child: SvgPicture.asset("assets/images/${d.type.name.toLowerCase()}.svg",
                      color: signColor, height: 15)),
              TextSpan(text: translate ? d.name.tr() : d.name, style: textStyle)
            ])));
      } else {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
            child: Text(translate ? d.name.tr() : d.name, style: textStyle));
      }
    }
  }
}

class DayView extends StatefulWidget {
  final DateTime date, dateOld;

  DayView({Key? key, required this.date})
      : dateOld = date.subtract(const Duration(days: 13)),
        super(key: key);

  @override
  _DayViewState createState() => _DayViewState();
}

class _DayViewState extends State<DayView> with AutomaticKeepAliveClientMixin {
  DateTime get date => widget.date;
  DateTime get dateOld => widget.dateOld;

  late Cal cal;

  late List<SaintIcon> icons = [];
  late int pageSize;
  late PageController _controller;
  final ScrollController _scrollController = ScrollController();

  final space10 = const SizedBox(height: 10);
  final space5 = const SizedBox(height: 5);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    cal = Cal.fromDate(date);
    _controller = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    const itemWidth = 100;
    const padding = 10;

    pageSize = (MediaQuery.of(context).size.width - 4 * padding) ~/ (itemWidth + 10);
  }

  Widget getDate() {
    final df1 = DateFormat.yMMMMEEEEd(context.languageCode);
    final df2 = DateFormat.yMMMMd(context.languageCode);

    var dateWidget = GestureDetector(
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Icon(Icons.calendar_today, size: 30.0),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                    AutoSizeText(df1.format(date).capitalize(),
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        minFontSize: 5,
                        style: Theme.of(context).textTheme.titleLarge),
                    AutoSizeText("${df2.format(dateOld)} ${"old_style".tr()}",
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        minFontSize: 5,
                        style: Theme.of(context).textTheme.titleMedium),
                  ]))
            ]),
        onTap: () {
          CalendarSelector(date).show(context).then((newDate) {
            if (newDate != null) {
              DateChangedNotification(newDate).dispatch(context);
            }
          });
        });

    return dateWidget;
  }

  Widget getDescription() {
    var list = [cal.getWeekDescription(date), cal.getToneDescription(date)];
    var weekDescr = list.whereType<String>().join('; ');
    var dayDescr = cal.getDayDescription(date);
    // var greatFeasts = Cal.getGreatFeast(date);

    List<Widget> feastWidgets = dayDescr.map((d) => _FeastWidget(d)).toList();

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: (weekDescr.isNotEmpty
                ? <Widget>[Text(weekDescr, style: Theme.of(context).textTheme.titleMedium)]
                : <Widget>[]) +
            feastWidgets);
  }

  Widget getFasting() => FutureBuilder<FastingModel>(
      future: ChurchFasting.forDate(date, context.languageCode),
      builder: (BuildContext context, AsyncSnapshot<FastingModel> snapshot) {
        if (snapshot.hasData) {
          final fasting = snapshot.data!;

          List<InlineSpan> spans = [
            TextSpan(
                text: "${fasting.description.tr()}  ",
                style: Theme.of(context).textTheme.titleMedium)
          ];

          String? comment = JSON.fastingComments[context.countryCode]![fasting.description];

          if (comment != null) {
            spans.add(const WidgetSpan(
              child: Icon(Icons.article_outlined, size: 25.0, color: Colors.red),
            ));
          }

          return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (comment != null) PopupComment(comment).show(context);
              },
              child: Row(children: [
                SvgPicture.asset("assets/images/${fasting.type.icon}", height: 30),
                const SizedBox(width: 10),
                Expanded(child: RichText(text: TextSpan(children: spans)))
              ]));
        } else {
          return Container();
        }
      });

  Widget getIcons() => FutureBuilder<List<SaintIcon>>(
      future: IconModel.fetch(date),
      builder: (BuildContext context, AsyncSnapshot<List<SaintIcon>> snapshot) {
        if (snapshot.hasData) {
          if (icons.isEmpty) {
            icons = List<SaintIcon>.from(snapshot.data!);
          }

          Widget iconPage(int page) {
            final newItems =
                icons.sublist(page * pageSize, min((page + 1) * pageSize, icons.length));

            final pageNotFull = page > 0 && (page + 1) * pageSize > icons.length;

            return Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment:
                    pageNotFull ? MainAxisAlignment.start : MainAxisAlignment.spaceAround,
                children: [
                  if (!pageNotFull) ...[const Spacer()],
                  ...newItems
                      .map<Widget>((s) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                          child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                if (context.languageCode == 'ru' && s.name.isNotEmpty) {
                                  PopupComment(s.name).show(context);
                                }
                              },
                              child: Image.asset(
                                'assets/icons/${s.id}.jpg',
                                height: 110.0,
                                fit: BoxFit.contain,
                              ))))
                      .toList(),
                  if (!pageNotFull) ...[const Spacer()],
                ]);
          }

          return Container(
              margin: const EdgeInsets.symmetric(vertical: 20.0),
              height: 120.0,
              child: PageView.builder(
                  controller: _controller,
                  itemCount: (icons.length - 1) ~/ pageSize + 1,
                  itemBuilder: (BuildContext context, int index) => iconPage(index)));
        } else {
          return Container();
        }
      });

  Future<List<Saint>> fetchSaints(DateTime d) async {
    final url = "https://$hostURL/saints/${context.countryCode}/${d.day}/${d.month}/${d.year}";

    try {
      final r = await http.get(Uri.parse(url));

      if (r.statusCode == 200) {
        final data = utf8.decode(r.bodyBytes);
        return (jsonDecode(data) as List<dynamic>).map<Saint>((b) => Saint.fromJson(b)).toList();
      } else {
        throw Exception('Failed to load ');
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Widget getReading() {
    final reading = ChurchReading.forDate(date);
    List<Widget> content = [];

    for (final r in reading) {
      content.add(ReadingView(r));
    }

    if (context.languageCode != "zh") {
      content.add(FeofanView(date));
      content.add(SaintsLivesView(date));
    }

    if (context.languageCode == "ru") {
      if (date.weekday == DateTime.sunday) {
        for (final r in reading) {
          content.add(TaushevView(r));
        }
      }

      if (Cal.getGreatFeast(date).isEmpty &&
          date.weekday != DateTime.sunday &&
          reading.length == 1) {
        content.add(ZernaView(date));
      }
    }

    if (context.languageCode != "zh") {
      content.add(const SizedBox(height: 5));
      content.add(TroparionWidget(date));
    }

    return CardWithTitle(
        title: "Reading of the day",
        content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: content));
  }

  Widget getSaints() => FutureBuilder<List<Saint>>(
      future: fetchSaints(date),
      builder: (BuildContext context, AsyncSnapshot<List<Saint>> snapshot) {
        if (snapshot.hasData) {
          return CardWithTitle(
              title: "Memory of saints",
              content: CopyToClipboard(
                  List<Saint>.from(snapshot.data!).map((s) => s.name).join("\n"),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List<Saint>.from(snapshot.data!)
                          .map((s) => _FeastWidget(ChurchDay.fromSaint(s),
                              style: Theme.of(context).textTheme.titleMedium, translate: false))
                          .toList())));
        } else {
          return Container();
        }
      });

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return SingleChildScrollView(
        controller: _scrollController,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardWithTitle(
                  title: "",
                  content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getDate(),
                        space10,
                        getDescription(),
                        space10,
                        getFasting(),
                        space10,
                        getIcons()
                      ])),
              space10,
              getReading(),
              space10,
              getSaints()
            ]));
  }
}

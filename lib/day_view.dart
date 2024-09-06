import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'church_day.dart';
import 'card_view.dart';
import 'globals.dart';

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
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
            child: RichText(
                text: TextSpan(children: [
              WidgetSpan(
                  child: SvgPicture.asset("assets/images/${d.type.name.toLowerCase()}.svg",
                      height: 15)),
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

class _DayViewState extends State<DayView> {
  DateTime get date => widget.date;
  DateTime get dateOld => widget.dateOld;

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
          /*
          CalendarSelector(date).show(context).then((newDate) {
            if (newDate != null) {
              DateChangedNotification(newDate).dispatch(context);
            }
          });

           */
        });

    return dateWidget;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                  ]))
        ]));
  }
}

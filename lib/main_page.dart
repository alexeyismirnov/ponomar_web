import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

import 'globals.dart';
import 'day_view.dart';
import 'extensions.dart';

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> with WidgetsBindingObserver {
  int initialPage = 100000;

  late DateTime date;
  late PageController _controller;

  @override
  void initState() {
    super.initState();

    _controller = PageController(initialPage: initialPage);
    setDate(DateTime.now());

    WidgetsBinding.instance.addObserver(this);

    Future.delayed(Duration.zero, () => postInit());
  }

  void postInit() async {
    await Jiffy.setLocale(context.languageCode);
  }

  void setDate(DateTime d) {
    setState(() {
      date = DateTime.utc(d.year, d.month, d.day);
      if (_controller.hasClients) {
        initialPage = _controller.page!.round();
      }
    });
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => [],
          body: Padding(
              padding: const EdgeInsets.all(10),
              child: PageView.builder(
                controller: _controller,
                itemBuilder: (BuildContext context, int index) {
                  final currentDate = date.add(Duration(days: index - initialPage));
                  return NotificationListener<Notification>(
                      onNotification: (n) {
                        if (n is DateChangedNotification) setDate(n.newDate);
                        return true;
                      },
                      child: DayView(key: ValueKey(currentDate), date: currentDate));
                },
              ))));
}

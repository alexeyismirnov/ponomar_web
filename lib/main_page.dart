import 'package:flutter/material.dart';


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
  }

  Widget getContent() {
    return const Center(child: Text("Main page"));
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => [],
          body: Padding(padding: const EdgeInsets.all(15), child: getContent())));
}

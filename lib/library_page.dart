import 'package:flutter/material.dart';

class LibraryPage extends StatefulWidget {
  @override
  LibraryPageState createState() => LibraryPageState();
}

class LibraryPageState extends State<LibraryPage> {
  Widget getContent() {
    return const Center(child: Text("Library page"));
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => [],
          body: Padding(padding: const EdgeInsets.all(15), child: getContent())));
}

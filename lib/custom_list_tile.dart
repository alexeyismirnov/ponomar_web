import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final double padding;
  final bool reversed;
  final String? lang;

  CustomListTile(
      {required this.title,
      required this.onTap,
      this.subtitle,
      this.lang,
      this.padding = 5,
      this.reversed = false});

  @override
  Widget build(BuildContext context) {
    var font = Theme.of(context).textTheme.titleLarge!;

    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
            padding: EdgeInsets.only(bottom: padding),
            child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                      child: (subtitle?.length ?? 0) == 0
                          ? Text(title, textAlign: TextAlign.left, style: font)
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: reversed
                                  ? <Widget>[
                                      Text(subtitle!,
                                          textAlign: TextAlign.left,
                                          style: Theme.of(context).textTheme.titleMedium!),
                                      Text(title,
                                          textAlign: TextAlign.left,
                                          style: Theme.of(context).textTheme.titleLarge),
                                    ]
                                  : <Widget>[
                                      Text(title,
                                          textAlign: TextAlign.left,
                                          style: Theme.of(context).textTheme.titleLarge),
                                      Text(subtitle!,
                                          textAlign: TextAlign.left,
                                          style: Theme.of(context).textTheme.titleMedium!),
                                    ]))
                ])));
  }
}

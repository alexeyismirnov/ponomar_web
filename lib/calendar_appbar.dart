import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'globals.dart';
import 'church_fasting.dart';
import 'restart_widget.dart';

class SelectorDialog extends StatelessWidget {
  final String title;
  final List<Widget> content;

  SelectorDialog({required this.title, required this.content});

  @override
  Widget build(BuildContext context) => AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
      contentPadding: const EdgeInsets.all(5.0),
      content: Container(
          // width: context.screenWidth * 0.5,
          padding: const EdgeInsets.all(10.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                    Container(
                        padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
                        child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(title.tr().toUpperCase(),
                                  style: Theme.of(context).textTheme.labelLarge)
                            ])),
                  ] +
                  content)));
}

class FastingLevelDialog extends StatelessWidget {
  final labels = ['laymen_fasting', 'monastic_fasting'];

  Widget _getListItem(BuildContext context, int index) {
    return CheckboxListTile(
        title: Text(labels[index]).tr(),
        value: ConfigParamExt.fastingLevel.val() == index,
        onChanged: (_) {
          ConfigParamExt.fastingLevel.set(index);
          ChurchFasting.fastingLevel = FastingLevel.values[index];
          RestartWidget.restartApp(context);
        });
  }

  @override
  Widget build(BuildContext context) => SelectorDialog(title: 'fasting_level', content: [
        _getListItem(context, 0),
        _getListItem(context, 1),
      ]);
}

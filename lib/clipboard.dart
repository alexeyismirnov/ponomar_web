import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyToClipboard extends StatelessWidget {
  final String text;
  final Widget child;

  const CopyToClipboard(this.text, {required this.child});

  @override
  Widget build(BuildContext context) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: text));

        const snackBar = SnackBar(
          content: Text('Скопировано в буфер обмена'),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      child: child);
}

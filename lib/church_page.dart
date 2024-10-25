import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';

import 'clipboard.dart';

class ChurchPage extends StatefulWidget {
  @override
  _ChurchPageState createState() => _ChurchPageState();
}

class _ChurchPageState extends State<ChurchPage> {
  @override
  void initState() {
    super.initState();
  }

  List<Widget> getContent() {
    final col = Theme.of(context).textTheme.bodyMedium!.color!;

    return [
      Row(mainAxisSize: MainAxisSize.max, children: [
        Expanded(
            child: Text("church_hk".tr(),
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge)),
      ]),
      const SizedBox(height: 15),
      Text("church_info".tr(), style: Theme.of(context).textTheme.bodyMedium),
      Text("please_make_donation".tr(), style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 25),
      SvgPicture.asset("assets/images/ton_wallet.svg", height: 200, color: col),
      const SizedBox(height: 25),
      CopyToClipboard("UQDgCVp1j_4Pi8-2AYvAX5E9YmqsQDiJmhRV7AZ8B9l85Hhl",
          child: Row(mainAxisSize: MainAxisSize.max, children: [
            Expanded(
                child: Text("UQDgCVp1j_4Pi8-2AYvAX5E9YmqsQDiJmhRV7AZ8B9l85Hhl",
                    textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge)),
          ])),
    ];
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      child: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: CustomScrollView(slivers: <Widget>[
                SliverPadding(
                    padding: const EdgeInsets.all(15),
                    sliver: SliverList(delegate: SliverChildListDelegate(getContent())))
              ]))));
}

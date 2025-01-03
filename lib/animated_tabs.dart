import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:easy_localization/easy_localization.dart' as EL;

import 'calendar_appbar.dart';
import 'extensions.dart';

class AnimatedTab {
  final Widget icon;
  final String title;
  final Widget content;

  AnimatedTab({required this.icon, required this.title, required this.content});
}

class _AnimatedTabView {
  final AnimatedTab tab;
  final BottomNavigationBarItem item;
  final AnimationController controller;
  late CurvedAnimation _animation;

  _AnimatedTabView({
    required this.tab,
    required TickerProvider vsync,
  })  : item = BottomNavigationBarItem(
          icon: tab.icon,
          label: tab.title.tr(),
        ),
        controller = AnimationController(
          duration: kThemeAnimationDuration,
          vsync: vsync,
        ) {
    _animation = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );
  }

  FadeTransition transition(BuildContext context) {
    return FadeTransition(
      key: ValueKey(tab.title),
      opacity: _animation,
      child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.02), // Slightly down.
            end: Offset.zero,
          ).animate(_animation),
          child: tab.content),
    );
  }
}

class ContainerPage extends StatefulWidget {
  final List<AnimatedTab> tabs;
  final int highlight;
  ContainerPage({required this.tabs, this.highlight = -1});

  @override
  ContainerPageState createState() => ContainerPageState();
}

class ContainerPageState extends State<ContainerPage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late List<_AnimatedTabView> _navigationViews;
  List<FadeTransition> transitions = [];
  SettingsButton get settingsButton => TelegramWebApp.instance.settingButton;

  @override
  void initState() {
    super.initState();

    _navigationViews = widget.tabs.map((t) => _AnimatedTabView(tab: t, vsync: this)).toList();

    for (_AnimatedTabView view in _navigationViews) {
      view.controller.addListener(() => setState(() {}));
    }

    _navigationViews[_currentIndex].controller.value = 1.0;

    for (_AnimatedTabView view in _navigationViews) {
      transitions.add(view.transition(context));
    }

    settingsButton.show();
    settingsButton.onClick(showSettings);
  }

  @override
  void dispose() {
    super.dispose();

    for (_AnimatedTabView view in _navigationViews) {
      view.controller.dispose();
    }

    settingsButton.hide();
    settingsButton.offClick(showSettings);
  }

  Widget _buildTransitionsStack() {
    // We want to have the newly animating (fading in) views on top.
    transitions.sort((FadeTransition a, FadeTransition b) {
      final Animation<double> aAnimation = a.opacity;
      final Animation<double> bAnimation = b.opacity;
      final double aValue = aAnimation.value;
      final double bValue = bAnimation.value;
      return aValue.compareTo(bValue);
    });

    return Stack(children: transitions);
  }

  void update(int index) => setState(() {
        _navigationViews[_currentIndex].controller.reverse();
        _currentIndex = index;
        _navigationViews[_currentIndex].controller.forward();
      });

  @override
  Widget build(BuildContext context) {
    final botNavBar = Container(
        color: Colors.transparent,
        child: widget.highlight == -1
            ? BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                backgroundColor: Colors.transparent,
                currentIndex: _currentIndex,
                items: _navigationViews.map((navigationView) => navigationView.item).toList(),
                onTap: update)
            : BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.red,
                currentIndex: widget.highlight,
                elevation: 0,
                backgroundColor: Colors.transparent,
                items: _navigationViews.map((navigationView) => navigationView.item).toList(),
                onTap: update));

    return Container(
        color: TelegramWebApp.instance.backgroundColor,
        child: SafeArea(
            minimum: const EdgeInsets.only(bottom: 10),
            child: Scaffold(
                body: Center(child: _buildTransitionsStack()), bottomNavigationBar: botNavBar)));
  }

  void showSettings() {
    FastingLevelDialog().show(context);
  }
}

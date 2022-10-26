import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:system_info2/system_info2.dart';
import 'package:unicons/unicons.dart';
import 'package:vs_droid/inner_drawer.dart';
import 'package:vs_droid/left_quick_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<InnerDrawerState> _innerDrawerKey =
      GlobalKey<InnerDrawerState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return InnerDrawer(
      key: _innerDrawerKey,
      onTapClose: true,
      swipe: false,
      boxShadow: const [],
      colorTransitionChild: Colors.transparent,
      colorTransitionScaffold: Colors.transparent,
      offset: const IDOffset.only(top: 0.2, right: 0, left: 0),
      scale: const IDOffset.horizontal(0.9),
      proportionalChildArea: true,
      borderRadius: 8,
      leftAnimationType: InnerDrawerAnimation.quadratic,
      rightAnimationType: InnerDrawerAnimation.quadratic,
      backgroundDecoration: const BoxDecoration(color: Colors.white),
      leftChild: const LeftQuickBar(),
      scaffold: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: CupertinoPageScaffold(
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              const WebView(
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl: 'https://flutter.dev',
              ),
              Positioned(
                top: 25,
                left: 20,
                child: GestureDetector(
                  onTap: () {
                    _innerDrawerKey.currentState?.open();
                  },
                  child: const Icon(
                    UniconsLine.bars,
                    color: Colors.lightBlue,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

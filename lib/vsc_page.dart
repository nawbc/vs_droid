import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vs_droid/inner_drawer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VscPage extends StatefulWidget {
  const VscPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VscPageState();
  }
}

class _VscPageState extends State<VscPage> {
  final GlobalKey<InnerDrawerState> _innerDrawerKey = GlobalKey<InnerDrawerState>();

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
    // ignore: prefer_const_constructors
    return WebView(
      javascriptMode: JavascriptMode.unrestricted,
      initialUrl: 'https://flutter.dev',
    );
  }
}

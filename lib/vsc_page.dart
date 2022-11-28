import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vs_droid/constant.dart';
import 'package:vs_droid/theme_model.dart';
import 'package:vs_droid/utils.dart';
import 'package:wakelock/wakelock.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'config_model.dart';
import 'droid_pty.dart';

class VscPage extends StatefulWidget {
  const VscPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VscPageState();
  }
}

class _VscPageState extends State<VscPage> {
  late VSDroidPty _pty;
  late ConfigModel _cm;
  late ThemeModel _tm;
  late bool _init;

  @override
  void initState() {
    super.initState();
    _init = false;
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  void dispose() {
    super.dispose();
    _pty.kill();
    Wakelock.disable();
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    _cm = Provider.of<ConfigModel>(context);
    _tm = Provider.of<ThemeModel>(context);
    _pty = VSDroidPty(
      _cm.termuxUsr.path,
    );
    if (!await Wakelock.enabled) {
      Wakelock.enable();
    }
    try {
      log("Vsc Page Init: $_init");
      if (!_init) {
        await _pty.startCodeServer(
          name: _cm.currentRootfsId!,
        );

        setState(() {
          _init = true;
        });
      }
    } catch (e) {
      log("Code Server: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    log("============================================");
    return SafeArea(
      child: _init
          ? WebView(
              javascriptMode: JavascriptMode.unrestricted,
              initialUrl: LOCAL_CODE_SERVER_ADDR,
              onWebResourceError: (WebResourceError error) {},
            )
          : Container(color: _tm.themeData.scaffoldBackgroundColor),
    );
  }
}

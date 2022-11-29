import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:vs_droid/theme_model.dart';
import 'package:wakelock/wakelock.dart';

import 'config_model.dart';
import 'constant.dart';
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
        await Future.delayed(const Duration(milliseconds: 500));
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
          ? InAppWebView(
              initialSettings: InAppWebViewSettings(
                useHybridComposition: true,
                iframeAllowFullscreen: true,
              ),
              initialUrlRequest: URLRequest(url: WebUri("http://$LOCAL_CODE_SERVER_ADDR")),
            )
          : Container(color: _tm.themeData.scaffoldBackgroundColor),
    );
  }
}

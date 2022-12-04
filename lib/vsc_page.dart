import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vs_droid/theme_model.dart';
import 'package:wakelock/wakelock.dart';
// import 'package:webview_flutter/webview_flutter.dart';
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
  VSDroidPty? _pty;
  late ConfigModel _cm;
  late ThemeModel _tm;
  late bool _init;

  @override
  void initState() {
    super.initState();
    _init = false;
    WebView.debugLoggingSettings.enabled = true;
    // if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  void dispose() {
    super.dispose();
    _pty?.kill();
    Wakelock.disable();
  }

//   startServer() async {
//     _pty?.kill();
//     _pty = null;

//     await Future.delayed(const Duration(milliseconds: 100));

//     _pty = VSDroidPty(
//       _cm.termuxUsr.path,
//     );
//     _pty?.output.cast<List<int>>().transform(const Utf8Decoder()).listen((data) async {
//       log(data);
//       if (data.contains(RegExp("$LOCAL_CODE_SERVER_URL|EADDRINUSE"))) {
//         setState(() {
//           _init = true;
//         });
//       }
//     });

//     _pty?.exec("""
// proot-distro login ${_cm.currentRootfsId}
// code-server --auth none --bind-addr $LOCAL_CODE_SERVER_ADDR
// """);
//   }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    _cm = Provider.of<ConfigModel>(context);
    _tm = Provider.of<ThemeModel>(context);
    if (!await Wakelock.enabled) {
      Wakelock.enable();
    }

    _pty = VSDroidPty(
      _cm.termuxUsr.path,
    );
    try {
      log("Vsc Page Init: $_init");
      if (!_init) {
        await _pty?.startCodeServer(
          name: _cm.currentRootfsId!,
        );
        await Future.delayed(const Duration(milliseconds: 300));

        setState(() {
          _init = true;
        });

        await launchUrl(Uri.parse(LOCAL_CODE_SERVER_URL), mode: LaunchMode.inAppWebView);
      }
    } catch (e) {
      log("Code Server: $e");
    }
  }

  handleKey(dynamic e) {
    log("$e");
  }

  final FocusNode _focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

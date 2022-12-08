import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vs_droid/quick_settings.dart';
import 'package:wakelock/wakelock.dart';
import 'config_model.dart';
import 'droid_pty.dart';
import 'utils.dart';

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
  late bool _init;

  @override
  void initState() {
    super.initState();
    _init = false;
  }

  @override
  void dispose() {
    super.dispose();
    _pty?.kill();
    Wakelock.disable();
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    _cm = Provider.of<ConfigModel>(context);
    if (!await Wakelock.enabled) {
      Wakelock.enable();
    }

    if (!_init) {
      _pty?.kill();
      // _pty = await launchCodeServerStage(_cm.termuxUsr.path, _cm.currentRootfsId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // return InAppWebView(
    //   initialSettings:
    //       InAppWebViewSettings(useHybridComposition: true, iframeAllowFullscreen: true, hardwareAcceleration: true),
    //   initialUrlRequest: URLRequest(url: WebUri("http://$LOCAL_CODE_SERVER_ADDR")),
    // );
    return Container(
      color: Colors.white,
    );
  }
}

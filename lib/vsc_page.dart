import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';
import 'config_model.dart';
import 'constant.dart';
import 'droid_pty.dart';
import 'stage_plugin.dart';

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
        Stage.launch(Uri.parse(LOCAL_CODE_SERVER_URL));
      }
    } catch (e) {
      log("Code Server: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

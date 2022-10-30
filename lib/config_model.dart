import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:vs_droid/constant.dart';
import 'package:vs_droid/store.dart';

class ConfigModel extends ChangeNotifier {
  late Directory _filesDir;
  Directory get filesDir => _filesDir;

  late Directory _termuxUsrDir;
  Directory get termuxUsrDir => _termuxUsrDir;

  late Directory _termuxBinDir;
  Directory get termuxBinDir => _termuxBinDir;

  late Directory _termuxHomeDir;
  Directory get termuxHomeDir => _termuxHomeDir;

  late bool _isAppInit;
  bool get isAppInit => _isAppInit;

  late String _internalIP;
  String? get internalIP => _internalIP;

  // Export Code Server to Lan
  late String _serverPort;
  String get serverPort => _serverPort;

  void setServerPort(String port) {
    _serverPort = port;
  }

  void setInternalIP(String arg) {
    _internalIP = arg;
  }

  Future<void> setAppInit(bool arg) async {
    _isAppInit = arg;
    await Store.setBool(IS_APP_INIT, arg);
    notifyListeners();
  }

  Future<void> init() async {
    try {
      _isAppInit = await Store.getBool("is_app_init") ?? false;
      _serverPort = await Store.getString("server_port") ?? "20771";
      _filesDir = Directory("/data/data/com.deskbtm.vs_droid/files");
      _termuxUsrDir = Directory("${_filesDir.path}/usr");
      _termuxBinDir = Directory("${_filesDir.path}/usr/bin");
      _termuxHomeDir = Directory("${_filesDir.path}/home");
    } catch (e, s) {
      await Sentry.captureException(
        e,
        stackTrace: s,
      );
    }
  }
}

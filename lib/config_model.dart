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

  late bool _terminalQuakeMode;
  bool get terminalQuakeMode => _terminalQuakeMode;
  Future<void> setTerminalQuakeMode(bool mode) async {
    _terminalQuakeMode = mode;
    await Store.setBool(TERMINAL_QUAKE_MODE, mode);
  }

  // Export Code Server to Lan
  late String _serverPort;
  String get serverPort => _serverPort;

  Future<void> setServerPort(String port) async {
    _serverPort = port;
    await Store.setString(SERVER_PORT, port);
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
      _terminalQuakeMode = await Store.getBool(TERMINAL_QUAKE_MODE) ?? false;
      _isAppInit = await Store.getBool(IS_APP_INIT) ?? false;
      _serverPort = await Store.getString(SERVER_PORT) ?? "20771";
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

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:vs_droid/constant.dart';
import 'package:vs_droid/store.dart';

class ConfigModel extends ChangeNotifier {
  late Directory _filesDir;
  Directory get filesDir => _filesDir;

  late Directory _termuxUsr;
  Directory get termuxUsr => _termuxUsr;

  late Directory _termuxBin;
  Directory get termuxBin => _termuxBin;

  late Directory _termuxHome;
  Directory get termuxHome => _termuxHome;

  late bool _isAppInit;
  bool get isAppInit => _isAppInit;
  Future<void> setAppInit(bool arg) async {
    _isAppInit = arg;
    await Store.setBool(IS_APP_INIT, arg);
    notifyListeners();
  }

  late bool _haveReadUsage;
  bool get haveReadUsage => _haveReadUsage;

  Future<void> setReadUsage(bool arg) async {
    _haveReadUsage = arg;
    await Store.setBool(HAVE_READ_USAGE, arg);
  }

  late String _internalIP;
  String? get internalIP => _internalIP;

  void setInternalIP(String arg, {bool notify = false}) {
    _internalIP = arg;
    if (notify) {
      notifyListeners();
    }
  }

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

  Future<void> init() async {
    try {
      _terminalQuakeMode = await Store.getBool(TERMINAL_QUAKE_MODE) ?? false;
      _haveReadUsage = await Store.getBool(HAVE_READ_USAGE) ?? false;
      _isAppInit = await Store.getBool(IS_APP_INIT) ?? false;
      _serverPort = await Store.getString(SERVER_PORT) ?? "20771";
      _filesDir = Directory("/data/data/com.deskbtm.vs_droid/files");
      _termuxUsr = Directory("${_filesDir.path}/usr");
      _termuxBin = Directory("$_termuxUsr/bin");
      _termuxHome = Directory("${_filesDir.path}/home");
    } catch (e, s) {
      await Sentry.captureException(
        e,
        stackTrace: s,
      );
    }
  }
}

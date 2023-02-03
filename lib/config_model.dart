import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:vs_droid/constant.dart';
import 'package:vs_droid/store.dart';

class ConfigModel extends ChangeNotifier {
  void flush() {
    notifyListeners();
  }

  late Directory _filesDir;
  Directory get filesDir => _filesDir;

  late Directory _termuxUsr;
  Directory get termuxUsr => _termuxUsr;

  late Directory _termuxBin;
  Directory get termuxBin => _termuxBin;

  late Directory _termuxHome;
  Directory get termuxHome => _termuxHome;

  late bool _isCodeServerInited;
  bool get isCodeServerInited => _isCodeServerInited;

  Future<void> setCodeServerInit(bool arg) async {
    _isCodeServerInited = arg;
    await Store.setBool(IS_CODE_SERVER_INIT, arg);
    notifyListeners();
  }

  late bool _haveReadUsage;
  bool get haveReadUsage => _haveReadUsage;

  Future<void> setReadUsage(bool arg) async {
    _haveReadUsage = arg;
    await Store.setBool(HAVE_READ_USAGE, arg);
  }

  late String _internalIP;
  String get internalIP => _internalIP;

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

  String? _currentRootfsId;
  String? get currentRootfsId => _currentRootfsId;

  Future<void> setCurrentRootfsId(String id) async {
    _currentRootfsId = id;
    await Store.setString(CURRENT_ROOTFS_ID, id);
  }

  late String _appIcon;
  String get appIcon => _appIcon;

  Future<void> setAppIcon(String icon) async {
    _appIcon = icon;
    await Store.setString(APP_ICON, icon);
  }

  Future<void> init() async {
    try {
      _internalIP = META_ADDR;
      _terminalQuakeMode = await Store.getBool(TERMINAL_QUAKE_MODE) ?? false;
      _haveReadUsage = await Store.getBool(HAVE_READ_USAGE) ?? false;
      _isCodeServerInited = await Store.getBool(IS_CODE_SERVER_INIT) ?? false;
      _serverPort = await Store.getString(SERVER_PORT) ?? "20771";
      _currentRootfsId = await Store.getString(CURRENT_ROOTFS_ID);
      _appIcon = await Store.getString(APP_ICON) ?? "appicon.DEFAULT";
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

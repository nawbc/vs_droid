import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ConfigModel extends ChangeNotifier {
  late Directory _filesDir;
  Directory get filesDir => _filesDir;

  late Directory _termuxUsrDir;
  Directory get termuxUsrDir => _termuxUsrDir;

  late Directory _termuxBinDir;
  Directory get termuxBinDir => _termuxBinDir;

  late Directory _termuxHomeDir;
  Directory get termuxHomeDir => _termuxHomeDir;

  Future<void> init() async {
    try {
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

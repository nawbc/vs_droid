import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:vs_droid/app.dart';
import 'package:vs_droid/constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  if (Platform.isAndroid) {
    // await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  // runApp(const VSDroid());
  // await Sentry.init(
  //   (options) {
  //     if (kReleaseMode) {
  //       options.dsn = SENTRY_DNS;
  //     }
  //   },
  //   appRunner: () async {
  if (await Permission.storage.request().isGranted) {
    runApp(const VSDroid());
  }
  //   },
  // );
}

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:vs_droid/app.dart';
import 'package:vs_droid/constant.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // if (Platform.isAndroid) {
  //   SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
  //     statusBarColor: Colors.transparent,
  //     systemNavigationBarColor: Colors.transparent,
  //     systemNavigationBarDividerColor: Colors.transparent,
  //   );
  //   // SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  // }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Sentry.init(
    (options) {
      options.dsn = kReleaseMode ? SENTRY_DNS : '';
      options.debug = kDebugMode;
    },
    appRunner: () async {
      if (await Permission.storage.request().isGranted) {
        runApp(const VSDroid());
      }
    },
  );
}

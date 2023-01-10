import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:vs_droid/app.dart';
import 'package:vs_droid/constant.dart';
import 'firebase_options.dart';
import 'package:variable_app_icon/variable_app_icon.dart';

const List<String> androidIconIds = ["DEFAULT", "VSCODE"];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  VariableAppIcon.androidAppIconIds = androidIconIds;

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

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

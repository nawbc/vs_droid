import 'package:flutter/cupertino.dart';

class UIModel extends ChangeNotifier {
  late bool _canExitDesktop = true;
  bool get canExitDesktop => _canExitDesktop;

  void setCanPopToDesktop(bool val) {
    _canExitDesktop = val;
  }

  Future<void> init() async {
    try {} catch (e, s) {
      // await Sentry.captureException(
      //   e,
      //   stackTrace: s,
      // );
    }
  }
}

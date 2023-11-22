import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ignore: must_be_immutable
class DoublePop extends StatelessWidget {
  final Widget child;
  DateTime? _lastPressedTime;

  DoublePop({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: child,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        final NavigatorState navigator = Navigator.of(context);
        if (_lastPressedTime == null ||
            (_lastPressedTime != null &&
                DateTime.now().difference(_lastPressedTime!) > const Duration(milliseconds: 800))) {
          _lastPressedTime = DateTime.now();
          Fluttertoast.showToast(
            msg: "Press once again",
          );

          navigator.pop();
        }
      },
    );
  }
}

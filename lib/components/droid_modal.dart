import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../theme.dart';
import '../theme_model.dart';
import 'dialog.dart';

class DroidModalPopupRoute<T> extends PopupRoute<T> {
  DroidModalPopupRoute({
    required this.barrierColor,
    this.barrierLabel,
    required this.builder,
    bool? semanticsDismissible,
    ImageFilter? filter,
    RouteSettings? settings,
  }) : super(
          filter: filter,
          settings: settings,
        ) {
    _semanticsDismissible = semanticsDismissible;
  }

  final WidgetBuilder builder;
  late bool? _semanticsDismissible;

  @override
  final String? barrierLabel;

  @override
  final Color barrierColor;

  @override
  bool get barrierDismissible => true;

  @override
  bool get semanticsDismissible => _semanticsDismissible ?? false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);

  late Animation<double> _animation;

  late Tween<Offset> _offsetTween;

  @override
  Animation<double> createAnimation() {
    _animation = CurvedAnimation(
      parent: super.createAnimation(),
      curve: Curves.linearToEaseOut,
      reverseCurve: Curves.linearToEaseOut.flipped,
    );
    _offsetTween = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: const Offset(0.0, 0.0),
    );
    return _animation;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return CupertinoUserInterfaceLevel(
      data: CupertinoUserInterfaceLevelData.elevated,
      child: Builder(builder: builder),
    );
  }

  @override
  Widget buildTransitions(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionalTranslation(
        translation: _offsetTween.evaluate(_animation),
        child: child,
      ),
    );
  }
}

Future<T?> showDroidModal<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required ImageFilter filter,
  bool useRootNavigator = true,
  bool? semanticsDismissible,
  bool transparent = false,
}) {
  ThemeModel themeModel = Provider.of<ThemeModel>(context, listen: false);
  DroidTheme themeData = themeModel.themeData;

  return Navigator.of(context, rootNavigator: useRootNavigator).push(
    DroidModalPopupRoute<T>(
      barrierColor: transparent ? const Color(0x00382F2F) : themeData.modalColor(context),
      barrierLabel: 'Dismiss',
      builder: builder,
      filter: filter,
      semanticsDismissible: semanticsDismissible,
    ),
  );
}

Future<T?> showAlertModal<T>(context, String content) {
  return showDroidModal(
    context: context,
    filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
    builder: (BuildContext context) {
      return DroidDialog(
        withCancel: false,
        children: [Text(content)],
      );
    },
  );
}

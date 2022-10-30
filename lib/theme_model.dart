import 'package:flutter/cupertino.dart';

import 'constant.dart';
import 'store.dart';
import 'theme.dart';

class ThemeModel extends ChangeNotifier {
  late String _theme = "light";
  DroidTheme _themeData = LightTheme();
  late bool _isDark = false;

  bool get isDark => _isDark;

  DroidTheme get themeData => _themeData;
  String get theme => _theme;

  Future<void> setTheme(String theme, {notify = true}) async {
    _theme = theme;
    switch (theme) {
      case LIGHT_THEME:
        _isDark = false;
        _themeData = LightTheme();
        break;
      case DARK_THEME:
        _isDark = true;
        _themeData = DarkTheme();
        break;
      default:
        _isDark = false;
        _themeData = LightTheme();
        break;
    }
    await Store.setString(THEME_KEY, theme);
    if (notify) notifyListeners();
  }

  Future<void> init() async {
    String theme = (await Store.getString(THEME_KEY)) ?? LIGHT_THEME;
    await setTheme(theme, notify: false);
  }
}

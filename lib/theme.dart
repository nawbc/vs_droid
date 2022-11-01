import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';

abstract class DroidTheme {
  late Color primaryColor;
  late Color inactiveIconColor;
  late Color bottomNavColor;
  late Color scaffoldBackgroundColor;
  late Color navBackgroundColor;
  late Color iconColor;
  late Color actionButtonColor;
  late Color listTileColor;
  late Color itemFontColor = Colors.black54;
  late Color navTitleColor = Colors.black87;
  late Color dialogBgColor;
  late Color inputBgColor;
  late Color inputBorderColor;
  late Color menuItemColor;
  late Color divideColor;
}

class LightTheme implements DroidTheme {
  @override
  Color primaryColor = const Color(0xFF007AFF);
  @override
  Color inactiveIconColor = const Color(0xFF959596);
  @override
  Color bottomNavColor = const Color(0x94F3ECEC);
  @override
  Color scaffoldBackgroundColor = const Color(0xfffffffff);
  @override
  Color navBackgroundColor = const Color(0xfffffffff);
  @override
  Color iconColor = const Color(0x94535353);
  @override
  Color actionButtonColor = const Color(0x22181717);
  @override
  Color listTileColor = const Color(0x83EBEBEB);
  @override
  Color itemFontColor = Colors.black54;
  @override
  Color navTitleColor = Colors.black87;
  @override
  Color dialogBgColor = const Color(0xC0FFFFFF);
  @override
  Color inputBgColor = const Color(0xC0FFFFFF);
  @override
  Color inputBorderColor = const Color(0x33000000);
  @override
  Color menuItemColor = const Color(0xDEFFFFFF);
  @override
  Color divideColor = const Color(0xfff5f5f5);
}

class DarkTheme implements DroidTheme {
  @override
  Color primaryColor = const Color(0xFF007AFF);
  @override
  Color inactiveIconColor = const Color(0xFF959596);
  @override
  Color bottomNavColor = const Color(0xB00E0D0D);
  @override
  Color scaffoldBackgroundColor = const Color(0xff0000000);
  @override
  Color navBackgroundColor = const Color(0xff0000000);
  @override
  Color iconColor = const Color(0xFF007AFF);
  @override
  Color actionButtonColor = const Color(0x22ffffff);
  @override
  Color listTileColor = const Color(0xff222222);
  @override
  Color itemFontColor = const Color(0xfffffffff);
  @override
  Color navTitleColor = const Color(0xfffffffff);
  @override
  Color dialogBgColor = const Color(0x9F000000);
  @override
  Color inputBgColor = const Color(0xFF313131);
  @override
  Color inputBorderColor = const Color(0x4FFFFFFF);
  @override
  Color menuItemColor = const Color(0xcc0000000);
  @override
  Color divideColor = const Color(0xFF2C2C2C);
}

const terminalTheme = TerminalTheme(
  cursor: Color.fromARGB(255, 0, 148, 12),
  selection: Color(0XFFFFFF40),
  foreground: Color.fromARGB(255, 66, 66, 66),
  background: Color(0XFF1E1E1E),
  black: Color(0XFF000000),
  red: Color(0XFFCD3131),
  green: Color(0XFF0DBC79),
  yellow: Color(0XFFE5E510),
  blue: Color(0XFF2472C8),
  magenta: Color(0XFFBC3FBC),
  cyan: Color(0XFF11A8CD),
  white: Color(0XFFE5E5E5),
  brightBlack: Color(0XFF666666),
  brightRed: Color(0XFFF14C4C),
  brightGreen: Color(0XFF23D18B),
  brightYellow: Color(0XFFF5F543),
  brightBlue: Color(0XFF3B8EEA),
  brightMagenta: Color(0XFFD670D6),
  brightCyan: Color(0XFF29B8DB),
  brightWhite: Color(0XFFFFFFFF),
  searchHitBackground: Color(0XFFFFFF2B),
  searchHitBackgroundCurrent: Color(0XFF31FF26),
  searchHitForeground: Color(0XFF000000),
);

const terminalDarkTheme = TerminalTheme(
  cursor: Color.fromARGB(255, 0, 148, 12),
  selection: Color(0XFFFFFF40),
  foreground: Color(0xFFFFFFFF),
  background: Color(0xFF000000),
  black: Color(0XFF000000),
  red: Color(0XFFCD3131),
  green: Color(0XFF0DBC79),
  yellow: Color(0XFFE5E510),
  blue: Color(0XFF2472C8),
  magenta: Color(0XFFBC3FBC),
  cyan: Color(0XFF11A8CD),
  white: Color(0XFFE5E5E5),
  brightBlack: Color(0XFF666666),
  brightRed: Color(0XFFF14C4C),
  brightGreen: Color(0XFF23D18B),
  brightYellow: Color(0XFFF5F543),
  brightBlue: Color(0XFF3B8EEA),
  brightMagenta: Color(0XFFD670D6),
  brightCyan: Color(0XFF29B8DB),
  brightWhite: Color(0XFFFFFFFF),
  searchHitBackground: Color(0XFFFFFF2B),
  searchHitBackgroundCurrent: Color(0XFF31FF26),
  searchHitForeground: Color(0XFF000000),
);

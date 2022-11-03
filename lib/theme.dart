import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';

abstract class DroidTheme {
  late Color primaryColor;
  late Color scaffoldBackgroundColor;
}

class LightTheme implements DroidTheme {
  @override
  Color primaryColor = const Color(0xFF007AFF);
  @override
  Color scaffoldBackgroundColor = const Color(0xfffffffff);
}

class DarkTheme implements DroidTheme {
  @override
  Color primaryColor = const Color(0xFF007AFF);
  @override
  Color scaffoldBackgroundColor = const Color(0xff0000000);
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
  white: Color.fromARGB(255, 0, 0, 0),
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

import 'package:flutter/material.dart';

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
  Color searchBarColor = const Color(0xFF292929);
  @override
  Color searchBarInactiveIcon = const Color(0xFFC4C4C4);
  @override
  Color inputBorderColor = const Color(0x4FFFFFFF);
  @override
  Color menuItemColor = const Color(0xcc0000000);
  @override
  Color divideColor = const Color(0xFF2C2C2C);
}

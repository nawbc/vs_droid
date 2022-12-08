import 'package:flutter/services.dart';

class Stage {
  static const MethodChannel _channel = MethodChannel('com.deskbtm.vs_droid/stage');
  static Future<bool?> launch(Uri url) async {
    String urlStr = url.toString();
    return _channel.invokeMethod<bool>("launch", {"url": urlStr});
  }

  static Future<bool?> zoom(int val) async {
    return _channel.invokeMethod<bool>("setZoom", {"val": val});
  }
}

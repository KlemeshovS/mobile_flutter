import 'package:flutter/services.dart';

class YandexNativeAuth {
  static const MethodChannel _channel = MethodChannel('com.tritan.wobbly_flutter/yandex_auth');

  static Future<String?> signIn() async {
    try {
      final token = await _channel.invokeMethod<String>('signIn');
      return token;
    } on PlatformException catch (e) {
      print('Yandex auth error: ${e.message}');
      return null;
    }
  }
}
part of 'wpy_dio.dart';

mixin AsyncTimer {
  static Map<String, bool> _map = {};

  // map[key]==false : 正在执行方法，方法不可重复执行
  // map[key]==true : 方法可被执行
  static Future<void> runRepeatChecked<R>(
      String key, Future<void> body()) async {
    if (!_map.containsKey(key)) _map[key] = true;
    if (!(_map[key] ?? false)) return;
    _map[key] = false;
    await body();
    _map[key] = true;
  }
}

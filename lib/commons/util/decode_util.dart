// @dart = 2.12
import 'dart:convert';

import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';

extension FutureResponseStringDecodeExt on Future<Response<String>> {
  dynamic decode<T>(T Function(Map<String, dynamic> j) cb) async {
    final res = await this;
    final js = json.decode(res.data ?? '');
    // List<Map> or Map
    if (js is List) {
      return js.map((e) => cb(e)).toList();
    } else {
      final js1 = js as Map<String, dynamic>;
      return js1.trans(cb);
    }
  }
}

extension ListJsonDecodeExt on List<dynamic> {
  List<T> trans<T>(T Function(Map<String, dynamic> j) cb) {
    return this.map((e) => cb(e)).toList();
  }
}

extension MapJsonDecodeExt on Map<String, dynamic> {
  T trans<T>(T Function(Map<String, dynamic> j) cb) {
    return cb(this);
  }
}

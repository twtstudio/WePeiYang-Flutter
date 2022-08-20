// @dart = 2.12

import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';

import 'base_server.dart';
import 'error.dart';

class LoginDio extends DioAbstract {
  LoginDio() : super();

  @override
  String get baseUrl => 'https://selfstudy.twt.edu.cn/';

  @override
  Map<String, String>? get headers => {
        "DOMAIN": AuthDio.DOMAIN,
        "ticket": AuthDio.ticket,
      };

  @override
  List<InterceptorsWrapper> get interceptors => [
        ApiInterceptor(),
        InterceptorsWrapper(
          onRequest: (options, handler) {
            options.headers['token'] = CommonPreferences.token.value;
            return handler.next(options);
          },
        )
      ];
}

final loginDio = LoginDio();

class LoungeLoginApi {
  /// 获取收藏的教室id
  static Future<List<String>> get favouriteList async {
    var response = await loginDio.get('getCollections');
    var pre = Map<String, List<dynamic>>.from(response.data).values;
    if (pre.isEmpty) {
      return <String>[];
    } else {
      return pre.first.map((e) => e.toString()).toList();
    }
  }

  /// 收藏教室
  static Future<bool> collect(String id,DateTime time) async {
    try {
      await loginDio.post(
        'addCollection',
        queryParameters: {'classroom_id': id},
      );
      return true;
    } catch (e, s) {
      LoungeError.network(
        e,
        stackTrace: s,
        des: 'collect data upload error',
      )..report();
      return false;
    }
  }

  /// 取消收藏教室，失败的话就在本地添加记录，下次再做同步
  static Future<DateTime?> delete(String id) async {
    try {
      await loginDio.post(
        'deleteCollection',
        queryParameters: {'classroom_id': id},
      );
      return null;
    } catch (e, s) {
      LoungeError.network(
        e,
        stackTrace: s,
        des: 'unCollect data upload error',
      )..report();
      return DateTime.now();
    }
  }
}

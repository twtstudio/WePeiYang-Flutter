import 'dart:convert' show utf8, base64Encode;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show Color, Navigator, required;
import 'package:we_pei_yang_flutter/auth/skin_utils.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';

class ThemeDio extends DioAbstract {
  @override
  String baseUrl = 'http://120.48.17.78:1000/api/v1/';
  var headers = {};

  @override
  List<InterceptorsWrapper> interceptors = [
    InterceptorsWrapper(onRequest: (options, handler) {
      options.headers['token'] = CommonPreferences().themeToken.value;
      return handler.next(options);
    }, onResponse: (response, handler) {
      var code = response?.data['error_code'] ?? 0;
      switch (code) {
        case 0: // 成功
          return handler.next(response);
        default: // 其他错误
          return handler.reject(
              WpyDioError(error: response.data['message']), true);
      }
    })
  ];
}

final themeDio = ThemeDio();

class ThemeService with AsyncTimer {
  static Future<void> loginFromClient({
    @required void Function() onSuccess,
    @required onFailure,
  }) async {
    CommonPreferences().themeToken.clear();
    AsyncTimer.runRepeatChecked('theme_login', () async {
      try {
        var response = await themeDio.post('auth/client',
            formData: FormData.fromMap({
              'token': '${CommonPreferences().token.value}',
            }));
        CommonPreferences().themeToken.value = response.data['result'];
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static Future<void> uploadFile({
    @required File file,
    @required void Function() onSuccess,
    @required onFailure,
  }) async {
    AsyncTimer.runRepeatChecked('postTags', () async {
      try {
        var response = await themeDio.post('auth/client',
            formData: FormData.fromMap({
              'token': '${CommonPreferences().token.value}',
            }));
        CommonPreferences().themeToken.value = response.data['result'];
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static getSkins({
    @required OnResult<List<Skin>> onResult,
    @required onFailure,
  }) async {
    try {
      var response = await themeDio.get('skin/user');
      List<Skin> list = [];
      for (Map<String, dynamic> json in response.data['result']) {
        list.add(Skin.fromJson(json));
      }
      onResult(list);
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static Future<void> addSkin({
    @required void Function() onSuccess,
    @required onFailure,
  }) async {
    Skin haiTangSkin = Skin(
      id: 1,
      name: '海棠季皮肤',
      description: '是海棠季皮肤喵',
      mainPageImage:
          'https://qnhdpic.twt.edu.cn/download/origin/86e05be5a183cf9d8536e897a6dfad21.png',
      colorA: Color.fromRGBO(245, 224, 238, 1.0).value.toString(),
      colorB: Color.fromRGBO(221, 182, 190, 1.0).value.toString(),
      colorC: Color.fromRGBO(236, 206, 217, 1.0).value.toString(),
      colorD: Color.fromRGBO(236, 206, 217, 1.0).value.toString(),
      colorE: Color.fromRGBO(253, 253, 254, 1.0).value.toString(),
      colorF: Color.fromRGBO(221, 182, 190, 1.0).value.toString(),
    );
    print(haiTangSkin.toJson().toString());
    AsyncTimer.runRepeatChecked('postTags', () async {
      try {
        var response = await themeDio.post('skin',
            formData: FormData.fromMap({
              'skinName': '海棠节',
              'src': haiTangSkin.toJson().toString(),
            }));
        CommonPreferences().themeToken.value = response.data['result'];
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }
}

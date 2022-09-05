import 'dart:io';

import 'package:flutter/material.dart' show Color, required;
import 'package:we_pei_yang_flutter/auth/model/banner_pic.dart';
import 'package:we_pei_yang_flutter/auth/skin_utils.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

class ThemeDio extends DioAbstract {
  @override
  //String baseUrl = 'https://59.67.37.34/api/v1/';
  String baseUrl = 'https://haitang.twt.edu.cn/api/v1/';
  var headers = {};

  @override
  List<InterceptorsWrapper> interceptors = [
    InterceptorsWrapper(onRequest: (options, handler) {
      if (CommonPreferences.themeToken != null)
      options.headers['token'] = CommonPreferences.themeToken.value;
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
  }) async {
    CommonPreferences.themeToken.clear();
    AsyncTimer.runRepeatChecked('theme_login', () async {
      try {
        var response = await themeDio.post('auth/client',
            formData: FormData.fromMap({
              'token': CommonPreferences.token.value.toString(),
            }));
        CommonPreferences.themeToken.value = response.data['result'];
        onSuccess?.call();
      } on DioError catch (_) {
        ToastProvider.error('主题加载失败');
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
              'token': '${CommonPreferences.token.value}',
            }));
        CommonPreferences.themeToken.value = response.data['result'];
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static Future<List<Skin>> getSkins() async {
    try {
      var response = await themeDio
          .get('skin/user?token=${CommonPreferences.themeToken.value}');
      List<Skin> list = [];
      for (Map<String, dynamic> json in response.data['result']) {
        if (json != null)
        list.add(Skin.fromJson(json));
      }
      return list;
    } on DioError catch (_) {
      ToastProvider.error('获取皮肤列表失败，请刷新');
      return [];
    }
  }

  static Future<void> addSkin() async {
    Skin haiTangSkin = Skin(
      id: 1,
      name: '海棠季皮肤',
      description: '是海棠季皮肤喵',
      mainPageImage:
          'EnvConfig.QNHDPICdownload/origin/0096c030ab5c8948479c0d0e36b9577b.png',
      schedulePageImage:
          'EnvConfig.QNHDPICdownload/origin/4dc1b6aef63c44c9d1af33ce7311b389.png',
      selfPageImage:
          'EnvConfig.QNHDPICdownload/origin/b7edb6c12ddde1f3156b2a447aa00e2e.png',
      gpaImageInner:
          'EnvConfig.QNHDPICdownload/origin/6034d9dbb59306e57ebf92b665957936.png',
      gpaImageOuter:
          'EnvConfig.QNHDPICdownload/origin/e9e505986880253cace8b9b114353f7b.png',
      colorA: Color.fromRGBO(245, 224, 238, 1.0).value,
      colorB: Color.fromRGBO(221, 182, 190, 1.0).value,
      colorC: Color.fromRGBO(236, 206, 217, 1.0).value,
      colorD: Color.fromRGBO(236, 206, 217, 1.0).value,
      colorE: Color.fromRGBO(253, 253, 254, 1.0).value,
      colorF: Color.fromRGBO(221, 182, 190, 1.0).value,
      colorG: Color.fromRGBO(241, 220, 224, 1.0).value,
    );
    AsyncTimer.runRepeatChecked('uploadSkin', () async {
      try {
        await themeDio.post('skin',
            formData: FormData.fromMap({
              'skinName': '海棠节',
              'src': haiTangSkin.toJson().toString(),
            }));
      } on DioError catch (_) {}
    });
  }

  static Future<void> postMeSkin({
    @required int skinId,
    @required void Function() onSuccess,
    @required onFailure,
  }) async {
    AsyncTimer.runRepeatChecked('post_me_skin', () async {
      try {
        await themeDio.post('skin/user',
            formData: FormData.fromMap({
              'skinId': '${skinId}',
              'token': '${CommonPreferences.themeToken.value}',
            }));
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static Future<List<BannerPic>> getBanner() async {
    try {
      var response = await themeDio.get('banner');
      var result = response.data['result'];
      // return result.map((e) => BannerPic.fromJson(e)).toList();
      var list = <BannerPic>[];
      result.forEach((e) {
        list.add(BannerPic.fromJson(e));
      });
      return list;
    } catch (e, stack) {
      Logger.reportError(e, stack);
      return [];
    }
  }
}
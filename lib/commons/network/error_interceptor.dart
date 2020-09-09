import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:wei_pei_yang_demo/commons/network/dio_server.dart';

class ErrorInterceptor extends InterceptorsWrapper {
  //TODO need CommonContext、CommonPreferences
  _reLogin() async {
    var dio = await DioService().create();
    await dio.getCall("v1/auth/token/get",
        queryParameters: {"twtuname": "3019244334", "twtpasswd": "125418"},
        onSuccess: (commonBody) {
      if (commonBody?.error_code == -1) ;
      // CommonPreferences.token = Token.fromJson(commonBody.data);
    }, onFailure: (e) {
      // Navigator.pushReplacementNamed(context, '/login');
    });
    throw DioError(error: "登录失效，正在尝试自动重登");
  }

  @override
  Future onError(DioError err) {
    var code = err.type == DioErrorType.RESPONSE
        ? json.decode(err.response.data)['error_code']
        : -1;
    var request = err.response.request;
    //TODO security here
    switch (code) {
      case 10001:
        if (request.headers.containsKey("Authorization")) _reLogin();
        break;
      case 10003:
      case 10004:
        _reLogin();
        break;
      case 40000:
      case 40011:
        //TODO 办公网相关（到底是40000还是40011啊我吐力）
        throw DioError(error: "办公网帐号或密码错误");
        break;
      case 30001:
      case 30002:
        //TODO 判断当前context是否为login，否则打开login
        throw DioError(error: "账号或密码错误");
        break;
      default:
        print(
            "Unhandled error code $code, forRequest: $request Response: ${err.response}");
    }
    return null;
  }
}

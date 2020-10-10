import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/network/captcha_dialog.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';

/// 登录sso (获取session与execution -> 填写captcha -> 进行sso登录)
Future<void> loginSpider(BuildContext context, String name, String pw) async {
  var map = await getExecAndSession();
  showDialog(
      context: context, builder: (context) => CaptchaDialog(map, name, pw));
}

/// 获取包含 session、execution 的 map
Future<Map<String, String>> getExecAndSession() async {
  var map = Map<String, String>();
  var response = await fetch("https://sso.tju.edu.cn/cas/login");
  response.headers.map['set-cookie'].forEach((string) {
    if (string.contains('SESSION'))
      map['session'] = RegExp(r'SESSION=\w+').firstMatch(string).group(0);
  });
  map['execution'] = RegExp(r'(?<=execution" value=")\w+')
      .firstMatch(response.data.toString())
      .group(0);
  return map;
}

/// 进行sso登录
Future<void> ssoLogin(BuildContext context, String name, String pw,
    String captcha, Map map) async {
  var response = await fetch("https://sso.tju.edu.cn/cas/login",
      params: {
        "username": name,
        "password": pw,
        "captcha": captcha,
        "execution": map['execution'],
        "_eventId": "submit"
      },
      cookie: map['session']);
  var cookie = RegExp(r'TGC=\S+(?=\;)')
      .firstMatch(response.headers.map['set-cookie'][0])
      .group(0);
  CommonPreferences.create().tgc = cookie;
  Navigator.pop(context);
  await getClassesCookies(cookie);
}

/// 获取 GSESSIONID 、semester.id 、UqZBpD3n3iXPAw1X 、ids
Future<void> getClassesCookies(String tgc) async {
  var response = await fetch(
      "http://classes.tju.edu.cn/eams/courseTableForStd.action",
      cookie: tgc);
  var pref = CommonPreferences.create();
  response.headers.map['set-cookie'].forEach((string) {
    if (string.contains('GSESSIONID'))
      pref.gSessionId = RegExp(r'GSESSIONID=\w+').firstMatch(string).group(0);
    if (string.contains('semester'))
      pref.semesterId = RegExp(r'semester\.id=\w+').firstMatch(string).group(0);
    if (string.contains('UqZBpD3n3iXPAw1X'))
      pref.garbled =
          RegExp(r'UqZBpD3n3iXPAw1X=\w+').firstMatch(string).group(0);
  });
  pref.ids = RegExp(r'(?<=ids\"\,\")\w*')
      .firstMatch(response.data.toString())
      .group(0);
  var a = 1;
}

// TODO 以后可能要加回调和try catch
Future<Response> fetch(String url,
    {String cookie,
    List<String> cookieList,
    Map<String, dynamic> params}) async {
  var cookieTmp = cookie ?? "";
  cookieList?.forEach((string) {
    if (cookieTmp != "") cookieTmp += ';';
    cookieTmp += string;
  });
  BaseOptions options = BaseOptions(
      connectTimeout: 10000,
      receiveTimeout: 10000,
      headers: {"Cookie": cookieTmp});
  var dio = Dio()
    ..options = options
    ..interceptors.add(LogInterceptor(requestBody: false));
  return await dio.get(url, queryParameters: params);
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';

/// 登录总流程： 获取session与execution -> 填写captcha -> 进行sso登录

/// 获取包含 session、execution 的 map
Future<void> getExecAndSession({@required void Function(Map) onSuccess}) async {
  var map = Map<String, String>();
  await fetch("https://sso.tju.edu.cn/cas/login", onSuccess: (response) {
    response.headers.map['set-cookie'].forEach((string) {
      if (string.contains('SESSION'))
        map['session'] = getRegExpStr(r'SESSION=\w+', string);
    });
    map['execution'] =
        getRegExpStr(r'(?<=execution" value=")\w+', response.data.toString());
    onSuccess(map);
  });
}

/// 进行sso登录
Future<void> ssoLogin(
    BuildContext context, String name, String pw, String captcha, Map map,
    {@required void Function() onSuccess,
    void Function(DioError) onFailure}) async {
  await fetch("https://sso.tju.edu.cn/cas/login",
      params: {
        "username": name,
        "password": pw,
        "captcha": captcha,
        "execution": map['execution'],
        "_eventId": "submit"
      },
      cookie: map['session'], onSuccess: (response) async {
    var cookie =
        getRegExpStr(r'TGC=\S+(?=\;)', response.headers.map['set-cookie'][0]);
    CommonPreferences.create().tgc.value = cookie;
    Navigator.pop(context);

    /// 顺便请求一下办公网的cookie,成功后将账号密码存起来
    await getClassesCookies(cookie, onSuccess: () {
      var pref = CommonPreferences.create();
      pref.tjuuname.value = name;
      pref.tjupasswd.value = pw;
      onSuccess();
    }, onFailure: onFailure);
  }, onFailure: onFailure);
}

/// 获取 GSESSIONID 、semester.id 、UqZBpD3n3iXPAw1X 、ids 等cookie
Future<void> getClassesCookies(String tgc,
    {@required void Function() onSuccess,
    void Function(DioError) onFailure}) async {
  await fetch("http://classes.tju.edu.cn/eams/courseTableForStd.action",
      cookie: tgc, onSuccess: (response) {
    var pref = CommonPreferences.create();
    response.headers.map['set-cookie'].forEach((string) {
      if (string.contains('GSESSIONID'))
        pref.gSessionId.value = getRegExpStr(r'GSESSIONID=\w+\.\w+', string);
      if (string.contains('semester'))
        pref.semesterId.value = getRegExpStr(r'semester\.id=\w+', string);
      if (string.contains('UqZBpD3n3iXPAw1X'))
        pref.garbled.value = getRegExpStr(r'UqZBpD3n3iXPAw1X=\w+', string);
    });
    pref.ids.value = getRegExpStr(r'(?<=ids\"\,\")\w*', response.data.toString());
    onSuccess();
  }, onFailure: onFailure);
}

Future<void> fetch(String url,
    {@required void Function(Response) onSuccess,
    void Function(DioError) onFailure,
    String cookie,
    List<String> cookieList,
    Map<String, dynamic> params,
    bool isPost = false}) async {
  var cookieTmp = cookie ?? "";
  cookieList?.forEach((string) {
    if (cookieTmp != "") cookieTmp += '; ';
    cookieTmp += string;
  });
  BaseOptions options = BaseOptions(
      connectTimeout: 10000,
      receiveTimeout: 10000,
      headers: {"Cookie": cookieTmp});
  var dio = Dio()
    ..options = options
    ..interceptors.add(LogInterceptor(requestBody: false));
  try {
    var response;
    if(isPost) response = await dio.post(url, queryParameters: params);
    else response = await dio.get(url, queryParameters: params);
    onSuccess(response);
  } on DioError catch (e) {
    print("DioServiceLog: \"${e.type}\" error happened!!!");
    onFailure(e);
  }
}

/// 获取[单个]正则匹配结果，input为待匹配串，form为匹配格式
String getRegExpStr(String form, String input) =>
    RegExp(form).firstMatch(input).group(0);

/// 获取[多个]正则匹配结果，input为待匹配串，form为匹配格式
List<String> getRegExpList(String form, String input) {
  List<String> list = [];
  RegExp(form).allMatches(input).toList().forEach((e) => list.add(e.group(0)));
  return list;
}

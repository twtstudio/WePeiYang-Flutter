import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show required, BuildContext;
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/network/error_interceptor.dart';
import 'package:we_pei_yang_flutter/commons/network/net_check_interceptor.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_manager.dart'
    show OnSuccess, OnFailure;

/// 登录总流程：获取session与 execution -> 填写captcha -> 进行sso登录获取tgc -> 获取classes.tju.edu的cookie
/// 这里出现一个分支：辅修生最后获取classes.tju.edu的cookie的时候，不会返回semester.id和ids
///                  而是会返回“主修”、“辅修”字样。
void login(BuildContext context, String name, String pw, String captcha,
    Map<String, String> map,
    {@required OnSuccess onSuccess, OnFailure onFailure}) async {
  try {
    var pref = CommonPreferences();

    /// 登录sso
    var ssoRsp = await ssoLogin(name, pw, captcha, map);

    /// 这里的tgc是一个登录后给的cookie，只会使用一次所以不存了
    var tgc =
        getRegExpStr(r'TGC=\S+(?=\;)', ssoRsp.headers.map['set-cookie'][0]);
    pref.tjuuname.value = name;
    pref.tjupasswd.value = pw;

    /// 获取classes的cookies
    var cookieRsp = await getClassesCookies(tgc);
    cookieRsp.headers.map['set-cookie'].forEach((string) {
      if (string.contains('GSESSIONID'))
        pref.gSessionId.value = getRegExpStr(r'GSESSIONID=\w+\.\w+', string);
      if (string.contains('UqZBpD3n3iXPAw1X'))
        pref.garbled.value = getRegExpStr(r'UqZBpD3n3iXPAw1X=\w+', string);
      if (string.contains('semester'))
        pref.semesterId.value = getRegExpStr(r'semester\.id=\w+', string);
    });

    /// 这里如果是null的话则证明学生有辅修
    var idsValue =
        getRegExpStr(r'(?<=ids\"\,\")\w*', cookieRsp.data.toString());
    pref.ids.value = (idsValue == null) ? "useless" : idsValue;
    pref.isBindTju.value = true;
    onSuccess();
  } on DioError catch (e) {
    if (onFailure != null) onFailure(e);
  }
}

/// 获取包含 session、execution 的 map
Future<Map> getExecAndSession() =>
    fetch("https://sso.tju.edu.cn/cas/login").then((response) {
      var map = Map<String, String>();
      response.headers.map['set-cookie'].forEach((string) {
        if (string.contains('SESSION'))
          map['session'] = getRegExpStr(r'SESSION=\w+', string);
      });
      map['execution'] =
          getRegExpStr(r'(?<=execution" value=")\w+', response.data.toString());
      return map;
    });

/// 进行sso登录
Future<Response> ssoLogin(String name, String pw, String captcha, Map map) =>
    fetch("https://sso.tju.edu.cn/cas/login",
        params: {
          "username": name,
          "password": pw,
          "captcha": captcha,
          "execution": map['execution'],
          "_eventId": "submit"
        },
        cookie: map['session']);

/// 获取 GSESSIONID 、semester.id 、UqZBpD3n3iXPAw1X 、ids 等cookie
Future<Response> getClassesCookies(String tgc) =>
    fetch("http://classes.tju.edu.cn/eams/courseTableForStd.action",
        cookie: tgc);

/// 负责爬虫请求的方法
Future<Response<dynamic>> fetch(String url,
    {String cookie,
    List<String> cookieList,
    Map<String, dynamic> params,
    bool isPost = false}) {
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
    ..interceptors.add(NetCheckInterceptor())
    ..interceptors.add(ErrorInterceptor())
    ..interceptors.add(LogInterceptor());
  if (isPost)
    return dio.post(url, queryParameters: params);
  else
    return dio.get(url, queryParameters: params);
}

/// 获取[单个]正则匹配结果，input为待匹配串，form为匹配格式
String getRegExpStr(String form, String input) =>
    RegExp(form).firstMatch(input)?.group(0);

/// 获取[多个]正则匹配结果，input为待匹配串，form为匹配格式
List<String> getRegExpList(String form, String input) {
  List<String> list = [];
  RegExp(form).allMatches(input).toList().forEach((e) => list.add(e?.group(0)));
  return list;
}

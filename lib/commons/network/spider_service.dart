import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show required, BuildContext;
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/schedule/model/schedule_notifier.dart';
import '../../main.dart';

/// 登录总流程：获取session与 execution -> 填写captcha -> 进行sso登录获取tgc -> 获取classes.tju.edu的cookie
void login(BuildContext context, String name, String pw, String captcha,
    Map<String, String> map,
    {void Function() onSuccess, void Function(DioError) onFailure}) {
  var pref = CommonPreferences();

  ssoLogin(name, pw, captcha, map).then((ssoRsp) {
    var tgc =
        getRegExpStr(r'TGC=\S+(?=\;)', ssoRsp.headers.map['set-cookie'][0]);
    pref.tjuuname.value = name;
    pref.tjupasswd.value = pw;
    return getClassesCookies(tgc);
  }).then((cookieRsp) {
    cookieRsp.headers.map['set-cookie'].forEach((string) {
      if (string.contains('GSESSIONID'))
        pref.gSessionId.value = getRegExpStr(r'GSESSIONID=\w+\.\w+', string);
      if (string.contains('semester'))
        pref.semesterId.value = getRegExpStr(r'semester\.id=\w+', string);
      if (string.contains('UqZBpD3n3iXPAw1X'))
        pref.garbled.value = getRegExpStr(r'UqZBpD3n3iXPAw1X=\w+', string);
    });
    pref.ids.value =
        getRegExpStr(r'(?<=ids\"\,\")\w*', cookieRsp.data.toString());
    return getWeekInfo();
  }).then((weekRsp) {
    var matched =
        getRegExpStr(r'(?<=date\-icon)[^]+(?=当前教学周)', weekRsp.data.toString());
    var notifier = Provider.of<ScheduleNotifier>(
        WeiPeiYangApp.navigatorState.currentContext, listen: false);
    notifier.weekCount = int.parse(getRegExpStr(r'(?<=i\>\/)[0-9]+', matched));
    notifier.currentWeekWithNotify =
        int.parse(getRegExpStr(r'(?<=\<span\>)[0-9]+', matched));
    pref.isBindTju.value = true;
    onSuccess();
  }).catchError((e) {
    print("Error happened: $e");
    onFailure(e);
  });
}

/// 获取包含 session、execution 的 map
void getExecAndSession({@required void Function(Map) onSuccess}) {
  fetch("https://sso.tju.edu.cn/cas/login").then((response) {
    var map = Map<String, String>();
    response.headers.map['set-cookie'].forEach((string) {
      if (string.contains('SESSION'))
        map['session'] = getRegExpStr(r'SESSION=\w+', string);
    });
    map['execution'] =
        getRegExpStr(r'(?<=execution" value=")\w+', response.data.toString());
    onSuccess(map);
  }).catchError((e) => print("Error happened: $e"));
}

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

/// 获取当前周数、学期总周数
Future<Response> getWeekInfo() =>
    fetch("http://classes.tju.edu.cn/eams/homeExt!main.action",
        cookieList: CommonPreferences().getCookies());

Future<Response> fetch(String url,
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
    ..interceptors.add(LogInterceptor(requestBody: false));
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

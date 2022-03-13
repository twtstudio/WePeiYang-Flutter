// @dart = 2.12
import 'package:flutter/material.dart' show BuildContext;
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';

/// 登录总流程：获取session与 execution -> 填写captcha -> 进行sso登录获取tgc -> 获取classes.tju.edu的cookie
/// 这里出现一个分支：辅修生最后获取classes.tju.edu的cookie的时候，不会返回semester.id和ids
///                  而是会返回“主修”、“辅修”字样。
void login(BuildContext context, String name, String pw, String captcha,
    Map<String, String> map,
    {required OnSuccess onSuccess, required OnFailure onFailure}) async {
  try {
    /// 登录sso
    var tgc = await _ssoLogin(name, pw, captcha, map);

    /// 获取classes的cookies
    await _getClassesCookies(tgc);

    CommonPreferences.tjuuname.value = name;
    CommonPreferences.tjupasswd.value = pw;
    CommonPreferences.isBindTju.value = true;
    onSuccess();
  } on DioError catch (e) {
    onFailure(e);
  }
}

/// 获取包含 session、execution 的 map
Future<Map> getExecAndSession() async {
  var response = await fetch("https://sso.tju.edu.cn/cas/login");
  var map = Map<String, String>();
  response.headers.map['set-cookie']!.forEach((string) {
    if (string.contains('SESSION'))
      map['session'] = string.match(r'SESSION=\w+');
  });
  map['execution'] =
      response.data.toString().match(r'(?<=execution" value=")\w+');
  return map;
}

/// 进行sso登录，并返回tgc(只会使用一次的cookie，所以不用存了)
Future<String> _ssoLogin(
    String name, String pw, String captcha, Map map) async {
  var response = await fetch("https://sso.tju.edu.cn/cas/login",
      params: {
        "username": name,
        "password": pw,
        "captcha": captcha,
        "execution": map['execution'],
        "_eventId": "submit"
      },
      cookie: map['session']);
  return response.headers.map['set-cookie']![0].match(r'TGC=\S+(?=\;)');
}

/// 获取 GSESSIONID 、semester.id 、UqZBpD3n3iXPAw1X 、ids 等cookie
Future<void> _getClassesCookies(String tgc) async {
  var response = await fetch(
      "http://classes.tju.edu.cn/eams/courseTableForStd.action",
      cookie: tgc);
  response.headers.map['set-cookie']!.forEach((str) {
    if (str.contains('GSESSIONID'))
      CommonPreferences.gSessionId.value = str.match(r'GSESSIONID=\w+\.\w+');
    if (str.contains('UqZBpD3n3iXPAw1X'))
      CommonPreferences.garbled.value = str.match(r'UqZBpD3n3iXPAw1X=\w+');
    if (str.contains('semester'))
      CommonPreferences.semesterId.value = str.match(r'semester\.id=\w+');
  });

  /// 这里如果是null的话则证明学生有辅修
  var idsValue = response.data.toString().match(r'(?<=ids\"\,\")\w*');
  CommonPreferences.ids.value = (idsValue == '') ? "useless" : idsValue;
}

class _SpiderDio extends DioAbstract {}

final _spiderDio = _SpiderDio();

/// 负责爬虫请求的方法
Future<Response<dynamic>> fetch(String url,
    {String? cookie,
    List<String>? cookieList,
    Map<String, dynamic>? params,
    bool isPost = false}) {
  var cookieTmp = cookie ?? '';
  cookieList?.forEach((string) {
    if (cookieTmp != '') cookieTmp += '; ';
    cookieTmp += string;
  });
  Options? option;
  if (cookieTmp != '') option = Options(headers: {"Cookie": cookieTmp});
  if (isPost)
    return _spiderDio.post(url, queryParameters: params, options: option);
  else
    return _spiderDio.get(url, queryParameters: params, options: option);
}

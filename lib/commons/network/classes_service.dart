import 'package:dio_cookie_caching_handler/dio_cookie_interceptor.dart';
import 'package:flutter/material.dart' show BuildContext;
import 'package:path/path.dart' as p;
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/storage_util.dart';

class _SpiderDio extends DioAbstract {
  @override
  List<Interceptor> interceptors = [
    // CookieManager(CookieJa r()),
    cookieCachedHandler(),
    ClassesErrorInterceptor()
  ];
}

class ClassesService {
  /// 是否研究生
  static bool isMaster = false;

  /// 是否有辅修
  static bool hasMinor = false;

  /// 学期id
  static String semesterId = '';

  /// 检查办公网连通
  static Future<bool> check() async {
    try {
      await fetch('http://classes.tju.edu.cn');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 登录总流程：获取session与 execution -> 填写captcha -> 进行sso登录
  static void login(
      BuildContext context, String name, String pw, String captcha,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    try {
      // 登录sso
      final execution = await _getExecution();
      await _ssoLogin(name, pw, captcha, execution);
      await _getIdentity();

      // 获取classes的cookies
      CommonPreferences.tjuuname.value = name;
      CommonPreferences.tjupasswd.value = pw;
      CommonPreferences.isBindTju.value = true;

      // 刷新学期数据
      await AuthService.getSemesterInfo();

      onSuccess();
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  /// 退出登录
  static Future<void> logout() async {
    await fetch("http://classes.tju.edu.cn/eams/logoutExt.action");
  }

  /// 获取包含 session、execution 的 map
  static Future<String> _getExecution() async {
    var response = await fetch("https://sso.tju.edu.cn/cas/login");
    return response.data.toString().find(r'name="execution" value="(\w+)"');
  }

  /// 进行sso登录
  static Future<dynamic> _ssoLogin(
      String name, String pw, String captcha, String execution) async {
    await fetch("https://sso.tju.edu.cn/cas/login", isPost: true, params: {
      "username": name,
      "password": pw,
      "captcha": captcha,
      "execution": execution,
      "_eventId": "submit"
    });
    return;
  }

  static Future<void> _getIdentity() async {
    late Response<dynamic> ret;
    bool redirect = false;
    String url = 'http://classes.tju.edu.cn/eams/dataQuery.action';
    while (true) {
      if (!redirect) {
        ret = await fetch(url,
            params: {'entityId': ''},
            isPost: true,
            options: Options(
              validateStatus: (status) => status! < 400,
              followRedirects: false,
            ));
      } else {
        ret = await fetch(url,
            options: Options(
              validateStatus: (status) => status! < 400,
              followRedirects: false,
            ));
      }

      if ((ret.statusCode ?? 0) == 302) {
        url = ret.headers.value('location')!;
        redirect = true;
      } else {
        redirect = false;
        break;
      }
    }
    ret = await fetch(url, isPost: true, params: {'entityId': ''});

    isMaster = ret.data.toString().contains(' 研究');
    hasMinor = ret.data.toString().contains('辅修');

    ret = await fetch('http://classes.tju.edu.cn/eams/dataQuery.action',
        isPost: true, params: {"dataType": "semesterCalendar"});
    final allSemester = ret.data.toString().findArrays(
        "id:([0-9]+),schoolYear:\"([0-9]+)-([0-9]+)\",name:\"(1|2)\"");

    for (var arr in allSemester) {
      if ("${arr[1]}-${arr[2]} ${arr[3]}" == _currentSemester) {
        semesterId = arr[0];
        break;
      }
    }
  }

  static String get _currentSemester {
    final date = DateTime.now();
    final year = date.year;
    final month = date.month;
    if (month > 7)
      return "${year}-${year + 1} 1";
    else if (month < 2)
      return "${year - 1}-${year} 1";
    else
      return "${year - 1}-${year} 2";
  }

  static final _spiderDio = _SpiderDio();

  /// 负责爬虫请求的方法
  static Future<Response<dynamic>> fetch(String url,
      {String? cookie,
      List<String>? cookieList,
      Map<String, dynamic>? params,
      bool isPost = false,
      Options? options}) {
    if (isPost) {
      if (options == null) {
        options = Options(
          contentType: Headers.formUrlEncodedContentType,
        );
      } else {
        options.contentType = Headers.formUrlEncodedContentType;
      }
      return _spiderDio.post(
        url,
        data: params,
        options: options,
      );
    } else
      return _spiderDio.get(
        url,
        queryParameters: params,
        options: options,
      );
  }
}

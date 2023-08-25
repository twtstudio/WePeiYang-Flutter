import 'package:dio_cookie_caching_handler/dio_cookie_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/gpa/model/gpa_notifier.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam_provider.dart';

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

  static final spiderDio = _SpiderDio();

  /// 获取办公网GPA、课表、考表信息
  static Future<void> getClasses(
      BuildContext context, String name, String pw, String code) async {
    await login(name, pw, code);
    var gpaProvider = Provider.of<GPANotifier>(context, listen: false);
    var courseProvider = Provider.of<CourseProvider>(context, listen: false);
    var examProvider = Provider.of<ExamProvider>(context, listen: false);
    Future.sync(() async {
      var mtx = Mutex();

      await mtx.acquire();
      gpaProvider.refreshGPA(
        onSuccess: () {
          mtx.release();
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
          mtx.release();
        },
      );

      await mtx.acquire();
      courseProvider.refreshCourse(
        onSuccess: () {
          mtx.release();
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
          mtx.release();
        },
      );

      await mtx.acquire();
      examProvider.refreshExam(
        onSuccess: () {
          mtx.release();
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
          mtx.release();
        },
      );
    });
  }

  /// 检查办公网连通
  static Future<bool> check() async {
    try {
      await spiderDio.get('http://classes.tju.edu.cn');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 登录总流程：填写图形验证码code -> 获取session和lt -> 在后端加密得到rsa -> 进行sso登录 -> 判断本科/研究生
  static Future<void> login(String name, String pw, String code) async {
    // 获取session和lt
    var response = await spiderDio.get("https://sso.tju.edu.cn/cas/login", options: Options(
            contentType: Headers.formUrlEncodedContentType,
            validateStatus: (status) => status! < 400,
            followRedirects: false,
          ));
    if (response.statusCode == 302) {
      // 已经登录
      await _getIdentity();
      // 刷新学期数据
      await AuthService.getSemesterInfo();
      return;
    }
    var execution =
        response.data.toString().find(r'name="execution" value="(\w+)"');
    var lt = response.data.toString().find(r'name="lt" value="([\w\-]+)"');

    // 获取rsa
    response = await spiderDio.post("https://learning.twt.edu.cn/enc",
        data: FormData.fromMap({'val': name + pw + lt}));
    var rsa = response.data['data'].toString();

    // 登录sso
    await _ssoLogin(name, pw, code, execution, lt, rsa);
    await _getIdentity();

    // 刷新学期数据
    await AuthService.getSemesterInfo();
  }

  /// 退出登录
  static Future<void> logout() async {
    await spiderDio.get("https://sso.tju.edu.cn/cas/logout");
    await spiderDio.get('https://sso.tju.edu.cn/cas/login');
  }

  /// 进行sso登录
  static Future<dynamic> _ssoLogin(String name, String pw, String code,
      String execution, String lt, String rsa) async {
    var res = await spiderDio.post(
      "https://sso.tju.edu.cn/cas/login",
      data: {
        'code': code,
        'ul': name.length,
        'pl': pw.length,
        'lt': lt,
        'rsa': rsa,
        "execution": execution,
        "_eventId": "submit",
      },
      options: Options(
            contentType: Headers.formUrlEncodedContentType,
            validateStatus: (status) => status! < 400,
            followRedirects: false,
          ),
    );
  
    if ((res.statusCode == 302)||
        res.data.toString().contains(
            "var remind_strong_pwd = 'true'"))
      return;

    ToastProvider.error('检查账号密码和验证码正确');
    throw WpyDioException(error: '检查账号密码正确');
  }

  static Future<void> _getIdentity() async {
    late Response<dynamic> ret;
    bool redirect = false;
    String url = 'http://classes.tju.edu.cn/eams/dataQuery.action';
    while (true) {
      if (!redirect) {
        ret = await spiderDio.post(
          url,
          data: {'entityId': ''},
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            validateStatus: (status) => status! < 400,
            followRedirects: false,
          ),
        );
      } else {
        ret = await spiderDio.get(
          url,
          options: Options(
            validateStatus: (status) => status! < 400,
            followRedirects: false,
          ),
        );
      }

      if ((ret.statusCode ?? 0) == 302) {
        url = ret.headers.value('location')!;
        redirect = true;
      } else {
        redirect = false;
        break;
      }
    }
    ret = await spiderDio.post(
      url,
      data: {'entityId': ''},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    isMaster = ret.data.toString().contains(' 研究');
    hasMinor = ret.data.toString().contains('辅修');

    ret = await spiderDio.post(
      'http://classes.tju.edu.cn/eams/dataQuery.action',
      data: {"dataType": "semesterCalendar"},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
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
}

import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'dio_cookie_cached_handler/lib/dio_cookie_interceptor.dart';

const Map<String, String> default_header = {
  'Accept': 'application/json, text/plain, */*',
  'Accept-Encoding': 'gzip, deflate, br',
  'Accept-Language': 'en-US,en;q=0.5',
  'Connection': 'keep-alive',
  'Sec-Fetch-Dest': 'empty',
  'Sec-Fetch-Mode': 'cors',
  'Sec-Fetch-Site': 'same-origin',
  'Sec-GPC': '1',
  'User-Agent':
      'Mozilla/5.0 (X11; Linux x86_64; rv:125.0) Gecko/20100101 Firefox/125.0'
};

class LibRequestException implements Exception {
  final String message;

  LibRequestException(this.message);

  @override
  String toString() => "Library Spider report an exception, message: $message";
}

class LibraryDio extends DioAbstract {
  static const Map<String, String> icHeader = {
    ...default_header,
    'Host': 'ic.lib.tju.edu.cn',
    'Origin': 'ic.lib.tju.edu.cn',
    'Referer': 'https://ic.lib.tju.edu.cn/',
    'lan': '1',
  };

  @override
  bool get SSL => false;

  @override
  String get baseUrl => "https://ic.lib.tju.edu.cn/";

  @override
  List<Interceptor> get interceptors => [
        cookieCachedHandler(),
        InterceptorsWrapper(
          onRequest: (options, handler) {
            options.headers.addAll(icHeader);
            handler.next(options);
          },
          onResponse: (response, handler) {
            print(
                "==> content type: ${response.headers['Content-Type']?.first.split(';').first}");
            if (response.headers['Content-Type']?.first.split(';').first !=
                'application/json') {
              handler.next(response);
              return;
            }
            print("==> result data: ${response.data}");
            if (response.data['code'] != 0) {
              throw LibRequestException(response.data['message']);
            }
            response.data = response.data['data'];
            handler.next(response);
          },
        ),
      ];
}

class LibraryUserDio extends DioAbstract {
  static const Map<String, String> authHeader = {
    ...default_header,
    'Host': 'user.lib.tju.edu.cn',
    'Origin': 'user.lib.tju.edu.cn',
    'Referer': 'https://user.lib.tju.edu.cn/',
  };

  @override
  bool get SSL => false;

  @override
  String get baseUrl => "https://user.lib.tju.edu.cn/user_api/v1/";

  @override
  List<Interceptor> get interceptors => [
        cookieCachedHandler(),
        InterceptorsWrapper(
          onRequest: (options, handler) {
            options.headers.addAll(authHeader);
            handler.next(options);
          },
          onResponse: (response, handler) {
            if (response.statusCode != 200) {
              throw LibRequestException(response.data['detail']);
            }
            handler.next(response);
          },
        ),
      ];
}

class LibraryService {
  static final LibraryDio icDio = LibraryDio();
  static final LibraryUserDio userDio = LibraryUserDio();

  static Future<bool> login(String username, String password) async {
    try {
      print("loging in with $username, $password");
      // # Step0, get JSESSIONID Cookie
      // # Get Login URL
      final loginUrl =
          (await icDio.get("/ic-web/auth/address", queryParameters: {
        "finalAddress": "https://ic.lib.tju.edu.cn",
        "errPageUrl": "https://ic.lib.tju.edu.cn/#/error",
        "manager": "false",
        "consoleType": "16",
      }))
              .data;
      //#Goto login page
      icDio.get(loginUrl);

      // # step1, send usr,pass for jwt token
      final token = (await userDio.post(
        "login/access-token",
        data: {
          "username": username,
          "password": password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      ))
          .data['access_token'] as String;

      print("==> access token: $token");

      // # Authorize
      final result = (await userDio.post(
        "member/authorize",
        data: {},
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {"Authorization": "Bearer ${token}"},
        ),
      ))
          .data;
      final code = result['code'] as String;
      print("==> get code: $code");

      // # use code get cookie
      icDio.get("/authcenter/doCode", queryParameters: {
        code: code,
      });

      // check login status
      final res = icDio.get("/ic-web/auth/userInfo");
      print(res);
      return true;
    } on LibRequestException catch (e) {
      ToastProvider.error(e.message);
    } catch (e, stacktrace) {
      ToastProvider.error("未知错误");
      print(e);
      print(stacktrace);
    }
    return false;
  }
}

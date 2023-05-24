// @dart = 2.12
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

/// Don't use this class in Browser environment
class CookieManager extends InterceptorsWrapper {
  /// Cookie manager for http requests。Learn more details about
  /// CookieJar please refer to [cookie_jar](https://github.com/flutterchina/cookie_jar)
  final CookieJar cookieJar;

  CookieManager(this.cookieJar);

  final defaultUri = Uri.parse('https://tju.edu.cn');

  Map<String, List<Cookie>> cookiesMap = {};

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    Set<Cookie> cookieList = {};

    if (options.uri.host.contains("tju.edu.cn")) {
      try {
        final cookies = cookiesMap[defaultUri.host] ?? [];
        cookieList.addAll(cookies);
      } catch (_) {}
    }
    cookieJar.loadForRequest(options.uri).then((cookies) {
      cookieList.addAll(cookies);

      var cookie = getCookies(cookieList.toList());
      if (cookie.isNotEmpty) {
        options.headers[HttpHeaders.cookieHeader] = cookie;
      }
      handler.next(options);
    }).catchError((e, stackTrace) {
      var err =
          DioError(requestOptions: options, error: e, stackTrace: stackTrace);
      handler.reject(err, true);
    });
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _saveCookies(response)
        .then((_) => handler.next(response))
        .catchError((e, stackTrace) {
      var err = DioError(
          requestOptions: response.requestOptions,
          error: e,
          stackTrace: stackTrace);
      handler.reject(err, true);
    });
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      _saveCookies(err.response!)
          .then((_) => handler.next(err))
          .catchError((e, stackTrace) {
        var _err = DioError(
            requestOptions: err.response!.requestOptions,
            error: e,
            stackTrace: stackTrace);
        handler.next(_err);
      });
    } else {
      handler.next(err);
    }
  }

  Future<void> _saveCookies(Response response) async {
    var cookies = (response.headers[HttpHeaders.setCookieHeader] ?? [])
        .map((str) => Cookie.fromSetCookieValue(str))
        .toList();

    if (cookies.isNotEmpty) {
      if (response.requestOptions.uri.host.contains("tju.edu.cn")) {
        // 更新cookie
        final oldCookies = cookiesMap[defaultUri.host] ?? [];
        for (var cookie in cookies) {
          final findIndex =
              oldCookies.indexWhere((element) => element.name == cookie.name);
          if (findIndex >= 0) {
            oldCookies[findIndex] = cookie;
          } else {
            oldCookies.add(cookie);
          }
        }
        cookiesMap[defaultUri.host] = oldCookies;
      }

      await cookieJar.saveFromResponse(
        response.requestOptions.uri,
        cookies,
      );
    }
  }

  static String getCookies(List<Cookie> cookies) {
    return cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
  }
}

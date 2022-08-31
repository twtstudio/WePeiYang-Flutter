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

  String _getBaseUrl(String url) {
    final headerIdx = url.indexOf("//");
    if (headerIdx == -1) return url;
    final firstSlashIdx = url.indexOf("/", headerIdx + 2);
    if (firstSlashIdx == -1) return url.substring(headerIdx + 2);
    return url.substring(headerIdx + 2, firstSlashIdx);
  }

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    Set<Cookie> cookielist = {};

    if (options.uri.host.contains("tju.edu.cn")) {
      try {
        final cookies = await cookieJar
            .loadForRequest(Uri.parse('https://sso.tju.edu.cn/cas/login'));
        cookielist.addAll(cookies);
      } catch (_) {}
    }
    cookieJar.loadForRequest(options.uri).then((cookies) {
      cookielist.addAll(cookies);

      var cookie = getCookies(cookielist.toList());
      if (cookie.isNotEmpty) {
        options.headers[HttpHeaders.cookieHeader] = cookie;
      }
      handler.next(options);
    }).catchError((e, stackTrace) {
      var err = DioError(requestOptions: options, error: e);
      err.stackTrace = stackTrace;
      handler.reject(err, true);
    });
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _saveCookies(response)
        .then((_) => handler.next(response))
        .catchError((e, stackTrace) {
      var err = DioError(requestOptions: response.requestOptions, error: e);
      err.stackTrace = stackTrace;
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
        );
        _err.stackTrace = stackTrace;
        handler.next(_err);
      });
    } else {
      handler.next(err);
    }
  }

  Future<void> _saveCookies(Response response) async {
    var cookies = response.headers[HttpHeaders.setCookieHeader];

    if (cookies != null) {
      await cookieJar.saveFromResponse(
        response.requestOptions.uri,
        cookies.map((str) => Cookie.fromSetCookieValue(str)).toList(),
      );
    }
  }

  static String getCookies(List<Cookie> cookies) {
    return cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
  }
}

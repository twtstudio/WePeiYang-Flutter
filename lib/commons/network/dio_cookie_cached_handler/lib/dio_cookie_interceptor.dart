import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'cookie_storage.dart';

/// Since we are using Dio's interceptor. This is the interceptor for cookie handling
QueuedInterceptorsWrapper cookieCachedHandler() {
  final storage = CookieStorage(getApplicationSupportDirectory().then((value) => "${value.path}/.dio.cookies"));
  return QueuedInterceptorsWrapper(
    onRequest: (options, handler) async {
      await storage.loadToReq(options);
      handler.next(options);
    },
    onResponse: (res, handler) async {
      await storage.storeFromRes(res);
      handler.next(res);
    },
    onError: (e, handler) async {
      final res = e.response;
      if (res != null) {
        await storage.storeFromRes(res);
      }
      handler.next(e);
    },
  );
}
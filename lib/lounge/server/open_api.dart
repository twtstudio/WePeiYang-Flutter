import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';

import 'base.dart';

class OpenDio extends DioAbstract {
  @override
  String get baseUrl => 'https://selfstudy.twt.edu.cn/';

  @override
  bool get showLog => false;

  @override
  List<InterceptorsWrapper> get interceptors => [ApiInterceptor()];
}

final openDio = OpenDio();

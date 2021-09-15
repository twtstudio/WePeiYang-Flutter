import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';

class AuditDio extends DioAbstract {
  @override
  String baseUrl = "https://api.twt.edu.cn/api/";

  @override
  Map<String, String> headers = {};

  @override
  List<InterceptorsWrapper> interceptors = [];
}
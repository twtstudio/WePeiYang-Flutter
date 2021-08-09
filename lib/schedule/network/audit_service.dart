import 'package:we_pei_yang_flutter/commons/new_network/dio_manager.dart';

class AuditDio extends DioAbstract {
  @override
  String baseUrl = "https://api.twt.edu.cn/api/";

  @override
  Map<String, String> headers = {};

  @override
  List<InterceptorsWrapper> interceptors = [];
}
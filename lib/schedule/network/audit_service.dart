import 'package:wei_pei_yang_demo/commons/new_network/dio_manager.dart';

class AuditDio extends DioAbstract {
  @override
  String baseUrl = "https://api.twt.edu.cn/api/";

  @override
  Map<String, String> headers = {};

  @override
  List<InterceptorsWrapper> interceptors = [];
}
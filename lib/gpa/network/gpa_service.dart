import 'package:wei_pei_yang_demo/commons/network/dio_server.dart';
import 'package:flutter/cupertino.dart' show required;

getGPABean({@required OnSuccess onSuccess, OnFailure onFailure}) async {
  var dio = await DioService().create();
  await dio.getCall("v1/gpa",
      onSuccess: onSuccess,
      onFailure: onFailure);
}

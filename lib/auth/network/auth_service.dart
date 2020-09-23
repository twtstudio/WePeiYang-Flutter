import '../../commons/network/dio_server.dart';
import 'package:flutter/material.dart' show required;

getToken(String name, String pw,
    {@required OnSuccess onSuccess, OnFailure onFailure}) async {
  var dio = await DioService.create();
  await dio.getCall("v1/auth/token/get",
      queryParameters: {"twtuname": name, "twtpasswd": pw},
      onSuccess: onSuccess,
      onFailure: onFailure);
}

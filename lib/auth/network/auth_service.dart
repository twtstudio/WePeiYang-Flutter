import 'package:wei_pei_yang_demo/commons/network/network_model.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import '../../commons/network/dio_server.dart';
import 'package:flutter/material.dart' show required;

getToken(String name, String pw,
    {@required void Function() onSuccess,
    OnFailure onFailure,
    bool shorted = false}) async {
  var dio = await DioService.create(shorted: shorted);
  await dio.getCall("v1/auth/token/get",
      queryParameters: {"twtuname": name, "twtpasswd": pw},
      onSuccess: (commonBody) {
    var prefs = CommonPreferences.create();
    prefs.token.value = Token.fromJson(commonBody.data).token;
    prefs.username.value = name;
    prefs.password.value = pw;
    prefs.isLogin.value = true;
    onSuccess();
  }, onFailure: onFailure);
}

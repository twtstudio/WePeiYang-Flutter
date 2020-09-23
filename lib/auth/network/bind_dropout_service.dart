import '../../commons/network/dio_server.dart';
import 'package:flutter/material.dart' show required;

bindTju(String tjuuname, String tjupasswd,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  var dio = await DioService.create();
  try{
    await dio.get("v1/auth/bind/tju",
        queryParameters: {"tjuuname": tjuuname, "tjupasswd": tjupasswd});
    onSuccess();
  }catch(e){
    if(onFailure!=null)onFailure(e);
  }
}

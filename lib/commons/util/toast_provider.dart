import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// 微北洋4.0中统一使用的toast，共有三种类型
class ToastProvider{
  static success(dynamic msg) {
    Fluttertoast.showToast(
        msg: msg.toString(),
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 15.0);
  }

  static error(dynamic msg) {
    Fluttertoast.showToast(
        msg: msg.toString(),
        backgroundColor: Color.fromRGBO(53, 53, 53, 1),
        textColor: Colors.white,
        fontSize: 15.0);
  }

  static running(dynamic msg) {
    Fluttertoast.showToast(
        msg: msg.toString(),
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 15.0);
  }
}

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// 微北洋4.0中统一使用的toast，共有三种类型
class ToastProvider {
  static success(
    String msg, {
    ToastGravity gravity = ToastGravity.BOTTOM,
    Color backgroundColor: Colors.green,
    Color textColor: Colors.white,
  }) {
    Fluttertoast.showToast(
        msg: msg,
        backgroundColor: backgroundColor,
        gravity: gravity,
        textColor: textColor,
        fontSize: 15.0);
  }

  static error(String msg, {ToastGravity gravity = ToastGravity.BOTTOM}) {
    Fluttertoast.showToast(
        msg: msg,
        backgroundColor: Color.fromRGBO(53, 53, 53, 1),
        gravity: gravity,
        textColor: Colors.white,
        fontSize: 15.0);
  }

  static running(String msg, {ToastGravity gravity = ToastGravity.BOTTOM}) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 15.0,
      gravity: gravity,
    );
  }
}

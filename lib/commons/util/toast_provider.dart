import 'package:flutter/material.dart' show Color, Colors;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';

/// WePeiYangApp统一使用的toast，共有三种类型
class ToastProvider with AsyncTimer {
  static success(
    String msg, {
    ToastGravity gravity = ToastGravity.BOTTOM,
    Color backgroundColor: Colors.green,
    Color textColor: Colors.white,
  }) {
    AsyncTimer.runRepeatChecked(msg, () async {
      print('ToastProvider success: $msg');
      await Fluttertoast.showToast(
          msg: msg,
          backgroundColor: backgroundColor,
          gravity: gravity,
          textColor: textColor,
          fontSize: 15.0);
      await Future.delayed(Duration(seconds: 2));
    });
  }

  static error(String msg, {ToastGravity gravity = ToastGravity.BOTTOM}) {
    AsyncTimer.runRepeatChecked(msg, () async {
      print('ToastProvider error: $msg');
      await Fluttertoast.showToast(
          msg: msg,
          backgroundColor: Color.fromRGBO(53, 53, 53, 1),
          gravity: gravity,
          textColor: Colors.white,
          fontSize: 15.0);
      await Future.delayed(Duration(seconds: 2));
    });
  }

  static running(String msg, {ToastGravity gravity = ToastGravity.BOTTOM}) {
    AsyncTimer.runRepeatChecked(msg, () async {
      print('ToastProvider running: $msg');
      await Fluttertoast.showToast(
        msg: msg,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 15.0,
        gravity: gravity,
      );
      await Future.delayed(Duration(seconds: 2));
    });
  }
}

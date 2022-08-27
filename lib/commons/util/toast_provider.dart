// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart'
    show AsyncTimer;

class ToastProvider with AsyncTimer {
  ToastProvider._();

  static late FToast _fToast;

  static void init(BuildContext context) {
    _fToast = FToast().init(context);
  }

  static success(String msg) {
    AsyncTimer.runRepeatChecked(msg, () async {
      print('ToastProvider success: $msg');
      _fToast.showToast(
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 2),
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            msg,
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
    });
  }

  static running(String msg) {
    AsyncTimer.runRepeatChecked(msg, () async {
      print('ToastProvider running: $msg');
      _fToast.showToast(
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 2),
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            msg,
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
    });
  }

  static error(String msg) {
    AsyncTimer.runRepeatChecked(msg, () async {
      print('ToastProvider error: $msg');
      _fToast.showToast(
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 2),
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
          decoration: BoxDecoration(
            color: Color.fromRGBO(53, 53, 53, 1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            msg,
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
    });
  }

  /// 自定义 Toast
  /// [child] 显示内容
  /// [duration] 显示时间，默认为两秒
  /// [positionedToastBuilder] 自定义位置，为空时默认使用 [ToastGravity.BOTTOM]
  ///
  /// 参考代码，在屏幕中心偏下处显示图标和文字：
  /// ```dart
  /// import 'package:flutter_screenutil/flutter_screenutil.dart';
  ///
  /// ToastProvider.custom(
  ///   child: Container(
  ///     padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
  ///     decoration: BoxDecoration(
  ///       color: Colors.greenAccent,
  ///       borderRadius: BorderRadius.circular(25),
  ///     ),
  ///     child: Row(
  ///       mainAxisSize: MainAxisSize.min,
  ///       children: [
  ///         Icon(Icons.check),
  ///         SizedBox(width: 10),
  ///         Text('Hello World'),
  ///       ],
  ///     ),
  ///   ),
  ///   positionedToastBuilder: (context, child) {
  ///     return Positioned(
  ///       left: 16.0, // 左右填一样的值可以居中
  ///       right: 16.0,
  ///       top: 0.6.sh,
  ///       child: child,
  ///     );
  ///   },
  /// );
  /// ```
  static void custom({
    required Widget child,
    Duration duration = const Duration(seconds: 2),
    PositionedToastBuilder? positionedToastBuilder,
  }) {
    if (positionedToastBuilder != null) {
      _fToast.showToast(
        child: child,
        toastDuration: duration,
        positionedToastBuilder: positionedToastBuilder,
      );
    } else {
      _fToast.showToast(
        child: child,
        toastDuration: duration,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  /// 取消当前正在显示的 Toast
  static void cancelCurrent() {
    _fToast.removeCustomToast();
  }

  /// 取消队列中所有的 Toast，一般来说用这个比较好
  static void cancelAll() {
    _fToast.removeQueuedCustomToasts();
  }
}

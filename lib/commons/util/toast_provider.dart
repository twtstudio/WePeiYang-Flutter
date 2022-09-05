// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart'
    show AsyncTimer;
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';

class ToastProvider with AsyncTimer {
  ToastProvider._();

  static late FToast _fToast;

  static void init(BuildContext context) {
    _fToast = FToast().init(context);
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

  /// 新版本的 error 调整了报错的底部弹窗的位置，还加入了图标
  static void error(String msg) {
    if (msg == '') return;
    ToastProvider.custom(
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
        decoration: BoxDecoration(
          color: Color.fromRGBO(0xD9, 0x53, 0x4F, 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
                'assets/svg_pics/lake_butt_icons/error_background.svg',
                width: 15),
            SizedBox(width: 10),
            Text(
              msg,
              style: TextUtil.base.NotoSansSC.bold.sp(14).redD9,
            ),
          ],
        ),
      ),
      positionedToastBuilder: (context, child) {
        return Positioned(
          left: 16.0, // 左右填一样的值可以居中
          right: 16.0,
          bottom: 0.1.sh,
          child: child,
        );
      },
    );
  }

  static running(String msg) {
    ToastProvider.custom(
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
        decoration: BoxDecoration(
          color: Color.fromRGBO(0x21, 0x96, 0xf3, 0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          msg,
          style: TextUtil.base.NotoSansSC.regular.sp(14).white,
        ),
      ),
      positionedToastBuilder: (context, child) {
        return Positioned(
          left: 16.0, // 左右填一样的值可以居中
          right: 16.0,
          bottom: 0.1.sh,
          child: child,
        );
      },
    );
  }

  static success(String msg) {
    ToastProvider.custom(
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
        decoration: BoxDecoration(
          color: Color.fromRGBO(0x4C, 0xAF, 0x50, 0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          msg,
          style: TextUtil.base.NotoSansSC.regular.sp(14).white,
        ),
      ),
      positionedToastBuilder: (context, child) {
        return Positioned(
          left: 16.0, // 左右填一样的值可以居中
          right: 16.0,
          bottom: 0.1.sh,
          child: child,
        );
      },
    );
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

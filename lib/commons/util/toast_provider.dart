import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart'
    show AsyncTimer;
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';

import '../themes/template/wpy_theme_data.dart';
import '../themes/wpy_theme.dart';

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
  ///
  static void unFocusAllAndHideKeyboard(BuildContext context) {
    // 获取当前的FocusScope节点
    FocusScopeNode currentFocus = FocusScope.of(context);

    // 如果当前有焦点，则取消焦点并关闭键盘
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      // 这将关闭键盘并取消焦点
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  static void custom({
    required Widget child,
    Duration duration = const Duration(seconds: 1),
    PositionedToastBuilder? positionedToastBuilder,
  }) {
    if (positionedToastBuilder != null) {
      _fToast.showToast(
        child: Builder(builder: (context) {
          unFocusAllAndHideKeyboard(context);
          return child;
        }),
        toastDuration: duration,
        positionedToastBuilder: positionedToastBuilder,
      );
    } else {
      _fToast.showToast(
        child: Builder(builder: (context) {
          unFocusAllAndHideKeyboard(context);
          return child;
        }),
        toastDuration: duration,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  /// 新版本的 error 调整了报错的底部弹窗的位置，还加入了图标
  static void error(String msg) {
    if (msg == '') return;
    ToastProvider.custom(
      child: Builder(builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
          decoration: BoxDecoration(
            color: WpyTheme.of(context).get(WpyColorKey.dangerousRed),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Builder(
                  builder: (context) => SvgPicture.asset(
                        'assets/svg_pics/lake_butt_icons/error_background.svg',
                        colorFilter: ColorFilter.mode(
                            WpyTheme.of(context)
                                .get(WpyColorKey.brightTextColor),
                            BlendMode.srcIn),
                        width: 15,
                      )),
              SizedBox(width: 10),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1.sw - 90),
                child: Text(
                  msg,
                  style:
                      TextUtil.base.NotoSansSC.regular.sp(14).bright(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }),
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
      child: Builder(builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
          decoration: BoxDecoration(
            color: WpyTheme.of(context).get(WpyColorKey.infoStatusColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/svg_pics/lake_butt_icons/running_background.svg',
                width: 15,
              ),
              SizedBox(width: 10),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1.sw - 90),
                child: Text(
                  msg,
                  style:
                      TextUtil.base.NotoSansSC.regular.sp(14).bright(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }),
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
      child: Builder(builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
          decoration: BoxDecoration(
            color: WpyTheme.of(context).get(WpyColorKey.roomFreeColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/svg_pics/lake_butt_icons/success_background.svg',
                width: 15,
              ),
              SizedBox(width: 10),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1.sw - 90),
                child: Text(
                  msg,
                  style:
                      TextUtil.base.NotoSansSC.regular.sp(14).bright(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }),
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

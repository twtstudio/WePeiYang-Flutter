import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';

import '../themes/template/wpy_theme_data.dart';
import '../themes/wpy_theme.dart';

class LakeDialogWidget extends Dialog {
  final String title; //标题
  final Widget content; //内容
  final String cancelText; //是否需要"取消"按钮
  final TextStyle? confirmTextStyle; //确认按钮文字样式
  final TextStyle? cancelTextStyle; //取消按钮文字样式
  final String confirmText; //是否需要"确定"按钮
  final void Function() cancelFun; //取消回调
  final void Function() confirmFun; //确定回调
  final Color? cancelButtonColor;
  final Color? confirmButtonColor;
  final TextStyle? titleTextStyle;
  final LinearGradient? gradient;

  LakeDialogWidget({
    required this.title,
    required this.content,
    required this.cancelText,
    required this.confirmText,
    required this.cancelFun,
    required this.confirmFun,
    this.cancelButtonColor,
    this.confirmButtonColor,
    this.gradient,
    this.titleTextStyle,
    this.cancelTextStyle,
    this.confirmTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(28.w),
              decoration: BoxDecoration(
                color: WpyTheme.of(context)
                    .get(WpyColorKey.primaryBackgroundColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: [
                      Text(title,
                          style: titleTextStyle ??
                              TextUtil.base
                                  .label(context)
                                  .NotoSansSC
                                  .w500
                                  .normal
                                  .sp(18)),
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 24),
                      child: content),
                  _buildBottomButtonGroup()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtonGroup() {
    var widgets = <Widget>[];
    if (cancelText.isNotEmpty) widgets.add(_buildBottomCancelButton());
    if (confirmText.isNotEmpty && confirmText.isNotEmpty)
      widgets.add(_buildBottomOnline());
    if (confirmText.isNotEmpty && confirmText.isNotEmpty)
      widgets.add(SizedBox(width: 30.w));
    if (confirmText.isNotEmpty) widgets.add(_buildBottomPositiveButton());

    return Flex(
      direction: Axis.horizontal,
      children: widgets,
    );
  }

  Widget _buildBottomOnline() {
    return Builder(
        builder: (context) => Container(
              color: WpyTheme.of(context)
                  .get(WpyColorKey.secondaryBackgroundColor),
            ));
  }

  Widget _buildBottomCancelButton() {
    return Builder(
        builder: (context) => Container(
              height: 44.w,
              width: 136.w,
              child: TextButton(
                onPressed: cancelFun,
                child: Text(cancelText,
                    style: cancelTextStyle ??
                        TextUtil.base.normal.infoText(context).NotoSansSC.sp(16).w600),
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(3),
                  overlayColor:
                      MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.pressed))
                      return WpyTheme.of(context)
                          .get(WpyColorKey.oldSecondaryActionColor);
                    return WpyTheme.of(context)
                        .get(WpyColorKey.secondaryBackgroundColor);
                  }),
                  backgroundColor: MaterialStateProperty.all(
                      cancelButtonColor ??
                          WpyTheme.of(context)
                              .get(WpyColorKey.secondaryBackgroundColor)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
                ),
              ),
            ));
  }

  Widget _buildBottomPositiveButton() {
    return Builder(
        builder: (context) => gradient != null
            ? Container(
                height: 44.w,
                width: 136.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: gradient,
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 1.6,
                        color: WpyTheme.of(context)
                            .get(WpyColorKey.iconAnimationStartColor),
                        offset: Offset(-1, 3),
                        spreadRadius: 1),
                  ],
                ),
                child: TextButton(
                  onPressed: this.confirmFun,
                  child: Text(confirmText,
                      style: confirmTextStyle ??
                          TextUtil.base.normal
                              .reverse(context)
                              .NotoSansSC
                              .sp(16)
                              .w400),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                  ),
                ),
              )
            : Container(
                height: 44.w,
                width: 136.w,
                child: TextButton(
                  onPressed: this.confirmFun,
                  child: Text(
                    confirmText,
                    style: confirmTextStyle ??
                        TextUtil.base.normal
                            .reverse(context)
                            .NotoSansSC
                            .sp(16)
                            .w400,
                  ),
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(3),
                    overlayColor:
                        MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.pressed))
                        return WpyTheme.of(context)
                            .get(WpyColorKey.oldSecondaryActionColor);
                      return WpyTheme.of(context)
                          .get(WpyColorKey.secondaryBackgroundColor);
                    }),
                    backgroundColor: MaterialStateProperty.all(
                        confirmButtonColor ??
                            WpyTheme.of(context)
                                .get(WpyColorKey.secondaryBackgroundColor)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                  ),
                ),
              ));
  }
}

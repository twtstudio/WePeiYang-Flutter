// @dart = 2.12
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';

class DialogWidget extends Dialog {
  final String title; //标题
  final Widget content; //内容
  final String cancelText; //是否需要"取消"按钮
  final TextStyle confirmTextStyle; //确认按钮文字样式
  final TextStyle cancelTextStyle; //取消按钮文字样式
  final String confirmText; //是否需要"确定"按钮
  final void Function() cancelFun; //取消回调
  final void Function() confirmFun; //确定回调
  DialogWidget(
      {required this.title,
      required this.content,
      required this.cancelText,
      required this.confirmTextStyle,
      required this.cancelTextStyle,
      required this.confirmText,
      required this.cancelFun,
      required this.confirmFun});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(28.w),
              decoration: ShapeDecoration(
                color: Color(0xfff2f2f2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(0),
                    child: Row(
                      children: [
                        Text(title,
                            style: TextUtil.base.black2A.NotoSansSC.w500.normal
                                .sp(18)),
                      ],
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(minHeight: 100),
                    child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: content),
                  ),
                  this._buildBottomButtonGroup()
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
      widgets.add(SizedBox(
        width: 30.w,
      ));
    if (confirmText.isNotEmpty) widgets.add(_buildBottomPositiveButton());

    return Flex(
      direction: Axis.horizontal,
      children: widgets,
    );
  }

  Widget _buildBottomOnline() {
    return Container(
      color: ColorUtil.backgroundColor,
    );
  }

  Widget _buildBottomCancelButton() {
    return Container(
      height: 44.w,
      width: 136.w,
      child: TextButton(
        onPressed: this.cancelFun,
        child: Text(cancelText, style: cancelTextStyle),
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(3),
          overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.pressed))
              return Color.fromRGBO(79, 88, 107, 1);
            return ColorUtil.backgroundColor;
          }),
          backgroundColor: MaterialStateProperty.all(ColorUtil.backgroundColor),
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        ),
      ),
    );
  }

  Widget _buildBottomPositiveButton() {
    return Container(
      height: 44.w,
      width: 136.w,
      child: TextButton(
        onPressed: this.confirmFun,
        child: Text(confirmText, style: confirmTextStyle),
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(3),
          overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.pressed))
              return Color.fromRGBO(79, 88, 107, 1);
            return ColorUtil.backgroundColor;
          }),
          backgroundColor: MaterialStateProperty.all(ColorUtil.backgroundColor),
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';

class AprilFoolDialog extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => AprilFoolDialogState();
  final String confirmText;
  final String cancelText;
  final String content;
  final Function confirmFun;
  const AprilFoolDialog({Key key, this.cancelText,this.confirmText,this.content,this.confirmFun})
      : super(key: key);
}

class AprilFoolDialogState extends State<AprilFoolDialog>{

  @override
  Widget build(BuildContext context) {
    return LakeDialogWidget(
        confirmButtonColor: ColorUtil.selectionButtonColor,
        title: '愚人节快乐！',
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 15.w),
            RichText(
              text: TextSpan(
                  text: widget.content,
                  style: TextUtil.base.normal.black2A.NotoSansSC
                      .sp(14)
                      .w400,
                  ),
            ),
          ],
        ),
        cancelText: widget.cancelText,
        confirmTextStyle:
        TextUtil.base.normal.white.NotoSansSC.sp(16).w400,
        cancelTextStyle:
        TextUtil.base.normal.black2A.NotoSansSC.sp(16).w400,
        confirmText:widget.confirmText,
        cancelFun: () {
          Navigator.pop(context);
        },
        confirmFun: () {
          widget.confirmFun.call();
            Navigator.pop(context);
        });
  }
}
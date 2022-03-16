import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/message/model/message_provider.dart';

class FeedbackReadAllButton extends StatefulWidget {
  const FeedbackReadAllButton({Key key}) : super(key: key);

  @override
  _FeedbackReadAllButtonState createState() => _FeedbackReadAllButtonState();
}

class _FeedbackReadAllButtonState extends State<FeedbackReadAllButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Image.asset('assets/images/lake_butt_icons/check-square.png',
            width: 15.w),
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return DialogWidget(
                  title: '一键已读：',
                  titleTextStyle:
                      TextUtil.base.normal.black2A.NotoSansSC.sp(18).w600,
                  content: Text('这将清除所有的消息提醒'),
                  cancelText: "取消",
                  confirmTextStyle:
                      TextUtil.base.normal.white.NotoSansSC.sp(16).w600,
                  cancelTextStyle:
                      TextUtil.base.normal.black2A.NotoSansSC.sp(16).w400,
                  confirmText: "确认",
                  cancelFun: () {
                    Navigator.pop(context);
                  },
                  confirmFun: () async {
                    await context.read<MessageProvider>().setAllMessageRead();
                    Navigator.pop(context);
                  },
                  confirmButtonColor: ColorUtil.selectionButtonColor,
                );
              });
        });
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:we_pei_yang_flutter/auth/view/privacy/lake_privacy_dialog.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/home/home_router.dart';

class FirstInLakeDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FirstInLakeDialogState();
  final ValueNotifier<bool> checkedNotifier;

  const FirstInLakeDialog({Key key, this.checkedNotifier}) : super(key: key);
}

class FirstInLakeDialogState extends State<FirstInLakeDialog> {
  @override
  Widget build(BuildContext context) {
    return LakeDialogWidget(
        confirmButtonColor: ColorUtil.selectionButtonColor,
        title: '同学你好：',
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 15.w),
            RichText(
              text: TextSpan(
                  text: "尊敬的微北洋用户：\n"
                          "\n" +
                      "经过一段时间的沉寂，我们很高兴能够带着崭新的求实论坛与您相见。\n" +
                      "\n" +
                      "让我来为您简单的介绍一下，原“校务专区”已与其包含的标签“小树洞”分离，成为求实论坛中的两个分区，“小树洞”更名为“青年湖底”，同时我们也在努力让求实在功能上接近于一个成熟的论坛。\n" +
                      "\n" +
                      "现在它拥有：\n" +
                      "\n" +
                      "点踩、举报；回复评论、带图评论；分享、自定义tag、内链外链跳转...还有一些细节等待您去自行挖掘。\n" +
                      "\n" +
                      "还有最重要的一点，为了营造良好的社区氛围，这里有一份社区规范待您查看。",
                  style: TextUtil.base.normal.black2A.NotoSansSC.sp(14).w400,
                  children: [
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) =>
                                  LakePrivacyDialog());
                        },
                      text: '《求实论坛社区规范》',
                      style: TextUtil.base.normal.NotoSansSC
                          .sp(14)
                          .w400
                          .textButtonBlue,
                    )
                  ]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ValueListenableBuilder<bool>(
                    valueListenable: widget.checkedNotifier,
                    builder: (context, type, _) {
                      return GestureDetector(
                        onTap: () {
                          widget.checkedNotifier.value =
                              !widget.checkedNotifier.value;
                        },
                        child: Stack(
                          children: [
                            SvgPicture.asset(
                              "assets/svg_pics/lake_butt_icons/checkedbox_false.svg",
                              width: 16.w,
                            ),
                            if (widget.checkedNotifier.value == false)
                              Positioned(
                                top: 3.w,
                                left: 3.w,
                                child: SvgPicture.asset(
                                  "assets/svg_pics/lake_butt_icons/check.svg",
                                  width: 10.w,
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                SizedBox(width: 10.w),
                Text('我已阅读并承诺遵守',
                    style: TextUtil.base.normal.black2A.NotoSansSC.sp(12).w400),
                SizedBox(width: 2.w),
                TextButton(
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(1, 1)),
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) =>
                              LakePrivacyDialog());
                    },
                    child: Text(
                      '《求实论坛社区规范》',
                      style: TextUtil.base.normal.NotoSansSC
                          .sp(12)
                          .w400
                          .textButtonBlue,
                      overflow: TextOverflow.ellipsis,
                    ))
              ],
            )
          ],
        ),
        cancelText: "返回主页",
        confirmText: "前往求实论坛",
        gradient: LinearGradient(
            colors: [
              Color(0xFF2C7EDF),
              Color(0xFFA6CFFF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // 在0.7停止同理
            stops: [0, 0.99]),
        cancelFun: () {
          Navigator.pop(context);
          Navigator.popAndPushNamed(context, HomeRouter.home);
        },
        confirmFun: () {
          if (widget.checkedNotifier.value == false) {
            Navigator.pop(context);
            CommonPreferences.isFirstLogin.value = false;
          } else {
            ToastProvider.error('请同意《求实论坛社区规范》');
          }
        });
  }
}

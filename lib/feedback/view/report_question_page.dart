import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/auth/view/privacy/lake_privacy_dialog.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/new_post_page.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

import '../../commons/themes/wpy_theme.dart';

class ReportPageArgs {
  final int id;
  final int floorId;
  final bool isQuestion; // 是举报问题还是举报评论

  ReportPageArgs(this.id, this.isQuestion, {this.floorId = -1});
}

class ReportQuestionPage extends StatefulWidget {
  final ReportPageArgs args;

  ReportQuestionPage(this.args);

  @override
  _ReportQuestionPageState createState() => _ReportQuestionPageState();
}

class _ReportQuestionPageState extends State<ReportQuestionPage> {
  String textInput = '';

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ButtonStyle(
      elevation: MaterialStateProperty.all(1),
      overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.pressed))
          return WpyTheme.of(context).get(WpyColorKey.oldActionRippleColor);
        return WpyTheme.of(context).get(WpyColorKey.oldActionColor);
      }),
      backgroundColor: MaterialStateProperty.all(
          WpyTheme.of(context).get(WpyColorKey.oldActionColor)),
      shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      minimumSize: MaterialStateProperty.all(Size(80, 40)),
    );
    var appBar = AppBar(
      backgroundColor: WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
      leading: IconButton(
        icon: Icon(Icons.arrow_back,
            color: WpyTheme.of(context).get(WpyColorKey.defaultActionColor)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        S.current.feedback_report,
        style: TextUtil.base.NotoSansSC.medium.label(context).sp(18),
      ),
      centerTitle: true,
      elevation: 0,
    );

    var reportButton = Container(
        padding: EdgeInsets.only(right: 26),
        child: ElevatedButton(
          onPressed: () {
            if (textInput == '') {
              ToastProvider.error("请输入详细说明");
              return;
            }
            FeedbackService.report(
                id: widget.args.id,
                floorId: widget.args.floorId,
                isQuestion: widget.args.isQuestion,
                reason: textInput,
                onSuccess: () {
                  ToastProvider.success(S.current.feedback_report_success);
                  Navigator.pop(context);
                },
                onFailure: (e) {
                  ToastProvider.error(e.error.toString());
                });
          },
          child: Text(S.current.feedback_report,
              style: TextUtil.base.NotoSansSC.reverse(context).w600.sp(18)),
          style: buttonStyle,
        ));

    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
            child: Container(
              width: MediaQuery.of(context).size.width - 16,
              height: 60,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: widget.args.isQuestion
                      ? Text(
                          "你正在举报" +
                              "“#MP${widget.args.id.toString().padLeft(6, '0')}”",
                          style: TextUtil.base
                              .label(context)
                              .NotoSansSC
                              .medium
                              .sp(18),
                        )
                      : Text(
                          "你正在举报" +
                              "“#FL${widget.args.id.toString().padLeft(6, '0')}”",
                          style: TextUtil.base
                              .label(context)
                              .NotoSansSC
                              .medium
                              .sp(18),
                        ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
            child: Container(
              width: MediaQuery.of(context).size.width - 16,
              padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
              height: 300,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor)),
              child: TextField(
                minLines: 7,
                maxLines: 15,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.done,
                style: TextUtil.base.normal.customColor(WpyTheme.of(context).get(WpyColorKey.cursorColor)).sp(14),
                decoration: InputDecoration.collapsed(
                  hintText: '请填写举报理由，如“色情暴力”“政治敏感”等',
                  hintStyle:
                      TextUtil.base.regular.NotoSansSC.label(context).sp(16),
                ),
                onChanged: (text) {
                  textInput = text;
                },
                inputFormatters: [
                  CustomizedLengthTextInputFormatter(200),
                ],
              ),
            ),
          ),
          //湖底规范
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //先与上面对齐
              SizedBox(width: 25),
              TextButton(
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(1, 1)),
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) => LakePrivacyDialog());
                  },
                  child: Text(
                    '查看《求实论坛社区规范》',
                    style: TextUtil.base.normal.NotoSansSC
                        .sp(16)
                        .w400
                        .textButtonPrimary(context),
                    overflow: TextOverflow.ellipsis,
                  )),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: reportButton,
          ),
        ],
      ),
    );
  }
}

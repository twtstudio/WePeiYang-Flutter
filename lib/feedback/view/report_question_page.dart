import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/new_post_page.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class ReportQuestionPage extends StatefulWidget {
  final int questionId;

  ReportQuestionPage(this.questionId);

  @override
  _ReportQuestionPageState createState() => _ReportQuestionPageState();
}

class _ReportQuestionPageState extends State<ReportQuestionPage> {
  int index = 1;

  static const reasons = [
    '', // 无用，对应index == 0
    '垃圾广告信息',
    '辱骂、人身攻击等不友善行为',
    '诱导赞同、关注等行为',
    '骚扰',
  ];

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: ColorUtil.mainColor),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        S.current.feedback_report,
        style: FontManager.YaHeiRegular.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: ColorUtil.boldTextColor,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      brightness: Brightness.light,
    );

    var reasonTiles = <RadioListTile>[];
    for (int i = 1; i < reasons.length; i++) {
      reasonTiles.add(
        RadioListTile(
          value: i,
          groupValue: this.index,
          selected: this.index == i,
          onChanged: (value) {
            setState(() => this.index = value);
          },
          title: Text(
            reasons[i],
            style: FontManager.YaHeiRegular.copyWith(
              fontSize: 15,
              color: ColorUtil.boldTextColor,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          ...reasonTiles,
          RadioListTile(
            value: reasons.length,
            groupValue: this.index,
            selected: this.index == reasons.length,
            onChanged: (value) {
              setState(() => this.index = value);
            },
            title: Text(
              '其他',
              style: FontManager.YaHeiRegular.copyWith(
                fontSize: 15,
                color: ColorUtil.boldTextColor,
              ),
            ),
            secondary: IconButton(
              icon: Icon(Icons.keyboard_arrow_right,
                  size: 24, color: ColorUtil.boldTextColor),
              onPressed: () {
                Navigator.pushNamed(context, FeedbackRouter.reportOther,
                    arguments: widget.questionId);
              },
            ),
          ),
          Spacer(),
          ElevatedButton(
            onPressed: _report,
            child: Text(S.current.feedback_report,
                style: FontManager.YaHeiRegular.copyWith(
                    color: index == reasons.length
                        ? Color.fromRGBO(98, 103, 123, 1)
                        : Colors.white,
                    fontSize: 13)),
            style: ButtonStyle(
              elevation: MaterialStateProperty.all(5),
              overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (index == reasons.length) return Colors.grey[300];
                if (states.contains(MaterialState.pressed))
                  return Color.fromRGBO(103, 110, 150, 1);
                return Color.fromRGBO(53, 59, 84, 1);
              }),
              backgroundColor:
                  MaterialStateProperty.resolveWith<Color>((states) {
                if (index == reasons.length) return Colors.grey[300];
                return Color.fromRGBO(53, 59, 84, 1);
              }),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
              minimumSize: MaterialStateProperty.all(Size(220, 50)),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }

  _report() {
    if (index == reasons.length) return;
    FeedbackService.reportQuestion(
        id: widget.questionId,
        reason: reasons[index],
        onSuccess: () {
          ToastProvider.success(S.current.feedback_report_success);
          Navigator.pop(context);
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
        });
  }
}

class ReportOtherReasonPage extends StatefulWidget {
  final int questionId;

  ReportOtherReasonPage(this.questionId);

  @override
  _ReportOtherReasonPageState createState() => _ReportOtherReasonPageState();
}

class _ReportOtherReasonPageState extends State<ReportOtherReasonPage> {
  String textInput = '';

  final buttonStyle = ButtonStyle(
    elevation: MaterialStateProperty.all(5),
    overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.pressed))
        return Color.fromRGBO(103, 110, 150, 1);
      return Color.fromRGBO(53, 59, 84, 1);
    }),
    backgroundColor: MaterialStateProperty.all(Color.fromRGBO(53, 59, 84, 1)),
    shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
    minimumSize: MaterialStateProperty.all(Size(100, 50)),
  );

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: ColorUtil.mainColor),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        S.current.feedback_other_reason,
        style: FontManager.YaHeiRegular.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: ColorUtil.boldTextColor,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      brightness: Brightness.light,
    );

    var backButton = ElevatedButton(
      onPressed: () => Navigator.pop(context),
      child: Text('返回',
          style: FontManager.YaHeiRegular.copyWith(
              color: Colors.white, fontSize: 13)),
      style: buttonStyle,
    );

    var reportButton = ElevatedButton(
      onPressed: () {
        if (textInput == '') {
          ToastProvider.error("请输入详细说明");
          return;
        }
        FeedbackService.reportQuestion(
            id: widget.questionId,
            reason: textInput,
            onSuccess: () {
              ToastProvider.success(S.current.feedback_report_success);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            onFailure: (e) {
              ToastProvider.error(e.error.toString());
            });
      },
      child: Text(S.current.feedback_report,
          style: FontManager.YaHeiRegular.copyWith(
              color: Colors.white, fontSize: 13)),
      style: buttonStyle,
    );

    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
            child: TextField(
              minLines: 7,
              maxLines: 15,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
              style: FontManager.YaHeiRegular.copyWith(
                  color: ColorUtil.boldTextColor,
                  fontWeight: FontWeight.normal,
                  fontSize: 14),
              decoration: InputDecoration.collapsed(
                hintText: '举报详细说明（必填，最多200字）',
                hintStyle: FontManager.YaHeiRegular.copyWith(
                  color: Color(0xffd0d1d6),
                  fontSize: 14,
                ),
              ),
              onChanged: (text) {
                textInput = text;
                print(text);
              },
              inputFormatters: [
                CustomizedLengthTextInputFormatter(200),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [backButton, reportButton],
          ),
        ],
      ),
    );
  }
}
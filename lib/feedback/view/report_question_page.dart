import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/new_post_page.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class ReportPageArgs {
  final int id;
  final bool isQuestion; // 是举报问题还是举报评论

  ReportPageArgs(this.id, this.isQuestion);
}

class ReportQuestionPage extends StatefulWidget {
  final ReportPageArgs args;

  ReportQuestionPage(this.args);

  @override
  _ReportQuestionPageState createState() => _ReportQuestionPageState();
}

class _ReportQuestionPageState extends State<ReportQuestionPage> {
  int index = 1;

  static const reasons = [
    '', // 无用，对应index == 0
    '违反宪法及相关法律法规与政策，违反《普通高等学校学生管理规定》和天津大学学生管理规定',
    '危害国家安全，煽动民族矛盾，鼓动地域歧视，以及其他破坏政治稳定',
    '散布宗教、迷信、谣言、虚假信息，干扰校园和社会秩序',
    '含有淫秽色情、性暗示、赌博、传销、暴力、凶杀、恐怖或者教唆犯罪内容',
    '侵害他人肖像权隐私，未经允许披露他人信息、侮辱攻击他人或机构',
    '干扰校务专区正常运营，以及迫害其他用户或第三方合法权益的内容'
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
        S.current.feedback_report + (widget.args.isQuestion ? '问题' : '评论'),
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
            style: TextStyle(fontSize: 13, color: ColorUtil.boldTextColor),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: MediaQuery.of(context).size.width-16,
              height: 60,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                  color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                    child: Text("你正在举报"+"“${widget.args.id}”",style: TextStyle(fontSize: 20,color: ColorUtil.boldTextColor),),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                  color: Colors.white),
              child: Column(
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
                      style: TextStyle(
                          fontSize: 13, color: ColorUtil.boldTextColor),
                    ),
                    secondary: IconButton(
                      icon: Icon(Icons.keyboard_arrow_right,
                          size: 24, color: ColorUtil.boldTextColor),
                      onPressed: () {
                        Navigator.pushNamed(context, FeedbackRouter.reportOther,
                            arguments: widget.args);
                      },
                    ),
                  ),
                ],
              ),
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
    FeedbackService.report(
        id: widget.args.id,
        isQuestion: widget.args.isQuestion,
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
  final ReportPageArgs args;

  ReportOtherReasonPage(this.args);

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
        FeedbackService.report(
            id: widget.args.id,
            isQuestion: widget.args.isQuestion,
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

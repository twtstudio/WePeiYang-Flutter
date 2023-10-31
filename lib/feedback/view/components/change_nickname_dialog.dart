import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/commons/util/color_util.dart';

class ChangeNicknameDialog extends StatefulWidget {
  const ChangeNicknameDialog({Key? key}) : super(key: key);

  @override
  ChangeNicknameDialogState createState() => ChangeNicknameDialogState();
}

class ChangeNicknameDialogState extends State<ChangeNicknameDialog> {
  final _textEditingController = TextEditingController();
  final _focus = FocusNode();
  String _commentLengthIndicator = '0/20';

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LakeDialogWidget(
      title: '修改你的昵称',
      titleTextStyle: TextUtil.base.w700.NotoSansSC.sp(20).h(1.4).black00,
      confirmButtonColor: Color.fromRGBO(44, 126, 223, 1),
      confirmFun: () {
        FeedbackService.changeNickname(
            onSuccess: () {
              ToastProvider.success('修改成功喵');
              FeedbackService.getUserInfo(
                  onSuccess: () {},
                  onFailure: (e) {
                    ToastProvider.error(e.error.toString());
                  });
              Navigator.pop(context);
            },
            onFailure: (e) {
              _focus.unfocus();
              ToastProvider.error(e.error.toString());
            },
            nickName: _textEditingController.text);
      },
      confirmTextStyle: TextUtil.base.w700.NotoSansSC.sp(16).h(1.4).white,
      confirmText: '确定',
      cancelText: '取消',
      content: Column(
        children: [
          TextField(
            style: TextUtil.base.w400.NotoSansSC.sp(16).h(1.4).black00,
            controller: _textEditingController,
            focusNode: _focus,
            maxLength: 20,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              counterText: '',
              hintText: '请设置合理昵称捏',
              suffix: Text(
                _commentLengthIndicator,
                style: TextUtil.base.w400.NotoSansSC.sp(12).greyAA,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              fillColor: ColorUtil.whiteF8Color,
              filled: true,
              isDense: true,
            ),
            onChanged: (text) {
              _commentLengthIndicator = '${text.characters.length}/20';
              setState(() {});
            },
            minLines: 1,
            maxLines: 1,
          ),
          SizedBox(height: 10),
          Text('（仅在求实论坛非实名区生效）',
              style: TextUtil.base.w400.NotoSansSC.sp(12).h(1.4).greyA6),
        ],
      ),
      cancelFun: () => Navigator.pop(context),
      cancelTextStyle: TextUtil.base.w400.NotoSansSC.sp(16).h(1.4).greyA6,
    );
  }
}

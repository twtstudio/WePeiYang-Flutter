import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';

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
      titleTextStyle:
          TextUtil.base.w700.NotoSansSC.sp(20).h(1.4).primary(context),
      confirmButtonColor:
          WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
      confirmFun: () {
        if (_textEditingController.text == "") {
          ToastProvider.error('昵称不能为空喵');
          return;
        }
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
      confirmTextStyle:
          TextUtil.base.w700.NotoSansSC.sp(16).h(1.4).reverse(context),
      confirmText: '确定',
      cancelText: '取消',
      content: Column(
        children: [
          TextField(
            style: TextUtil.base.w400.NotoSansSC.sp(16).h(1.4).primary(context),
            controller: _textEditingController,
            focusNode: _focus,
            maxLength: 20,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              counterText: '',
              hintText: '请设置合理昵称捏',
              suffix: Text(
                _commentLengthIndicator,
                style:
                    TextUtil.base.w400.NotoSansSC.sp(12).replySuffix(context),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              fillColor: WpyTheme.of(context)
                  .get(WpyColorKey.secondaryBackgroundColor),
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
              style: TextUtil.base.w400.NotoSansSC
                  .sp(12)
                  .h(1.4)
                  .unlabeled(context)),
        ],
      ),
      cancelFun: () => Navigator.pop(context),
      cancelTextStyle:
          TextUtil.base.w400.NotoSansSC.sp(16).h(1.4).unlabeled(context),
    );
  }
}

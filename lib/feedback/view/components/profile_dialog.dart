import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class ProfileDialog extends StatelessWidget {
  final Post post;
  final void Function() onConfirm;
  final void Function() onCancel;

  const ProfileDialog(
      {Key key,
      @required this.post,
      @required this.onConfirm,
      @required this.onCancel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color.fromRGBO(237, 240, 244, 1)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
              child: Text(
                  S.current.feedback_delete_question_content +
                      ': ${post.title}',
                  style: FontManager.YaHeiRegular.copyWith(
                      color: Color.fromRGBO(79, 88, 107, 1),
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Text(
                      S.current.feedback_cancel,
                      style: FontManager.YaQiHei.copyWith(
                        color: ColorUtil.boldTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 30),
                GestureDetector(
                  onTap: onConfirm,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Text(
                      S.current.feedback_ok,
                      style: FontManager.YaQiHei.copyWith(
                        color: ColorUtil.boldTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

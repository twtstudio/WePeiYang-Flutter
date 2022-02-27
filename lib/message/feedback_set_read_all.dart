import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
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
        icon: Image.asset('assets/images/lake_butt_icons/check-square.png', width: 15.w),
        onPressed: () {
          showDialog<bool>(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) => ReadAllDialog())
              .then((ok) async {
            if (ok) {
              context.read<MessageProvider>().setAllMessageRead();
            }
          });
        });
  }
}

final _hintStyle = FontManager.YaQiHei.copyWith(
    fontSize: 15,
    color: ColorUtil.boldTextColor,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.none);

class ReadAllDialog extends Dialog {
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
            SizedBox(height: 20),
            Text('确定要设置所有消息已读嘛？',
                textAlign: TextAlign.center,
                style: FontManager.YaHeiRegular.copyWith(
                    color: Color.fromRGBO(79, 88, 107, 1),
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context, false),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Text(S.current.cancel, style: _hintStyle),
                  ),
                ),
                SizedBox(width: 30),
                GestureDetector(
                  onTap: () => Navigator.pop(context, true),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Text(S.current.ok, style: _hintStyle),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

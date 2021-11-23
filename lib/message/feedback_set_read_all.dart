import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/message/message_provider.dart';
import 'package:we_pei_yang_flutter/message/message_service.dart';

class FeedbackReadAllButton extends StatefulWidget {
  const FeedbackReadAllButton({Key key}) : super(key: key);

  @override
  _FeedbackReadAllButtonState createState() => _FeedbackReadAllButtonState();
}

class _FeedbackReadAllButtonState extends State<FeedbackReadAllButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.check_box_outlined),
        onPressed: () {
          showDialog<bool>(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) => ReadAllDialog())
              .then((ok) async {
            if (ok) {
              var result = await MessageService.setFeedbackMessageReadAll();
              if (result) {
                Provider.of<MessageProvider>(context, listen: false)
                    .refreshFeedbackCount();
              }
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
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color.fromRGBO(237, 240, 244, 1)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(S.current.feedback_set_all_read,
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

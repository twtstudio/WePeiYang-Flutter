import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/feedback/model/feedback_notifier.dart';
import 'package:wei_pei_yang_demo/lounge/provider/provider_widget.dart';
import 'package:wei_pei_yang_demo/message/message_provider.dart';

class FeedbackBannerWidget extends StatelessWidget {
  final int questionId;
  final Widget child;

  const FeedbackBannerWidget({Key key, this.questionId, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProvider>(builder: (__, model, _) {
      var list = model.feedbackMessageList
          .where((element) => element.id == questionId);
      var messageId = list.isEmpty ? null : list.first.messageId;

      Widget result;
      print("FEEDBACKMESSAGEID ${messageId?.toString() ?? "null"}");
      if (messageId != null) {
        result = GestureDetector(
          onTapDown: (_) async => await model.setFeedbackMessageRead(messageId),
          child: ClipRect(
            child: Banner(
              message: "未读",
              location: BannerLocation.bottomEnd,
              child: child,
            ),
          ),
        );
      } else {
        result = child;
      }

      return result;
    });
  }
}

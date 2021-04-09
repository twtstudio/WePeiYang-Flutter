import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/feedback/model/feedback_notifier.dart';
import 'package:wei_pei_yang_demo/lounge/provider/provider_widget.dart';
import 'package:wei_pei_yang_demo/message/message_provider.dart';

class FeedbackBannerWidget extends StatelessWidget {
  final int questionId;
  final Widget child;
  final bool showBanner;

  const FeedbackBannerWidget(
      {Key key, this.questionId, this.child, this.showBanner = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (showBanner) {
      return Consumer<MessageProvider>(builder: (__, model, _) {
        Widget result;
        if (model.inMessageList(questionId)) {
          result = Listener(
            onPointerDown: (_) => model.setFeedbackQuestionRead(questionId),
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
    }else {
      return child;
    }
  }
}

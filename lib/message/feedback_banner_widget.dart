import 'package:flutter/material.dart';
import 'package:provider/single_child_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wei_pei_yang_demo/feedback/model/feedback_notifier.dart';
import 'package:wei_pei_yang_demo/lounge/provider/provider_widget.dart';
import 'package:wei_pei_yang_demo/message/message_center.dart';
import 'package:wei_pei_yang_demo/message/message_provider.dart';

class FeedbackBannerWidget extends StatelessWidget {
  final int questionId;
  final bool showBanner;
  final Widget Function(VoidFutureCallBack tap) builder;

  const FeedbackBannerWidget(
      {Key key, this.questionId,  this.showBanner = false, this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (showBanner) {
      return Consumer<MessageProvider>(builder: (__, model, _) {
        Widget result;
        if (model.inMessageList(questionId)) {
          VoidFutureCallBack tap = () async {
            await model.setFeedbackQuestionRead(questionId);
          };
          result = ClipRect(
            child: Banner(
              message: "未读",
              location: BannerLocation.bottomEnd,
              child: builder(tap),
            ),
          );
        } else {
          result = builder(null);
        }

        return result;
      });
    } else {
      return builder(null);
    }
  }
}

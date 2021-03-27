import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/message/message_provider.dart';
import 'package:wei_pei_yang_demo/lounge/provider/provider_widget.dart';

enum FeedbackMessageType { detail_post, detail_favourite, home }

extension MessageData on FeedbackMessageType {
   int messageCount(MessageProvider model) {
    switch (this) {
      case FeedbackMessageType.detail_post:
        return model.feedbackQs.length;
        break;
      case FeedbackMessageType.detail_favourite:
        return model.feedbackFs.length;
        break;
      case FeedbackMessageType.home:
        return model.feedbackFs.length + model.feedbackQs.length;
        break;
      default:
        return 0;
    }
  }
}

class FeedbackBadgeWidget extends StatefulWidget {
  final Widget child;
  final FeedbackMessageType type;

  const FeedbackBadgeWidget({Key key, this.child, this.type}) : super(key: key);

  @override
  _FeedbackBadgeWidgetState createState() => _FeedbackBadgeWidgetState();
}

class _FeedbackBadgeWidgetState extends State<FeedbackBadgeWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProvider>(
      builder: (__, model, _) {
        if (model.isEmpty) {
          return widget.child;
        } else {
          return Badge(
            padding: EdgeInsets.all(4),
            badgeContent: Text(
              widget.type.messageCount(model).toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
            child: widget.child,
          );
        }
      },
    );
  }
}

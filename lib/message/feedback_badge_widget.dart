import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/lounge/provider/provider_widget.dart';
import 'package:we_pei_yang_flutter/message/model/message_provider.dart';

enum FeedbackMessageType { total, like, floor, reply, notice }

extension MessageData on FeedbackMessageType {
  String messageCount(MessageProvider model) {
    switch (this) {
      case FeedbackMessageType.like:
        return "";
        break;
      case FeedbackMessageType.floor:
        return model.messageCount.floor.toString();
        break;
      case FeedbackMessageType.reply:
        return model.messageCount.reply.toString();
        break;
      case FeedbackMessageType.notice:
        return model.messageCount.notice.toString();
        break;
      case FeedbackMessageType.total:
        return model.messageCount.total.toString();
        break;
      default:
        return '';
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
        if (model.isMessageEmptyOfType(widget.type)) {
          return widget.child;
        } else {
          var str = widget.type.messageCount(model);
          var padding = str.isEmpty ? 5.0 : 4.0;
          return Badge(
            padding: EdgeInsets.all(padding),
            badgeContent: Text(
              str,
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
            child: widget.child,
          );
        }
      },
    );
  }
}

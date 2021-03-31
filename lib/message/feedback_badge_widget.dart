import 'dart:async';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/message/message_provider.dart';
import 'package:wei_pei_yang_demo/lounge/provider/provider_widget.dart';

enum FeedbackMessageType { detail_post, detail_favourite, home, mailbox }

extension MessageData on FeedbackMessageType {
  String messageCount(MessageProvider model) {
    switch (this) {
      case FeedbackMessageType.detail_post:
        return "";
        break;
      case FeedbackMessageType.detail_favourite:
        return "";
        break;
      case FeedbackMessageType.home:
        return (model.feedbackFs.length + model.feedbackQs.length).toString();
        break;
      case FeedbackMessageType.mailbox:
        return model.totalMessageCount.toString();
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

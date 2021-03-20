import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/message/message_provider.dart';
import 'package:wei_pei_yang_demo/lounge/provider/provider_widget.dart';

class FeedbackBadgeWidget extends StatefulWidget {
  final Widget child;

  const FeedbackBadgeWidget({Key key, this.child}) : super(key: key);

  @override
  _FeedbackBadgeWidgetState createState() => _FeedbackBadgeWidgetState();
}

class _FeedbackBadgeWidgetState extends State<FeedbackBadgeWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProvider>(
      builder: (__, model, _) {
        if (model.feedbackCount == 0) {
          return widget.child;
        } else {
          return Badge(
            padding: EdgeInsets.all(4),
            badgeContent: Text(
              model.feedbackCount.toString(),
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

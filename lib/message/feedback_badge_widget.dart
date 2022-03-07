import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/lounge/provider/provider_widget.dart';
import 'package:we_pei_yang_flutter/message/model/message_provider.dart';

class FeedbackBadgeWidget extends StatefulWidget {
  final Widget child;

  const FeedbackBadgeWidget({Key key, this.child}) : super(key: key);

  @override
  _FeedbackBadgeWidgetState createState() => _FeedbackBadgeWidgetState();
}

class _FeedbackBadgeWidgetState extends State<FeedbackBadgeWidget> {
  @override
  Widget build(BuildContext context) {
    int count =
        context.select((MessageProvider messageProvider) => messageProvider.messageCount.total);
    return count == 0
        ? widget.child
        : Badge(
            padding: EdgeInsets.all(4),
            badgeContent: Text(
              count.toString(),
              style: TextStyle(color: Colors.white, fontSize: 7),
            ),
            child: widget.child,
          );
  }
}

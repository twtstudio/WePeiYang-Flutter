import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/message/model/message_provider.dart';

import '../commons/util/text_util.dart';

class FeedbackBadgeWidget extends StatefulWidget {
  final Widget child;

  const FeedbackBadgeWidget({Key? key, required this.child}) : super(key: key);

  @override
  _FeedbackBadgeWidgetState createState() => _FeedbackBadgeWidgetState();
}

class _FeedbackBadgeWidgetState extends State<FeedbackBadgeWidget> {
  @override
  Widget build(BuildContext context) {
    int count = context.select((MessageProvider messageProvider) =>
        messageProvider.messageCount.total);
    return count == 0
        ? widget.child
        : badges.Badge(
            badgeContent: Padding(
              padding: EdgeInsets.all(4),
              child: Text(
                count.toString(),
                style: TextUtil.base.white.sp(7),
              ),
            ),
            child: widget.child,
          );
  }
}

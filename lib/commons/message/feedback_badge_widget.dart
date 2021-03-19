import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/message/feedback_message_center.dart';
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
    return Consumer<FeedbackMessageNotifier>(
      builder: (__, model, _) {
        if (model.count == 0) {
          return widget.child;
        } else {
          return Badge(
            padding: EdgeInsets.all(4),
            badgeContent: Text(
              model.count.toString(),
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

class FeedbackMessageNotifier extends ChangeNotifier {
  factory FeedbackMessageNotifier() => _getInstance();

  FeedbackMessageNotifier._internal();

  static FeedbackMessageNotifier _instance;

  static FeedbackMessageNotifier _getInstance() {
    if (_instance == null) {
      _instance = FeedbackMessageNotifier._internal();
    }
    return _instance;
  }

  int count = 0;

  refreshFeedbackMessageCount() async {
    count = await FeedbackMessageCenter.getFeedbackMessageCount();
    notifyListeners();
  }
}

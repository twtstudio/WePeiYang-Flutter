import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:wei_pei_yang_demo/commons/message/feedback_badge_widget.dart';
import 'package:wei_pei_yang_demo/feedback/model/feedback_notifier.dart';

List<SingleChildWidget> feedbackProviders = [
  ChangeNotifierProvider<FeedbackNotifier>(
    create: (context) => FeedbackNotifier(),
  ),
  ChangeNotifierProvider<FeedbackMessageNotifier>(
    create: (context) =>
        FeedbackMessageNotifier()..refreshFeedbackMessageCount(),
  ),
];

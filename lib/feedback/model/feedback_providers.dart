import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/view/new_post_page.dart';

List<SingleChildWidget> feedbackProviders = [
  ChangeNotifierProvider<FbMainPageListProvider>(
    create: (context) => FbMainPageListProvider(),
  ),
  Provider.value(value: FbTagsProvider()),
  Provider.value(value: NewPostProvider()),
];

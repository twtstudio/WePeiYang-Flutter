import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/lounge/provider/provider_widget.dart';

List<SingleChildWidget> feedbackProviders = [
  Provider.value(value: FbTagsProvider()),
  Provider.value(value: NewPostProvider()),
  ChangeNotifierProvider.value(value: FbHotTagsProvider()),
  ChangeNotifierProvider.value(value: NewFloorProvider()),
  ChangeNotifierProvider.value(value: FbHomeListModel()),
  ChangeNotifierProxyProvider<FbHomeListModel, FbHomeStatusNotifier>(
    create: (_) => FbHomeStatusNotifier(),
    update: (_, homeList, homeStatus) => homeStatus..update(homeList),
  ),
];

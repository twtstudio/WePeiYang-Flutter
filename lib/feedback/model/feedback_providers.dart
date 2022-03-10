import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';

List<SingleChildWidget> feedbackProviders = [
  Provider.value(value: FbDepartmentsProvider()),
  Provider.value(value: NewPostProvider()),
  ChangeNotifierProvider.value(value: FbHotTagsProvider()),
  ChangeNotifierProvider.value(value: NewFloorProvider()),
  ChangeNotifierProvider.value(value: LakeModel()),
];

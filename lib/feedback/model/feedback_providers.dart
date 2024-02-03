import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/user_data.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';

import '../rating_page/modle/ui/page_switching_data.dart';
import '../rating_page/modle/rating/rating_page_data.dart';

List<SingleChildWidget> feedbackProviders = [
  Provider.value(value: FbDepartmentsProvider()),
  Provider.value(value: NewPostProvider()),
  ChangeNotifierProvider.value(value: ChangeHintTextProvider()),
  ChangeNotifierProvider.value(value: FbHotTagsProvider()),
  ChangeNotifierProvider.value(value: NewFloorProvider()),
  ChangeNotifierProvider.value(value: LakeModel()),
  ChangeNotifierProvider.value(value: FestivalProvider()),
  ChangeNotifierProvider.value(value: NoticeProvider()),

  ///以下为评分页面新增Provider
  ChangeNotifierProvider.value(value: PageSwitchingData()),
  ChangeNotifierProvider.value(value: RatingPageData()),
  ChangeNotifierProvider.value(value: RatingUserData())
];

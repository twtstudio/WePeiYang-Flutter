import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/edit_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam_provider.dart';

List<SingleChildWidget> scheduleProviders = [
  ChangeNotifierProvider(create: (_) => CourseProvider()),
  ChangeNotifierProvider(create: (_) => CourseDisplayProvider()),
  ChangeNotifierProvider(create: (_) => ExamProvider()),
  ChangeNotifierProvider(create: (_) => EditProvider()),
];

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';

import 'app_settings_widgets.dart';

class ScheduleSettingPage extends StatefulWidget {
  const ScheduleSettingPage({super.key});

  @override
  State<ScheduleSettingPage> createState() => _ScheduleSettingPageState();
}

class _ScheduleSettingPageState extends State<ScheduleSettingPage> {
  static const _dayLabels = ['周一至周五', '周一至周六', '周一至周日'];

  @override
  Widget build(BuildContext context) {
    final display = context.watch<CourseDisplayProvider>();
    final includeCustomCourseHours = context.select(
      (CourseProvider provider) => provider.includeCustomCourseHours,
    );
    final selectedDays = CommonPreferences.dayNumber.value;

    return AppSettingsPage(
      title: '课程表设置',
      children: [
        AppSettingsSection(
          children: [
            AppSettingsToggle(
              title: '开启夜猫子模式',
              subtitle: '晚上 9 点后，首页显示第二天的课程安排',
              value: display.nightMode,
              onChanged: (value) => display.nightMode = value,
            ),
            AppSettingsToggle(
              title: '实验课显示详细内容',
              subtitle: '如果课表显示异常，可以关闭此选项',
              value: display.showExperiment,
              onChanged: (value) => display.showExperiment = value,
            ),
            AppSettingsToggle(
              title: '自定义课程计入学时统计',
              value: includeCustomCourseHours,
              onChanged: (value) {
                context.read<CourseProvider>().includeCustomCourseHours = value;
              },
            ),
          ],
        ),
        SizedBox(height: 16.h),
        AppSettingsSection(
          title: '每周显示天数',
          children: [
            for (var days = 5; days <= 7; days++)
              Semantics(
                selected: selectedDays == days,
                child: AppSettingsRow(
                  title: '$days 天',
                  subtitle: _dayLabels[days - 5],
                  trailing: selectedDays == days
                      ? Icon(
                          Icons.check,
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.primaryActionColor),
                        )
                      : null,
                  onTap: () =>
                      setState(() => CommonPreferences.dayNumber.value = days),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/auth/auth_router.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/gpa/model/gpa_notifier.dart';

import 'app_settings_widgets.dart';

class HomeDisplaySettingPage extends StatefulWidget {
  const HomeDisplaySettingPage({super.key});

  @override
  State<HomeDisplaySettingPage> createState() => _HomeDisplaySettingPageState();
}

class _HomeDisplaySettingPageState extends State<HomeDisplaySettingPage> {
  @override
  Widget build(BuildContext context) {
    return AppSettingsPage(
      title: '主页展示定制',
      children: [
        AppSettingsSection(
          children: [
            AppSettingsToggle(
              title: '主页显示校园地图和校历',
              value: CommonPreferences.showMap.value,
              onChanged: (value) {
                setState(() => CommonPreferences.showMap.value = value);
              },
            ),
            AppSettingsToggle(
              title: '主页显示 GPA',
              value: !CommonPreferences.hideGPA.value,
              onChanged: (value) {
                setState(() => context.read<GPANotifier>().hideGPA = !value);
              },
            ),
            AppSettingsToggle(
              title: '底栏显示小天老师',
              value: CommonPreferences.showXiaotianTab.value,
              onChanged: (value) {
                setState(() {
                  CommonPreferences.showXiaotianTab.value = value;
                  CommonPreferences.showXiaotianTabNotifier.value = value;
                });
              },
            ),
            AppSettingsLink(
              title: '论坛分区顺序',
              subtitle: '拖动调整湖底、校务等分区',
              onTap: () =>
                  Navigator.pushNamed(context, AuthRouter.feedbackTabOrder),
            ),
          ],
        ),
      ],
    );
  }
}

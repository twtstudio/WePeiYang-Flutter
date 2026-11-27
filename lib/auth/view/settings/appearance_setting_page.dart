import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/auth/auth_router.dart';
import 'package:we_pei_yang_flutter/commons/font/font_reload_sheet.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';

import 'app_settings_widgets.dart';

class AppearanceSettingPage extends StatefulWidget {
  const AppearanceSettingPage({super.key});

  @override
  State<AppearanceSettingPage> createState() => _AppearanceSettingPageState();
}

class _AppearanceSettingPageState extends State<AppearanceSettingPage> {
  @override
  Widget build(BuildContext context) {
    return AppSettingsPage(
      title: '主题与外观',
      children: [
        AppSettingsSection(
          children: [
            AppSettingsLink(
              title: '主题设置',
              subtitle: WpyTheme.of(context).name,
              onTap: () =>
                  Navigator.pushNamed(context, AuthRouter.themeSetting),
            ),
            AppSettingsLink(
              title: '高级编辑导航栏',
              subtitle: '添加、排序或重置首页工具',
              onTap: () =>
                  Navigator.pushNamed(context, AuthRouter.toolbarManage),
            ),
            AppSettingsLink(
              title: '重新加载字体文件',
              subtitle: '查看下载进度与文件位置',
              onTap: () => showFontReloadSheet(context),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        AppSettingsSection(
          title: '大屏布局',
          children: [
            AppSettingsToggle(
              title: '平行视界',
              subtitle: '宽屏下在右侧分栏打开详情页',
              value: CommonPreferences.parallelView.value,
              onChanged: (value) {
                setState(() {
                  CommonPreferences.parallelView.value = value;
                  CommonPreferences.parallelViewNotifier.value = value;
                });
              },
            ),
            if (Platform.isAndroid)
              AppSettingsToggle(
                title: '强制允许旋转',
                subtitle: '开启后手机也可以横屏',
                value: CommonPreferences.allowRotation.value,
                onChanged: (value) {
                  setState(() {
                    CommonPreferences.allowRotation.value = value;
                    CommonPreferences.allowRotationNotifier.value = value;
                  });
                },
              ),
          ],
        ),
      ],
    );
  }
}

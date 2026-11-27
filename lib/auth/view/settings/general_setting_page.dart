import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/auth/auth_router.dart';
import 'package:we_pei_yang_flutter/commons/channel/push/push_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/storage_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

import 'app_settings_widgets.dart';

class GeneralSettingPage extends StatefulWidget {
  const GeneralSettingPage({super.key});

  @override
  State<GeneralSettingPage> createState() => _GeneralSettingPageState();
}

class _GeneralSettingPageState extends State<GeneralSettingPage> {
  late Future<int> _cacheSize;
  bool _clearingCache = false;

  @override
  void initState() {
    super.initState();
    _cacheSize = StorageUtil.getTemporaryCacheSize();
  }

  String _formatCacheSize(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = bytes.toDouble();
    var unit = 0;
    while (size >= 1024 && unit < units.length - 1) {
      size /= 1024;
      unit++;
    }
    return '${size.toStringAsFixed(unit == 0 ? 0 : 1)} ${units[unit]}';
  }

  Future<void> _clearCache() async {
    setState(() => _clearingCache = true);
    ToastProvider.running('正在清除缓存...');
    try {
      final cleared = await StorageUtil.clearTemporaryCache();
      if (cleared) {
        ToastProvider.success('应用缓存已清除');
      } else {
        ToastProvider.error('部分缓存正在使用，未能完全清除');
      }
    } catch (e) {
      ToastProvider.error('清除缓存失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _clearingCache = false;
          _cacheSize = StorageUtil.getTemporaryCacheSize();
        });
      }
    }
  }

  void _changePush(bool value) {
    final pushManager = context.read<PushManager>();
    if (value) {
      pushManager.turnOnPushService(
        () => ToastProvider.success('开启推送成功'),
        () => ToastProvider.success('开启推送需要通知权限'),
        () => ToastProvider.error('打开失败'),
      );
    } else {
      pushManager.turnOffPushService(
        () => ToastProvider.success('关闭推送成功'),
        () => ToastProvider.error('关闭失败'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final openPush = context.select((PushManager manager) => manager.openPush);
    return AppSettingsPage(
      title: '应用设置',
      children: [
        AppSettingsSection(
          title: '外观与主页',
          children: [
            AppSettingsLink(
              title: '主题与外观',
              subtitle: '主题、导航栏自定义、字体文件',
              onTap: () =>
                  Navigator.pushNamed(context, AuthRouter.appearanceSetting),
            ),
            AppSettingsLink(
              title: '主页展示定制',
              subtitle: '地图校历、GPA、小天老师、分区顺序',
              onTap: () =>
                  Navigator.pushNamed(context, AuthRouter.homeDisplaySetting),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        AppSettingsSection(
          title: '课程表',
          children: [
            AppSettingsLink(
              title: '课程表设置',
              subtitle: '夜猫子模式、实验课、天数',
              onTap: () =>
                  Navigator.pushNamed(context, AuthRouter.scheduleSetting),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        AppSettingsSection(
          title: '通知与体验',
          children: [
            AppSettingsToggle(
              title: '消息通知',
              subtitle: '论坛与信箱推送',
              value: openPush,
              onChanged: _changePush,
            ),
            AppSettingsLink(
              title: '动画',
              subtitle: '动画速度、返回动画',
              onTap: () =>
                  Navigator.pushNamed(context, AuthRouter.animationSetting),
            ),
          ],
        ),
        SizedBox(height: 32.h),
        AppSettingsSection(
          children: [
            FutureBuilder<int>(
              future: _cacheSize,
              builder: (context, snapshot) => AppSettingsLink(
                title: '清除应用缓存',
                subtitle: '清除所有临时缓存',
                value: snapshot.hasData
                    ? _formatCacheSize(snapshot.data!)
                    : '—',
                onTap: _clearingCache ? null : _clearCache,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/local/animation_provider.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';

import 'app_settings_widgets.dart';

class AnimationSettingPage extends StatefulWidget {
  const AnimationSettingPage({super.key});

  @override
  State<AnimationSettingPage> createState() => _AnimationSettingPageState();
}

class _AnimationSettingPageState extends State<AnimationSettingPage> {
  static const _deviceChannel = MethodChannel('com.twt.service/device_info');
  static const _speeds = [0.1, 0.5, 1.0, 1.5, 2.0];
  static const _speedNames = ['极快', '较快', '正常', '较慢', '极慢'];

  bool _supportsPredictiveBack = false;

  @override
  void initState() {
    super.initState();
    _checkPredictiveBack();
  }

  Future<void> _checkPredictiveBack() async {
    if (!Platform.isAndroid) return;
    try {
      final info = await _deviceChannel.invokeMethod<Map>('getDeviceInfo');
      final sdkInt = int.tryParse('${info?['sdkInt']}') ?? 0;
      if (mounted && sdkInt >= 34) {
        setState(() => _supportsPredictiveBack = true);
      }
    } catch (_) {
      // 获取不到系统版本时不显示该选项。
    }
  }

  @override
  Widget build(BuildContext context) {
    final animation = context.watch<AnimationProvider>();
    final speedIndex = animation.speedIndex;
    return AppSettingsPage(
      title: '动画',
      children: [
        AppSettingsSection(
          children: [
            AppSettingsRow(
              title: '动画速度',
              subtitle: _speedNames[speedIndex],
              trailing: SizedBox(
                width: 152.w,
                child: Slider(
                  value: speedIndex.toDouble(),
                  max: (_speeds.length - 1).toDouble(),
                  divisions: _speeds.length - 1,
                  label: _speedNames[speedIndex],
                  semanticFormatterCallback: (value) =>
                      _speedNames[value.round()],
                  activeColor: WpyTheme.of(context).primary,
                  onChanged: (value) {
                    final index = value.round();
                    animation.speed = _speeds[index];
                    animation.speedIndex = index;
                    timeDilation = _speeds[index];
                  },
                ),
              ),
            ),
            if (_supportsPredictiveBack)
              AppSettingsToggle(
                title: '预见性返回动画',
                subtitle: '实验性功能，仅在 Android 14 及以上生效',
                value: CommonPreferences.predictiveBack.value,
                onChanged: (value) {
                  setState(() {
                    CommonPreferences.predictiveBack.value = value;
                    CommonPreferences.predictiveBackNotifier.value = value;
                  });
                },
              ),
          ],
        ),
      ],
    );
  }
}

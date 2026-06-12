import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/test/test_router.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';

class TestMainPage extends StatelessWidget {
  const TestMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
      appBar: AppBar(title: const Text('测试主页')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(context, '推送测试', 'Push 通知、Intent 测试', TestRouter.pushTest),
          _card(context, '更新测试', 'APK/SO 清理、检查更新', TestRouter.updateTest),
          _card(context, '求实论坛测试', 'Token 获取、接口测试', TestRouter.qsltTest),
          _card(context, '字体测试', 'PingFang / Noto 字体', TestRouter.fontTest),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, String title, String desc, String route) {
    final bg = WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor);
    final textColor = WpyTheme.of(context).get(WpyColorKey.basicTextColor);
    final subColor = WpyTheme.of(context).get(WpyColorKey.secondaryTextColor);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.pushNamed(context, route),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
                      const SizedBox(height: 4),
                      Text(desc, style: TextStyle(fontSize: 12, color: subColor)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: subColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

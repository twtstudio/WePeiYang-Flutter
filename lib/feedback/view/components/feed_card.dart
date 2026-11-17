import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';

/// 多列（瀑布流）帖子列表中的卡片：圆角 + 细边框，与相邻帖子区分开。
/// 湖底首页和个人主页共用，保证多栏下效果一致。单列时不需要包裹。
class FeedCard extends StatelessWidget {
  const FeedCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // 折叠的置顶帖等空占位不需要卡片
    final c = child;
    if (c is SizedBox && c.height == 0) return c;
    final theme = WpyTheme.of(context);
    final radius = BorderRadius.circular(16.r);
    return Container(
      decoration: BoxDecoration(
        color: theme.get(WpyColorKey.primaryBackgroundColor),
        borderRadius: radius,
      ),
      // 边框画在内容之上，避免被帖子自身的背景盖住
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: theme.get(WpyColorKey.lightBorderColor)),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

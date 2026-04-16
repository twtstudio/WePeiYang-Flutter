import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/streak/streak_router.dart';

class DailyProgressPage extends StatelessWidget {
  final int days;
  final List<Map<String, dynamic>> tasks;

  const DailyProgressPage({Key? key, this.days = 0, this.tasks = const []}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = WpyTheme.of(context).get(WpyColorKey.primaryActionColor);
    // ensure enough bottom spacing for devices with navigation bars
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20.h, bottom: 30.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primaryColor.withOpacity(0.3), Colors.transparent],
                ),
              ),
              child: Column(
                children: [
                  //todo
                  Text('#用户名 的北洋圆', style: TextUtil.base.bold.sp(22).copyWith(color: Colors.black87)),
                  SizedBox(height: 30.h),
                  // 环形进度条
                  SizedBox(
                    height: 200.w,
                    width: 200.w,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: Size(200.w, 200.w),
                          painter: _StaticProgressPainter(color: primaryColor, progress: 0.67),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //todo
                            Text('67%', style: TextUtil.base.bold.sp(48).copyWith(color: Colors.black87)),
                            Text('今日进度', style: TextUtil.base.regular.sp(14).copyWith(color: Colors.black54)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 25.h),
                  Text('继续合上圆环', style: TextUtil.base.bold.sp(16).copyWith(color: Colors.black87)),
                  SizedBox(height: 5.h),
                  //todo
                  Text('你已完成今日打卡计划的 2/3，保持这种节奏。',
                      textAlign: TextAlign.center,
                      style: TextUtil.base.regular.sp(13).copyWith(color: Colors.black54)
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('任务列表', style: TextUtil.base.bold.sp(18).copyWith(color: Colors.black87)),
                      //todo 应该跳转到任务设置界面
                      Text('全部任务 ▼', style: TextUtil.base.medium.sp(14).copyWith(color: primaryColor)),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  // Use tasks passed from TaskSelectionPage. If empty, show a placeholder.
                  if (tasks.isEmpty)
                    Column(
                      children: [
                        SizedBox(height: 30.h),
                        Text('暂无任务', style: TextUtil.base.regular.sp(14).copyWith(color: Colors.black54)),
                        SizedBox(height: 20.h),
                      ],
                    )
                  else
                    Column(
                      children: tasks.map((t) {
                        final IconData icon = (t['icon'] is IconData) ? t['icon'] as IconData : Icons.task;
                        final String title = (t['title'] as String?) ?? '';
                        final String subtitle = (t['description'] as String?) ?? '';
                        //todo 这里的完成状态应该从接口获取，目前先假设都未完成
                        final bool isDone = false;

                        return _buildTaskCard(
                          context,
                          icon,
                          title,
                          subtitle,
                          isDone,
                          //todo 上传的接口
                          onUpload: !isDone
                              ? () => showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
                                    builder: (c) => SizedBox(
                                      height: 220.h,
                                      child: Center(child: Text('上传: $title', style: TextUtil.base.regular.sp(16))),
                                    ),
                                  )
                              : null,
                        );
                      }).toList(),
                    ),
                  SizedBox(height: 20.h),
                  // 底部入口
                  Row(
                    children: [
                      Expanded(child: _buildBottomNavCard(context, Icons.show_chart, '14', '打卡记录', () => Navigator.pushNamed(context, StreakRouter.streakRecordPage))),
                      SizedBox(width: 15.w),
                      Expanded(child: _buildBottomNavCard(context, Icons.star_border, '892', '数字证书', () => Navigator.pushNamed(context, StreakRouter.certificatePage))),
                    ],
                  ),
                  // 保证底部预留，避免被导航栏遮挡
                  SizedBox(height: 40.h + bottomPadding + 8.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a task card. If [isDone] is false and [onUpload] is provided,
  /// the "上传记录" area becomes a tappable button that calls [onUpload].
  Widget _buildTaskCard(BuildContext context, IconData icon, String title, String subtitle, bool isDone, {VoidCallback? onUpload}) {
    final primaryColor = WpyTheme.of(context).get(WpyColorKey.primaryActionColor);
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(color: isDone ? primaryColor.withOpacity(0.1) : const Color(0xFFF5F5F5), shape: BoxShape.circle),
            child: Icon(icon, color: isDone ? primaryColor : Colors.grey[600], size: 24.r),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextUtil.base.bold.sp(16).copyWith(color: Colors.black87)),
                SizedBox(height: 2.h),
                Text(subtitle, style: TextUtil.base.regular.sp(12).copyWith(color: Colors.black54)),
              ],
            ),
          ),
          if (isDone)
            Container(
              width: 60.w, height: 40.h,
              decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(20.r)),
              child: Icon(Icons.check, color: Colors.white, size: 24.r),
            )
          else
            // when onUpload is provided, make the area a tappable button
            (onUpload != null)
                ? WButton(
                    onPressed: onUpload,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(20.r)),
                      child: Text('上传记录', style: TextUtil.base.medium.sp(12).copyWith(color: Colors.grey[600])),
                    ),
                  )
                : const SizedBox.shrink()
        ],
      ),
    );
  }

  Widget _buildBottomNavCard(BuildContext context, IconData icon, String count, String title, VoidCallback onTap) {
    return WButton(
      onPressed: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor), size: 24.r),
            SizedBox(height: 10.h),
            Text(count, style: TextUtil.base.bold.sp(20).copyWith(color: Colors.black87)),
            Text(title, style: TextUtil.base.regular.sp(12).copyWith(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class _StaticProgressPainter extends CustomPainter {
  final Color color;
  final double progress;

  _StaticProgressPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 12.0;
    final double radius = (size.width - strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()..color = Colors.grey[200]!..style = PaintingStyle.stroke..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()..color = color..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeWidth = strokeWidth;
    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
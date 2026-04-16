import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';

import '../streak_router.dart';

class TaskSelectionPage extends StatefulWidget {
  final int days;
  const TaskSelectionPage({Key? key, required this.days}) : super(key: key);

  @override
  State<TaskSelectionPage> createState() => _TaskSelectionPageState();
}

class _TaskSelectionPageState extends State<TaskSelectionPage> {
  final List<Map<String, dynamic>> _tasks = [
    {
      'title': '晨起饮水',
      'description': '每日唤醒身体第一步',
      'icon': Icons.water_drop,
      'enabled': false,
      'isCustom': false, // 标记为内置
    },
    {
      'title': '专注阅读',
      'description': '每日读书20分钟',
      'icon': Icons.book,
      'enabled': false,
      'isCustom': false,
    },
    {
      'title': '每日锻炼',
      'description': '20分钟体育运动',
      'icon': Icons.fitness_center,
      'enabled': false,
      'isCustom': false,
    },
    {
      'title': '早睡早起',
      'description': '23:00前放下电子设备',
      'icon': Icons.nights_stay,
      'enabled': false,
      'isCustom': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final Gradient primaryGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
        WpyTheme.of(context)
            .get(WpyColorKey.primaryActionColor)
            .withOpacity(0.6),
      ],
    );
    // 为底部保留设备导航栏高度，避免内容被遮挡
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.4],
              colors: [
                WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
                Colors.white,
              ],
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Column(
                  children: [
                    Text(
                      '选择你的打卡任务',
                      style: TextUtil.base.bold.sp(28).copyWith(
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '文案文案',
                      style: TextUtil.base.regular.sp(16).copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: _tasks.length + 1,
                  itemBuilder: (context, index) {
                    if (index < _tasks.length) {
                      final task = _tasks[index];
                      return _buildTaskCard(task, index);
                    } else {
                      return _buildAddCustomHabitButton();
                    }
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 30.h + bottomPadding + 8.h),
                child: Column(
                  children: [
                    WButton(
                      onPressed: () => Navigator.pop(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chevron_left, color: Colors.grey, size: 20.r),
                          Text(
                            '返回上级',
                            style: TextUtil.base.regular.sp(14).copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.h),
                    WButton(
                      onPressed: () {
                        // Only pass tasks that are enabled
                        final enabledTasks = _tasks.where((t) => t['enabled'] == true).toList();
                        Navigator.pushNamed(
                          context,
                          StreakRouter.dailyProgressPage,
                          arguments: {
                            'days': widget.days,
                            'tasks': enabledTasks,
                          },
                        );
                        // 确认逻辑
                      },
                      child: Container(
                        width: double.infinity,
                        height: 55.h,
                        decoration: BoxDecoration(
                          gradient: primaryGradient,
                          borderRadius: BorderRadius.circular(30.r),
                          boxShadow: [
                            BoxShadow(
                              color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '确认开启',
                          style: TextUtil.base.bold.sp(18).copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50.r,
            height: 50.r,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Icon(task['icon'], color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor), size: 28.r),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'],
                  style: TextUtil.base.bold.sp(18).copyWith(color: Colors.black87),
                ),
                SizedBox(height: 4.h),
                Text(
                  task['description'],
                  style: TextUtil.base.regular.sp(14).copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
          // 如果是自定义任务，则显示删除按钮
          if (task['isCustom'] == true)
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[300], size: 22.r),
              onPressed: () {
                setState(() {
                  _tasks.removeAt(index);
                });
              },
            ),
          CupertinoSwitch(
            value: task['enabled'],
            activeColor: WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
            onChanged: (value) {
              setState(() {
                _tasks[index]['enabled'] = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddCustomHabitButton() {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      height: 70.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9).withOpacity(0.5),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: CustomPaint(
        painter: _DashedBorderPainter(color: Colors.grey.withOpacity(0.5)),
        child: InkWell(
          onTap: () {
            _showAddHabitBottomSheet(context);
          },
          borderRadius: BorderRadius.circular(15.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: 1.5),
                ),
                child: Icon(Icons.add, color: Colors.grey, size: 16.r),
              ),
              SizedBox(width: 10.w),
              Text(
                '添加自定义习惯',
                style: TextUtil.base.medium.sp(16).copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddHabitBottomSheet(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final Gradient primaryGradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
            WpyTheme.of(context)
                .get(WpyColorKey.primaryActionColor)
                .withOpacity(0.6),
          ],
        );

        return SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            // only account for keyboard inset here; SafeArea will handle system bottom padding
            padding: EdgeInsets.fromLTRB(
              25.w,
              15.h,
              25.w,
              MediaQuery.of(context).viewInsets.bottom + 30.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 25.h),
                // Header
                Text(
                  '添加自定义习惯',
                  style: TextUtil.base.bold.sp(22).copyWith(color: Colors.black87),
                ),
                SizedBox(height: 8.h),
                Text(
                  '开始新的自律计划, 保持你的节奏',
                  style:
                      TextUtil.base.regular.sp(14).copyWith(color: Colors.black54),
                ),
                SizedBox(height: 30.h),
                // Name Input
                Text(
                  '打卡任务名称',
                  style:
                      TextUtil.base.medium.sp(14).copyWith(color: Colors.black45),
                ),
                SizedBox(height: 10.h),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: '例如: 每天喝八杯水',
                      hintStyle: TextUtil.base.regular
                          .sp(15)
                          .copyWith(color: Colors.black26),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                // Description Input
                Text(
                  '打卡任务描述',
                  style:
                      TextUtil.base.medium.sp(14).copyWith(color: Colors.black45),
                ),
                SizedBox(height: 10.h),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: '给自己一点动力或说明执行细节...',
                      hintStyle: TextUtil.base.regular
                          .sp(15)
                          .copyWith(color: Colors.black26),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                // Confirm Button
                WButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      setState(() {
                        _tasks.add({
                          'title': nameController.text.trim(),
                          'description': descController.text.trim(),
                          'icon': Icons.stars, // 默认图标
                          'enabled': true,
                          'isCustom': true,
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 55.h,
                    decoration: BoxDecoration(
                      gradient: primaryGradient,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '确认添加',
                      style:
                          TextUtil.base.bold.sp(18).copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final double dashWidth = 5;
    final double dashSpace = 3;
    final double radius = 15.r;

    final RRect rRect = RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(radius));
    final Path path = Path()..addRRect(rRect);

    final Path dashedPath = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

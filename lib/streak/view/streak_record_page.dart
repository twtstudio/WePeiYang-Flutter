import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';

class StreakRecordPage extends StatelessWidget {
  const StreakRecordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = WpyTheme.of(context).get(WpyColorKey.primaryActionColor);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: WButton(
          child: Icon(Icons.arrow_back, color: Colors.black87, size: 28.r),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('打卡记录', style: TextUtil.base.bold.sp(28).copyWith(color: Colors.black87)),
            Text('查看你的坚持轨迹', style: TextUtil.base.regular.sp(14).copyWith(color: Colors.black54)),
            SizedBox(height: 20.h),

            // 统计卡片 Row - 使用 IntrinsicHeight + CrossAxisAlignment.stretch
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('累计坚持', style: TextUtil.base.medium.sp(14).copyWith(color: Colors.black54)),
                          SizedBox(height: 5.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              //todo 这里的数字应该从接口里来
                              Text('42', style: TextUtil.base.bold.sp(32).copyWith(color: Colors.black87)),
                              Padding(padding: EdgeInsets.only(bottom: 6.h, left: 2.w), child: Text('天', style: TextUtil.base.regular.sp(15))),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Row(children: [
                            Icon(Icons.circle, size: 8.r, color: primaryColor), SizedBox(width: 4.w),
                            Icon(Icons.circle, size: 8.r, color: primaryColor.withOpacity(0.5)), SizedBox(width: 4.w),
                            Icon(Icons.circle, size: 8.r, color: Colors.grey[300]),
                          ])
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('当前连续', style: TextUtil.base.medium.sp(14).copyWith(color: Colors.black54)),
                          SizedBox(height: 5.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            //todo 这里的数字应该从接口里来
                            children: [
                              Text('12', style: TextUtil.base.bold.sp(32).copyWith(color: primaryColor)),
                              Padding(padding: EdgeInsets.only(bottom: 6.h, left: 2.w), child: Text('天', style: TextUtil.base.regular.sp(15))),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Text('你的坚持正变得顺畅更加充满规律', style: TextUtil.base.regular.sp(12).copyWith(color: Colors.black45)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // 柱状图面板
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primaryColor.withOpacity(0.8), primaryColor]),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('本周完成度', style: TextUtil.base.bold.sp(16).copyWith(color: Colors.white)),
                  //todo 这里的完成度应该计算一下
                  Text('完成了 85% 的计划目标', style: TextUtil.base.regular.sp(12).copyWith(color: Colors.white70)),
                  SizedBox(height: 25.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //todo 这里的柱状图数据应该从接口里来
                    children: [
                      _buildBar(0.4), _buildBar(0.7),_buildBar(0.4), _buildBar(0.5), _buildBar(0.9), _buildBar(0.3), _buildBar(0.2),
                      Padding(
                        padding: EdgeInsets.only(bottom: 5.h),
                        //todo 这里的评价应该根据完成度判断
                        child: Text('Excellent', style: TextUtil.base.bold.sp(22).copyWith(color: Colors.white)),
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 25.h),

            // 日历面板（动态，根据设备时间显示当前月，可切换上月/下月，并高亮今日）
            SizedBox(height: 10.h),
            CalendarWidget(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(double percent) {
    return Container(
      width: 12.w,
      height: 60.h * percent,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6.r)),
    );
  }
}

// 新增：一个简单的可切换月份的日历组件，默认以周一为起始日，当前日期会高亮。
class CalendarWidget extends StatelessWidget {
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = WpyTheme.of(context).get(WpyColorKey.primaryActionColor);
    final today = DateTime.now();

    // calculate Monday as start of current week
    final int weekday = today.weekday; // 1=Mon..7=Sun
    final DateTime monday = today.subtract(Duration(days: weekday - 1));

    final weekdays = ['一', '二', '三', '四', '五', '六', '日'];

    // build header (显示当前年月)
    final header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${today.year}年 ${today.month}月', style: TextUtil.base.bold.sp(18).copyWith(color: Colors.black87)),
        // no month navigation, showing only current week
        SizedBox.shrink(),
      ],
    );

    // weekday labels and single week row rendered with a Table to keep stable child order
    final List<Widget> labelCells = weekdays
        .map((w) => Center(key: ValueKey('label-$w'), child: Text('周$w', style: TextUtil.base.regular.sp(12).copyWith(color: Colors.black45))))
        .toList();

    final List<Widget> dayCells = List.generate(7, (i) {
      final d = monday.add(Duration(days: i));
      final bool isToday = d.year == today.year && d.month == today.month && d.day == today.day;

      return Center(
        key: ValueKey('day-${d.year}-${d.month}-${d.day}'),
        child: Container(
          width: 36.w,
          height: 36.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            //todo 现在只是当天非透明，后面应该改成已打卡也为透明 吧
            color: isToday ? primaryColor.withOpacity(0.4) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text('${d.day}', style: TextUtil.base.regular.sp(14).copyWith(color: isToday ? primaryColor : Colors.black87)),
        ),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        SizedBox(height: 12.h),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
            4: FlexColumnWidth(1),
            5: FlexColumnWidth(1),
            6: FlexColumnWidth(1),
          },
          children: [
            TableRow(children: labelCells.map((w) => Padding(padding: EdgeInsets.symmetric(vertical: 6.h), child: w)).toList()),
            TableRow(children: dayCells.map((w) => Padding(padding: EdgeInsets.symmetric(vertical: 4.h), child: w)).toList()),
          ],
        ),
      ],
    );
  }
}
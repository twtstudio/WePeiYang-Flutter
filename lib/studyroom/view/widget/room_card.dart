import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_models.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_provider.dart';
import 'package:we_pei_yang_flutter/studyroom/util/time_util.dart';

class RoomStateText extends StatelessWidget {
  final Classroom room;
  final bool onlyCurrent;

  RoomStateText(this.room, {Key? key, this.onlyCurrent = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 这里用Consumer的原因是，只要更改时间，就要检查教室是否使用
    return Consumer<StudyroomProvider>(
      builder: (_, provider, __) {
        int currentDay;
        ClassTimerange timeRange;

        // 首页只展示当前时段
        if (onlyCurrent) {
          currentDay = DateTime.now().weekday;
          timeRange = ClassTimerangeExtension.current();
        }
        // 否则跟随时间变化
        else {
          currentDay = provider.dateTime.weekday;
          timeRange = provider.timeRange;
        }
        final currentPlan = room.statuses[currentDay]!;
        final available = Time.availableNow(currentPlan, timeRange);
        Widget stateDot;

        Widget stateText;

        if (available) {
          stateDot = Container(
            width: 6.w,
            height: 6.w,
            decoration: const BoxDecoration(
              color: ColorUtil.green5CColor,
              shape: BoxShape.circle,
            ),
          );

          stateText =
              Text('空闲', style: TextUtil.base.PingFangSC.w400.green5C.sp(10));
        } else {
          stateDot = Container(
            width: 6.w,
            height: 6.w,
            decoration: const BoxDecoration(
              color: Color(0xFFD9534F),
              shape: BoxShape.circle,
            ),
          );

          stateText =
              Text('占用', style: TextUtil.base.PingFangSC.w400.redD9.sp(10));
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            stateDot,
            SizedBox(width: 3.w),
            stateText,
          ],
        );
      },
    );
  }
}

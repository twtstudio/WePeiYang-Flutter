// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/lounge/provider/config_provider.dart';
import 'package:we_pei_yang_flutter/lounge/model/classroom.dart';
import 'package:we_pei_yang_flutter/lounge/util/time_util.dart';

class RoomState extends StatelessWidget {
  final Classroom room;

  const RoomState(this.room, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 这里用Consumer的原因是，只要更改时间，就要检查教室是否使用
    return Consumer<LoungeConfig>(
      builder: (_, provider, __) {
        final currentDay = provider.dateTime.weekday;
        final timeRange = provider.timeRange;
        final currentPlan = room.statuses[currentDay]!;
        final available = Time.availableNow(currentPlan, timeRange);
        Widget stateDot;

        Widget stateText;

        if (available) {
          stateDot = Container(
            width: 6.w,
            height: 6.w,
            decoration: const BoxDecoration(
              color: Colors.lightGreen,
              shape: BoxShape.circle,
            ),
          );

          stateText = Text(
            '空闲',
            style: TextStyle(
              color: Colors.lightGreen,
              fontSize: 9.sp,
              fontWeight: FontWeight.bold,
            ),
          );
        } else {
          stateDot = Container(
            width: 6.w,
            height: 6.w,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          );

          stateText = Text(
            '占用',
            style: TextStyle(
              color: Colors.red,
              fontSize: 9.sp,
              fontWeight: FontWeight.bold,
            ),
          );
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

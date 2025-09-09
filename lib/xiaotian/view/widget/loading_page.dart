import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



class historyLoading extends StatelessWidget {
  const historyLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: Image.asset(
              'assets/images/ai/history_loading.png',
              width: 360.w,
              height: 570.h,
            ),
          ),
        ),
      ],
    );
  }
}

class HistoryState extends StatefulWidget {
  const HistoryState({super.key});

  @override
  State<HistoryState> createState() => _HistoryStateState();
}

class _HistoryStateState extends State<HistoryState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        holderBubble(context, 121, 38, Alignment.centerRight, _controller),
        SizedBox(height: 8.h),
        holderBubble(context, 360, 120, Alignment.centerLeft, _controller),
        holderBubble(context, 360, 60, Alignment.centerLeft, _controller),
        holderBubble(context, 120, 37, Alignment.centerLeft, _controller),
        SizedBox(height: 8.h),
        holderBubble(context, 121, 38, Alignment.centerRight, _controller),
      ],
    );
  }
}

Widget holderBubble(BuildContext context, double width, double height,
    AlignmentGeometry align, AnimationController controller) {
  return Align(
    alignment: align,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              final opacity = 0.1 + 0.4 * controller.value; // 在 0.4~0.7 之间变动
              return Container(
                width: width.w,
                height: height.h,
                margin: EdgeInsets.symmetric(vertical: 10.h),
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(opacity), // 灰色闪烁
                  borderRadius: BorderRadius.circular(10.r),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

Widget mainLoad() {
  return Center(
    child: SizedBox(
      width: 20.w,
      height: 20.h,
      child: CircularProgressIndicator(),
    ),
  );
}
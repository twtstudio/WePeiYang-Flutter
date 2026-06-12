import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';

class historyLoading extends StatelessWidget {
  const historyLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const AiSkeletonPage();
  }
}

class AiSkeletonPage extends StatelessWidget {
  const AiSkeletonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(28.w, 80.h, 28.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SkeletonLine(width: 170.w, height: 26.h),
          SizedBox(height: 42.h),
          _SkeletonCard(height: 84.h),
          SizedBox(height: 14.h),
          _SkeletonCard(height: 84.h),
          SizedBox(height: 14.h),
          _SkeletonCard(height: 84.h),
          SizedBox(height: 34.h),
          Align(
            alignment: Alignment.centerRight,
            child: _SkeletonCard(width: 210.w, height: 58.h),
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({this.width, required this.height});

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return _SkeletonBox(
      width: width,
      height: height,
      radius: 14.r,
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return _SkeletonBox(
      width: width,
      height: height,
      radius: 8.r,
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({this.width, required this.height, required this.radius});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final base = WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor);
    final highlight =
        WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor);
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
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
              return Container(
                width: width.w,
                height: height.h,
                margin: EdgeInsets.symmetric(vertical: 10.h),
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
                decoration: BoxDecoration(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.secondaryBackgroundColor),
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
  return const AiSkeletonPage();
}

import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/schedule/model/schedule_model.dart';

const double singleCourseHeight = 100;

/// 返回本周需要上的课（亮色），可在wpy_page复用
Widget getActiveCourseCard(double width, Course bean) {
  return Container(
    height: singleCourseHeight,
    width: width,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
    child: InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(5),
      splashFactory: InkRipple.splashFactory,
      child: Column(
        children: [],
      ),
    ),
  );
}

const Color quietColor = Color.fromRGBO(236, 238, 237, 1);

/// 返回本周无需上的课（灰色）
Widget getQuietCourseCard(double width, Course bean) {
  return Container(
    height: singleCourseHeight,
    width: width,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5), color: quietColor),
    child: Column(
      children: [],
    ),
  );
}

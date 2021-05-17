import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/commons/res/color.dart';
import 'logic_extension.dart';
import '../model/school/school_model.dart';
import '../view/course_dialog.dart';

const TextStyle activeNameStyle =
    TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold);
const TextStyle activeHintStyle = TextStyle(color: Colors.white, fontSize: 8);

/// 返回本周需要上的课（亮色），可在wpy_page复用
Widget getActiveCourseCard(BuildContext context, double height, double width,
    List<ScheduleCourse> courses) {
  return Container(
    height: height,
    width: width,
    child: Material(
      color: generateColor(courses[0]),
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        onTap: () => showCourseDialog(context, courses),
        borderRadius: BorderRadius.circular(5),
        splashFactory: InkRipple.splashFactory,
        splashColor: Color.fromRGBO(179, 182, 191, 1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Column(
            children: [
              Expanded(child: Text("")),
              Text(courses[0].courseName,
                  style: activeNameStyle, textAlign: TextAlign.center),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(removeParentheses(courses[0].teacher),
                    style: activeHintStyle, textAlign: TextAlign.center),
              ),
              courses[0].arrange.room == "" ? Container() : Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(replaceBuildingWord(courses[0].arrange.room),
                    style: activeHintStyle, textAlign: TextAlign.center),
              ),
              courses.length == 1
                  ? Container()
                  : Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Image.asset('assets/images/schedule_warn.png',
                    width: 20, height: 20),
                  ),
              Expanded(child: Text(""))
            ],
          ),
        ),
      ),
    ),
  );
}

const Color quietBackColor = Color.fromRGBO(236, 238, 237, 1);
const Color quiteFrontColor = Color.fromRGBO(205, 206, 210, 1);

const TextStyle quietNameStyle = TextStyle(
    color: quiteFrontColor, fontSize: 10, fontWeight: FontWeight.bold);
const TextStyle quietHintStyle = TextStyle(color: quiteFrontColor, fontSize: 8);

/// 返回本周无需上的课（灰色）
Widget getQuietCourseCard(double height, double width, ScheduleCourse course) {
  return (CommonPreferences().otherWeekSchedule.value)
      ? Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5), color: quietBackColor),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              children: [
                Expanded(child: Text("")),
                Icon(Icons.lock, color: quiteFrontColor, size: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(course.courseName,
                      style: quietNameStyle, textAlign: TextAlign.center),
                ),
                Text("非本周", style: quietHintStyle, textAlign: TextAlign.center),
                Expanded(child: Text(""))
              ],
            ),
          ),
        )
      : Container();
}

/// 返回本周冲突的课, [courses]中的第一个元素应为显示在外的课（其余的在dialog中）
Widget getOverlapCourseCard(List<ScheduleCourse> courses) {
  return Container();
}

/// 为ActiveCourse生成随机颜色
Color generateColor(ScheduleCourse course) {
  var now = DateTime.now(); // 加点随机元素，以防一学期都是一个颜色
  int hashCode = course.courseName.hashCode + now.day;
  return FavorColors.scheduleColor[hashCode % FavorColors.scheduleColor.length];
}

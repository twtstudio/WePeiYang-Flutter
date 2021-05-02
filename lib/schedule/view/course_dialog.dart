import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/schedule/extension/logic_extension.dart';
import 'package:wei_pei_yang_demo/schedule/model/school/school_model.dart';
import 'package:wei_pei_yang_demo/schedule/extension/ui_extension.dart';

void showCourseDialog(BuildContext context, ScheduleCourse course) =>
    showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Color.fromRGBO(255, 255, 255, 0.7),
        builder: (BuildContext context) => CourseDialog(course));

class CourseDialog extends Dialog {
  final ScheduleCourse course;

  CourseDialog(this.course);

  static const nameStyle = TextStyle(
      fontSize: 25,
      color: Colors.white,
      decoration: TextDecoration.none,
      fontWeight: FontWeight.bold);

  static const teacherStyle = TextStyle(
      fontSize: 16,
      color: Colors.white,
      decoration: TextDecoration.none,
      fontWeight: FontWeight.normal);

  static const hintNameStyle = TextStyle(
      fontSize: 11,
      color: Colors.white,
      decoration: TextDecoration.none,
      fontWeight: FontWeight.w200,
      letterSpacing: 1);

  static const hintValueStyle = TextStyle(
      fontSize: 11,
      color: Colors.white,
      decoration: TextDecoration.none,
      fontWeight: FontWeight.w900);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 400,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 100),
          itemCount: 3,
          itemBuilder: (context, i){
            return Container(
              // margin: const EdgeInsets.symmetric(horizontal: 50),
              // height: 400,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/icon_peiyang.png'),
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(15),
                  color: generateColor(course)),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(25, 35, 50, 35),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.courseName, style: nameStyle),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(course.teacher, style: teacherStyle),
                      ),
                      Expanded(child: Text("")),
                      _getRow1(),
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _getRow2(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _getRow3(),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _getRow1() => Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 1),
                child: Text('ID', style: hintNameStyle),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(course.courseId, style: hintValueStyle),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('逻辑班号', style: hintNameStyle),
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(course.classId, style: hintValueStyle),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('校区', style: hintNameStyle.copyWith(letterSpacing: 3)),
                Padding(
                  padding: const EdgeInsets.only(top: 1, left: 1),
                  child: Text(
                      "${course.campus}${course.campus.isNotEmpty ? "校区" : ""}",
                      style: hintValueStyle.copyWith(fontSize: 10)),
                )
              ],
            ),
          )
        ],
      );

  Widget _getRow2() => Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('上课地点', style: hintNameStyle),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(replaceBuildingWord(course.arrange.room),
                    style: hintValueStyle),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('起止周', style: hintNameStyle),
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text("${course.week.start}-${course.week.end}",
                      style: hintValueStyle),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('学分', style: hintNameStyle.copyWith(letterSpacing: 3)),
                Padding(
                  padding: const EdgeInsets.only(top: 3, left: 2),
                  child: Text(course.credit, style: hintValueStyle),
                )
              ],
            ),
          )
        ],
      );

  Widget _getRow3() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('时间', style: hintNameStyle.copyWith(letterSpacing: 3)),
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(getCourseTime(course.arrange.start, course.arrange.end),
                style: hintValueStyle),
          )
        ],
      );
}

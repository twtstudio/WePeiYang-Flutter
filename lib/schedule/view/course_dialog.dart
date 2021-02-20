import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/schedule/extension/logic_extension.dart';
import 'package:wei_pei_yang_demo/schedule/model/school/school_model.dart';
import 'package:wei_pei_yang_demo/schedule/extension/ui_extension.dart';

void showCourseDialog(BuildContext context, ScheduleCourse course) => showDialog(
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
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          height: 400,
          width: 250,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: generateColor(course)),
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
      ),
    );
  }

  Widget _getRow1() => Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID', style: hintNameStyle),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(course.courseId, style: hintValueStyle),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LOGIC NO.', style: hintNameStyle),
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(course.classId, style: hintValueStyle),
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
              Text('CAMPUS', style: hintNameStyle),
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(course.campus, style: hintValueStyle),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ROOM', style: hintNameStyle),
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(replaceBuildingWord(course.arrange.room),
                      style: hintValueStyle),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('WEEKS', style: hintNameStyle),
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text("${course.arrange.start}-${course.arrange.end}",
                      style: hintValueStyle),
                )
              ],
            ),
          )
        ],
      );

  Widget _getRow3() => Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CREDITS', style: hintNameStyle),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(course.credit, style: hintValueStyle),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TIME', style: hintNameStyle),
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                      getCourseTime(course.arrange.start, course.arrange.end),
                      style: hintValueStyle),
                )
              ],
            ),
          )
        ],
      );
}

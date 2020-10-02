import 'package:flutter/material.dart' show Colors;
import 'package:fluttertoast/fluttertoast.dart' show Fluttertoast;
import 'package:wei_pei_yang_demo/commons/network/dio_server.dart';
import 'package:flutter/material.dart' show required;
import 'package:wei_pei_yang_demo/schedule/model/schedule_model.dart';

getClassTable(
    {@required void Function(Schedule) onSuccess, OnFailure onFailure}) async {
  var dio = await DioService.create();
  await dio.getCall("v1/classtable", onSuccess: (commonBody) {
    try {
      List<Course> courses = [];
      var classTable = ClassTable.fromJson(commonBody.data);
      classTable.data.forEach((element) {
        CourseBean cs = CourseBean.fromJson(element);

        ///把每个course对象arrange数组拆分（看看model里面[Course]和[CourseBean]的区别就懂了）
        cs.arrange.forEach((e) {
          courses.add(Course(
              cs.classId,
              cs.courseId,
              cs.courseName,
              cs.credit,
              cs.teacher,
              cs.campus,
              Week.fromJson(cs.week),
              Arrange.fromJson(e)));
        });
      });
      onSuccess(Schedule(classTable.termStart, classTable.term, courses));
    } catch (e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }, onFailure: onFailure);
}

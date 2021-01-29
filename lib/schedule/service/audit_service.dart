import 'package:flutter/material.dart' show Colors;
import 'package:fluttertoast/fluttertoast.dart' show Fluttertoast;
import 'package:wei_pei_yang_demo/commons/network/dio_server.dart';
import 'package:flutter/material.dart' show required;
import 'package:wei_pei_yang_demo/schedule/model/audit/audit_model.dart';
import 'package:wei_pei_yang_demo/schedule/model/audit/audit_popular_model.dart';

getMyAudit(String userNumber,
    {@required void Function(List<AuditCourse>) onSuccess,
    OnFailure onFailure}) async {
  var dio = DioService.create();
  await dio.getCall("v1/auditClass/audit",
      queryParameters: {"user_number": userNumber}, onSuccess: (commonBody) {
    try {
      List<AuditCourse> auditCourses = [];
      // commonBody.data.forEach(
      //     (key, value) => auditCourses.add(AuditCourse.fromJson(value)));
      onSuccess(auditCourses);
    } catch (e) {
      _onError(e);
    }
  }, onFailure: onFailure);
}

getPopularAudit(
    {@required void Function(List<AuditPopular>) onSuccess,
    OnFailure onFailure}) async {
  var dio = DioService.create();
  await dio.getCall("v1/auditClass/popular", onSuccess: (commonBody) {
    try {
      List<AuditPopular> auditPopulars = [];
      // commonBody.data.forEach(
      //     (key, value) => auditPopulars.add(AuditPopular.fromJson(value)));
      onSuccess(auditPopulars);
    } catch (e) {
      _onError(e);
    }
  }, onFailure: onFailure);
}

getAuditCollege(int withClass,
    {@required void Function(List<AuditCollegeData>) onSuccess,
    OnFailure onFailure}) async {
  var dio = DioService.create();
  await dio.getCall("v1/auditClass/college",
      queryParameters: {"with_class": withClass}, onSuccess: (commonBody) {
    try {
      List<AuditCollegeData> list = [];
      // commonBody.data
      //     .forEach((key, value) => list.add(AuditCollegeData.fromJson(value)));
      onSuccess(list);
    } catch (e) {
      _onError(e);
    }
  }, onFailure: onFailure);
}

searchCourse(String courseName, int type,
    {@required void Function(List<AuditSearchCourse>) onSuccess,
    OnFailure onFailure}) async {
  var dio = DioService.create();
  await dio.getCall("v1/auditClass/search",
      queryParameters: {"name": courseName, "type": type},
      onSuccess: (commonBody) {
    try {
      List<AuditSearchCourse> list = [];
      // commonBody.data
      //     .forEach((key, value) => list.add(AuditSearchCourse.fromJson(value)));
      onSuccess(list);
    } catch (e) {
      _onError(e);
    }
  }, onFailure: onFailure);
}

audit(String userNumber, int courseId, String infoIds,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  var dio = DioService.create();
  await dio.getCall("v1/auditClass/audit",
      queryParameters: {
        "user_number": userNumber,
        "course_id": courseId,
        "info_dis": infoIds
      },
      onSuccess: (_) => onSuccess(),
      onFailure: onFailure);
}

cancelAudit(String userNumber, String ids,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  var dio = DioService.create();
  await dio.getCall("v1/auditClass/audit",
      queryParameters: {"user_number": userNumber, "ids": ids},
      onSuccess: (_) => onSuccess(),
      onFailure: onFailure);
}

void _onError(dynamic e) {
  Fluttertoast.showToast(
      msg: e.toString(),
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

import 'package:wei_pei_yang_demo/commons/network/dio_server.dart';
import 'package:flutter/cupertino.dart' show required;
import 'package:wei_pei_yang_demo/gpa/gpa_model.dart';

getGPABean(
    {@required void Function(List<GPAStat> list) onSuccess,
    OnFailure onFailure}) async {
  var dio = await DioService().create();
  await dio.getCall("v1/gpa", onSuccess: (commonBody) {
    var gpaData = GPABean.fromJson(commonBody.data).data;
    List<GPAStat> stats = [];
    gpaData.forEach((element) {
      var term = Term.fromJson(element);
      var ts = TermStat.fromJson(term.stat);
      List<Course> courses = [];
      term.data.forEach((element) {
        courses.add(Course.fromJson(element));
      });
      stats.add(GPAStat(ts.score, ts.gpa, ts.credit, courses));
    });
    onSuccess(stats);
  }, onFailure: onFailure);
}

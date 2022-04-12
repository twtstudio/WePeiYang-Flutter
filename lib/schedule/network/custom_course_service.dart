// @dart = 2.12
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';

class CustomCourseDio extends DioAbstract {
  @override
  String baseUrl = 'http://101.42.225.75:8081//';

  @override
  List<InterceptorsWrapper> interceptors = [
    InterceptorsWrapper(onRequest: (options, handler) {
      options.headers['token'] = CommonPreferences.customCourseToken.value;
      return handler.next(options);
    })
  ];
}

final customCourseDio = CustomCourseDio();

class CustomCourseService with AsyncTimer {
  static Future<bool> getToken({bool quiet = true}) async {
    try {
      var response = await customCourseDio
          .post('api/v1/user/auth/fromClient/login', queryParameters: {
        'token': CommonPreferences.token.value,
      });
      CommonPreferences.customCourseToken.value = response.data['data'];
      return true;
    } catch (e) {
      if (!quiet) ToastProvider.error('自定义课表服务加载失败');
      return false;
    }
  }

  static Future<void> updateCustomClass(Course course, int index) async {
    try {
      Map<String, dynamic> map = {
        'index': index,
        'credit': course.credit,
        'class_name': course.name,
        'classDetailList': course.arrangeList
            .map((arrange) => {
                  'class_order': _unitList2Str(arrange.unitList),
                  'classroom': arrange.location,
                  'this_class_teacher': arrange.teacherList.first,
                  'which_week': _weekList2Str(arrange.weekList),
                  'which_weekday': arrange.weekday.toString()
                })
            .toList()
      };
      await customCourseDio.post('customClassTable/update',
          queryParameters: map);
    } catch (e) {
      // ToastProvider.error('更新自定义课程失败');
    }
  }

  static Future<void> deleteCustomClass(int index) async {
    try {
      await customCourseDio.post('customClassTable/deleteClass',
          queryParameters: {'index': index});
    } catch (e) {
      // ToastProvider.error('删除自定义课程失败');
    }
  }

  static Future<void> addCustomClass(Course course, int index) async {
    try {
      Map<String, dynamic> map = {
        'index': index,
        'credit': course.credit,
        'class_name': course.name,
        'classDetailList': course.arrangeList
            .map((arrange) => {
                  'class_order': _unitList2Str(arrange.unitList),
                  'classroom': arrange.location,
                  'this_class_teacher': arrange.teacherList.first,
                  'which_week': _weekList2Str(arrange.weekList),
                  'which_weekday': arrange.weekday.toString()
                })
            .toList()
      };
      await customCourseDio.post('customClassTable/addCustomClass',
          queryParameters: map);
    } catch (e) {
      // ToastProvider.error('添加自定义课程失败');
    }
  }

  static Future<List<Course>?> getCustomTable() async {
    try {
      var response =
          await customCourseDio.get('customClassTable/getCustomTable');
      var courseList = <Course>[];
      for (Map<String, dynamic> courseJson in response.data['data']
          ['customClassTable']) {
        var name = courseJson['class_name'];
        var credit = courseJson['credit'];
        var minWeek = 100, maxWeek = 0;
        var teacherList = <String>[];
        var arrangeList = <Arrange>[];
        for (Map<String, dynamic> arrangeJson
            in courseJson['classDetailList']) {
          var weekList = _weekStr2List(arrangeJson['which_week'].toString());
          if (minWeek > weekList.first) minWeek = weekList.first;
          if (maxWeek < weekList.last) maxWeek = weekList.last;

          var unitList = _unitStr2List(arrangeJson['class_order'].toString());

          var teacherStr = arrangeJson['this_class_teacher'].toString();
          if (!teacherList.contains(teacherStr)) {
            teacherList.add(teacherStr);
          }
          var arrange = Arrange.empty()
            ..location = arrangeJson['classroom']
            ..weekday = int.parse(arrangeJson['which_weekday'])
            ..weekList = weekList
            ..unitList = unitList
            ..teacherList = [teacherStr];
          arrangeList.add(arrange);
        }
        var weeks = '$minWeek-$maxWeek';
        courseList
            .add(Course.custom(name, credit, weeks, teacherList, arrangeList));
      }
    } catch (e) {
      return null;
    }
  }

  static Future<Course?> getClassBySerial(String serial) async {
    try {
      var response = await customCourseDio.get('customClassTable/${serial}');
      var data = response.data['data'];
      var name = data['class_name'];
      var credit = data['credit'];
      var weeks = data['total_start_end_week'];
      var teacherList = [data['all_teacher'].toString()];
      var arrangeList = <Arrange>[];
      for (Map<String, dynamic> json in data['detailList']) {
        // TODO 接口还有些问题
        var arrange = Arrange.empty()
          ..location = json['classroom']
          ..weekday = int.parse(json['which_weekday'])
          ..weekList = [int.parse(json['which_week'])] // this
          ..unitList = [0, 0] // this
          ..teacherList = [json['this_class_teacher']];
        arrangeList.add(arrange);
      }
      return Course.custom(name, credit, weeks, teacherList, arrangeList);
    } catch (e) {
      ToastProvider.error('导入课程失败，请重试');
      return null;
    }
  }
}

List<int> _weekStr2List(String str) {
  var result = <int>[];
  for (int i = 0; i < str.length; i++) {
    if (str[i] == '1') result.add(i);
  }
  return result;
}

String _weekList2Str(List<int> list) {
  var result = '';
  for (int i = 0; i <= list.last; i++) {
    result += list.contains(i) ? '1' : '0';
  }
  return result;
}

List<int> _unitStr2List(String str) => [int.parse(str[0]), int.parse(str[1])];

String _unitList2Str(List<int> list) => '${list.first}${list.last}';

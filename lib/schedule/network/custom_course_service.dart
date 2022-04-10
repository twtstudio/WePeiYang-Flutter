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
  static Future<void> getToken({bool quiet = true}) async {
    try {
      var response = await customCourseDio
          .post('api/v1/user/auth/fromClient/login', queryParameters: {
        'token': CommonPreferences.token.value,
      });
      if (response.data['data'] != null) {
        CommonPreferences.customCourseToken.value = response.data['data'];
      }
    } catch (e) {
      ToastProvider.error('自定义课表服务加载失败');
    }
  }

  static Future<void> updateCustomClass() async {

  }

  static Future<void> deleteCustomClassDetail() async {

  }

  static Future<void> deleteCustomClass() async {

  }

  static Future<void> addCustomClass() async {

  }

  static Future<List<Course>> getCustomTable() async {

  }

  static Future<Course> getClassBySerial(String serial) async {
    try {
      var response = await customCourseDio
          .post('api/v1/user/auth/fromClient/login', queryParameters: {
        'token': CommonPreferences.token.value,
      });
      if (response.data['data'] != null) {
        CommonPreferences.customCourseToken.value = response.data['data'];
      }
    } catch (e) {
      ToastProvider.error('导入课程失败，请重试');
    }
  }
}

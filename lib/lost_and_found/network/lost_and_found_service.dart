import 'dart:io';

import 'package:http_parser/http_parser.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/lost_and_found/network/lost_and_found_post.dart';

import '../../feedback/network/feedback_service.dart';

class LostAndFoundDio extends DioAbstract {
  @override
  String baseUrl = '${EnvConfig.LAF}v1/';

  @override
  List<Interceptor> interceptors = [
    InterceptorsWrapper(onRequest: (options, handler) {
      return handler.next(options);
    }, onResponse: (response, handler) {
      var code = response.data['code'] ?? 0;
      switch (code) {
        case "200": // 成功
          return handler.next(response);
        default: // 其他错误
          return handler.reject(
              WpyDioException(error: response.data['message']), true);
      }
    })
  ];
}

class LostAndFoundPicPostDio extends DioAbstract {
  @override
  String baseUrl = 'http://121.36.230.111:80';

  @override
  List<Interceptor> interceptors = [
    InterceptorsWrapper(onRequest: (options, handler) {
      options.headers['token'] = CommonPreferences.lakeToken.value;
      return handler.next(options);
    }, onResponse: (response, handler) {
      var code = response.data['code'] ?? 0;
      switch (code) {
        case 200: // 成功
          return handler.next(response);
        default: // 其他错误
          return handler.reject(
              WpyDioException(error: response.data['msg']), true);
      }
    })
  ];
}

final lostAndFoundDio = LostAndFoundDio();
final lostAndFoundPicPostDio = LostAndFoundPicPostDio();

class LostAndFoundService with AsyncTimer {
  static getLostAndFoundPosts({
    num,
    keyword,
    required String history,
    required String category,
    required String type,
    required void Function(List<LostAndFoundPost> list) onSuccess,
    required OnFailure onFailure,
  }) async {
    try {
      Options requestOptions = new Options(headers: {"history": history});
      var res = await lostAndFoundDio.get(
          keyword != null
              ? 'sort/search'
              : (category != '全部'
                  ? 'sort/getbytypeandcategorywithnum'
                  : 'sort/getbytypewithnum'),
          queryParameters: {
            'q': keyword,
            'type': type,
            'num': num,
            'category': category,
          },
          options: requestOptions);

      List<LostAndFoundPost> list = [];
      for (Map<String, dynamic> json in res.data['result']) {
        list.add(LostAndFoundPost.fromJson(json));
      }
      onSuccess(list);
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static void getLostAndFoundPostDetail({
    required int id,
    required OnResult<LostAndFoundPost> onResult,
    required OnFailure onFailure,
  }) async {
    try {
      var response = await lostAndFoundDio.get(
        'laf/get?id=${id}',
      );
      var post = LostAndFoundPost.fromJson(response.data['result']);
      onResult(post);
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  //擦亮
  static polish(
      {required id,
      required user,
      required OnSuccess onSuccess,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('polish', () async {
      try {
        await lostAndFoundDio.post('record/polish',
            formData: FormData.fromMap({'id': id, 'user': user}));
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  //失物招领删除
  static deleteLostAndFoundPost(
      {required id,
      required OnSuccess onSuccess,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('deleteLostAndFoundPost', () async {
      try {
        await lostAndFoundDio.post('laf/deletelaf',
            formData: FormData.fromMap({'id': id}));
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  // 失物招领的联系方式记录
  static locationAddRecord(
      {required String yyyymmdd,
      required user,
      required OnSuccess onSuccess,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('locationAddRecord', () async {
      try {
        await lostAndFoundDio.post('record/addrecord',
            formData: FormData.fromMap({'yyyymmdd': yyyymmdd, 'user': user}));
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  // 查询用户今天获取了几次联系方式
  static getRecordNum({
    required String yyyymmdd,
    required String user,
    required OnResult onResult,
    required OnFailure onFailure,
  }) async {
    try {
      var res = await lostAndFoundDio.get(
        'record/recordnum',
        queryParameters: {
          'yyyymmdd': yyyymmdd,
          'user': user,
        },
      );
      var num = res.data['result'];
      onResult(num);
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static sendLostAndFoundPost(
      {required author,
      required type,
      required category,
      required title,
      required text,
      required yyyymmdd,
      required yyyymmddhhmmss,
      required location,
      required phone,
      required List<String> images,
      required OnSuccess onSuccess,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('sendLostAndFoundPost', () async {
      try {
        var formData = FormData.fromMap({
          'type': type,
          'category': category,
          'title': title,
          'text': text,
          'yyyymmdd': yyyymmdd,
          'location': location,
          'phone': phone
        });
        if (images.isNotEmpty) {
          for (int i = 0; i < images.length; i++) {
            formData.fields.addAll([MapEntry('images', images[i])]);
          }
        }
        await lostAndFoundDio.post('post', formData: formData);
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  static Future<void> postLostAndFoundPic(
      {required List<File> images,
      required OnResult<List<String>> onResult,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('postLostAndFoundPic', () async {
      try {
        var formData = FormData();
        if (images.isNotEmpty) {
          for (int i = 0; i < images.length; i++)
            formData.files.addAll([
              MapEntry(
                  'images',
                  MultipartFile.fromFileSync(
                    images[i].path,
                    filename: '${DateTime.now().millisecondsSinceEpoch}qwq.jpg',
                    contentType: MediaType("image", "jpeg"),
                  ))
            ]);
        }
        var response = await feedbackPicPostDio.post(
          'upload/image',
          formData: formData,
          options: Options(sendTimeout: Duration(seconds: 10)),
        );
        List<String> list = [];
        for (String json in response.data['data']['urls']) {
          list.add(json);
        }
        onResult(list);
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }
}

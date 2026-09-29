import 'dart:io';

import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/token/laf_token_manager.dart';
import 'package:we_pei_yang_flutter/commons/token/lake_token_manager.dart';
import 'package:we_pei_yang_flutter/lost_and_found/network/lost_and_found_post.dart';

import '../../commons/preferences/common_prefs.dart';
import '../../feedback/network/feedback_service.dart';

class LostAndFoundDio extends DioAbstract {
  @override
  String baseUrl = '${EnvConfig.LAF}v1/';

  @override
  List<Interceptor> interceptors = [
    InterceptorsWrapper(onRequest: (options, handler) async{
      options.headers['token'] = (await LafTokenManager().token);
      return handler.next(options);
    }, onResponse: (response, handler) {
      var code = response.data['code'] ?? 0;
      switch (code) {
        case 200: // 成功
          return handler.next(response);
        case -1: // 获取联系方式超过三次
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
  String baseUrl = 'http://110.41.178.7:8080';

  @override
  List<Interceptor> interceptors = [
    InterceptorsWrapper(onRequest: (options, handler) async {
      options.headers['token'] = await LakeTokenManager().token;
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
  //通过账户密码获得token
  static getTokenByPw(String account,
      String passwd,
      {
        required OnSuccess onSuccess,
        required OnFailure onFailure,
      }) async {
    try {
      var response = await lostAndFoundDio.get('laf/login', queryParameters: {
        'account': account,
        'password': passwd,
      });
      if (response.data['result']['token'] != null)
        CommonPreferences.lafToken.value = response.data['result']['token'];
      onSuccess();
    } on DioException catch (e) {
      onFailure(e);
    }
  }


  static getLostAndFoundPosts({
    list,
    required int page,
    required int page_size,
    required void Function(List<LostAndFoundPost> list) onSuccess,
    required OnFailure onFailure,
  }) async {
    try {
      // Options requestOptions = new Options(headers: {"history": history});
      var res = await lostAndFoundDio.get(
        // keyword != null
        //     ? 'sort/search'
        //     : (category != '全部'
        //         ? 'sort/getbytypeandcategorywithnum'
        //         : 'sort/getbytypewithnum'),
          'laf/post/get/falls',
          queryParameters: {
            'page': page,
            'page_size': page_size,
          }

        // options: requestOptions
      );

      List<LostAndFoundPost> list = [];
      for (Map<String, dynamic> json in res.data['result']) {
        list.add(LostAndFoundPost.fromJson(json));
      }
      onSuccess(list);
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  //获取单个帖子
  static void getLostAndFoundPostDetail({
    required int id,
    required OnResult<LostAndFoundPost> onResult,
    required OnFailure onFailure,
  }) async {
    try {
      var response = await lostAndFoundDio.get(
        'laf/post/getById',
        queryParameters: {'post_id': id,},
      );
      var post = LostAndFoundPost.fromJson(response.data['result']);
      onResult(post);
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  //获取联系方式
  static void getRecordNum({
    required int post_id,
    required OnResult<String?> onResult,
    required OnFailure onFailure,
  }) async {
    try {
      var response=await lostAndFoundDio.post(
          'laf/post/get/phone', formData: FormData.fromMap(
          {
            'post_id': post_id,
          }));
      var post=response.data['result'];
      onResult(post);
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  //添加图片
  static void saveLostAndFoundSavePhoto({
    required int post_id,
    required XFile pho,
    required OnSuccess onSuccess,
    required OnFailure onFailure,
  }) async {
    try{
      await lostAndFoundDio.post('laf/pho/savepho',formData: FormData.fromMap(
          {
            'post_id':post_id,
            'pho':pho,
          }));
      onSuccess.call();
    } on DioException catch(e){
      onFailure(e);
    }
  }



  // //擦亮
  // static polish(
  //     {required id,
  //     required user,
  //     required OnSuccess onSuccess,
  //     required OnFailure onFailure}) async {
  //   AsyncTimer.runRepeatChecked('polish', () async {
  //     try {
  //       await lostAndFoundDio.post('record/polish',
  //           formData: FormData.fromMap({'id': id, 'user': user}));
  //       onSuccess.call();
  //     } on DioException catch (e) {
  //       onFailure(e);
  //     }
  //   });
  // }

  //失物招领删除自己帖子
  static deleteLostAndFoundPost(
      {required id,
      required OnSuccess onSuccess,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('deleteLostAndFoundPost', () async {
      try {
        await lostAndFoundDio.post('laf/post/delete',
            formData: FormData.fromMap({'post_id': id}));
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  //获取所有帖子类型
  // static getAllCategories({
  //   required OnResult<List> onResult,
  //   required OnFailure onFailure
  // }) async{
  //   AsyncTimer.runRepeatChecked('getAllCategories', () async{
  //     try {
  //       var response=await lostAndFoundDio.get('laf/get/categorys');
  //       var post = LostAndFoundPost.fromJson(response.data['result']);
  //      onResult(post);
  //     } on DioException catch (e){
  //       onFailure(e);
  //     }
  //   });
  // }

  // // 失物招领的联系方式记录
  // static locationAddRecord(
  //     {required String yyyymmdd,
  //     required user,
  //     required OnSuccess onSuccess,
  //     required OnFailure onFailure}) async {
  //   AsyncTimer.runRepeatChecked('locationAddRecord', () async {
  //     try {
  //       await lostAndFoundDio.post('record/addrecord',
  //           formData: FormData.fromMap({'yyyymmdd': yyyymmdd, 'user': user}));
  //       onSuccess.call();
  //     } on DioException catch (e) {
  //       onFailure(e);
  //     }
  //   });
  // }

  // // 查询用户今天获取了几次联系方式
  // static getRecordNum({
  //   required String yyyymmdd,
  //   required String user,
  //   required OnResult onResult,
  //   required OnFailure onFailure,
  // }) async {
  //   try {
  //     var res = await lostAndFoundDio.get(
  //       'record/recordnum',
  //       queryParameters: {
  //         'yyyymmdd': yyyymmdd,
  //         'user': user,
  //       },
  //     );
  //     var num = res.data['result'];
  //     onResult(num);
  //   } on DioException catch (e) {
  //     onFailure(e);
  //   }
  // }


  //发帖
  static sendLostAndFoundPost(
      {required bool type,
      required category,
      required campus,
      required title,
      required content,
      required location,
        required tag,
      required phone,
      required time,
      required OnSuccess onSuccess,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('sendLostAndFoundPost', () async {
      try {
        var formData = FormData.fromMap({
          'type': type,
          'category': category,
          'campus':campus,
          'title': title,
          'content': content,
          'location': location,
          'tag':tag,
          'phone': phone,
          'time':time,
        });
        await lostAndFoundDio.post('laf/post/put', formData: formData);
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

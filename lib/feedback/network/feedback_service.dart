import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show required;
import 'package:http_parser/http_parser.dart';

import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';

class FeedbackDio extends DioAbstract {
  // @override
  // String baseUrl = 'http://47.94.198.197:10805/api/user/';
  @override
  // String baseUrl = 'https://areas.twt.edu.cn/api/user/';
  String baseUrl = 'https://www.zrzz.site:7013/api/v1/f/';
  var headers = {};

  @override
  List<InterceptorsWrapper> interceptors = [
    InterceptorsWrapper(onRequest: (options, handler) {
      options.headers['token'] = CommonPreferences().feedbackToken.value;
      return handler.next(options);
    }, onResponse: (response, handler) {
      var code = response?.data['code'] ?? 0;
      switch (code) {
        case 200: // 成功
          return handler.next(response);
        // case 10: // 含有敏感词，需要把敏感词也展示出来
        //   return handler.reject(
        //       WpyDioError(
        //           error: response.data['msg'] +
        //               '\n' +
        //               response.data['data']['bad_word_list']
        //                   .toSet()
        //                   .toList()
        //                   .toString()),
        //       true);
        default: // 其他错误
          return handler.reject(WpyDioError(error: response.data['msg']), true);
      }
    })
  ];
}

final feedbackDio = FeedbackDio();

class FeedbackService with AsyncTimer {
  static getToken({OnResult<String> onResult, OnFailure onFailure}) async {
    try {
      var response = await feedbackDio.get('auth', queryParameters: {
        'user': CommonPreferences().account.value,
        'password': CommonPreferences().password.value,
      });
      if (response.data['data'] != null &&
          response.data['data']['token'] != null) {
        CommonPreferences().feedbackToken.value =
            response.data['data']['token'];
        CommonPreferences().feedbackUid.value =
        response.data['data']['uid'].toString();
        if (onResult != null) onResult(response.data['data']['token']);
      } else {
        throw WpyDioError(error: '校务专区登录失败, 请刷新');
      }
    } on DioError catch (e) {
      if (onFailure != null) onFailure(e);
    }
  }

  static getDepartments(token,
      {@required OnResult<List<Department>> onResult,
      @required OnFailure onFailure}) async {
    try {
      var response = await feedbackDio.get('departments');
      if (response.data['data']['total'] != 0) {
        List<Department> departmentList = [];
        for (Map<String, dynamic> json in response.data['data']['list']) {
          departmentList.add(Department.fromJson(json));
        }
        onResult(departmentList);
      } else {
        throw WpyDioError(error: '校务专区获取标签失败, 请刷新');
      }
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static getPosts(
      {keyword,
      departmentId,
      @required type,
      @required page,
      @required void Function(List<Post> list, int totalPage) onSuccess,
      @required OnFailure onFailure}) async {
    try {
      var response = await feedbackDio.get(
        'posts',
        queryParameters: {
          'type': '$type',
          'content': keyword ?? '',

          ///搜索
          'page_size': '10',
          'page': '$page',
        },
      );
      List<Post> list = [];
      for (Map<String, dynamic> json in response.data['data']['list']) {
        list.add(Post.fromJson(json));
      }
      onSuccess(list, response.data['data']['total']);
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static getMyPosts({
    @required OnResult<List<Post>> onResult,
    @required OnFailure onFailure,
  }) async {
    try {
      var response = await feedbackDio.get(
        'posts/user',
      );
      List<Post> list = [];
      for (Map<String, dynamic> json in response.data['data']['list']) {
        list.add(Post.fromJson(json));
      }
      onResult(list);
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static getFavoritePosts({
    @required OnResult<List<Post>> onResult,
    @required OnFailure onFailure,
  }) async {
    try {
      var response = await feedbackDio.get('posts/fav');
      List<Post> list = [];
      for (Map<String, dynamic> json in response.data['data']['list']) {
        list.add(Post.fromJson(json));
      }
      onResult(list);
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static getPostById({
    @required int id,
    @required OnResult<Post> onResult,
    @required OnFailure onFailure,
  }) async {
    try {
      var response = await feedbackDio.get(
        'post',
        queryParameters: {
          'id': '$id',
        },
      );
      var post = Post.fromJson(response.data['data']['post']);
      onResult(post);
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  ///comments改成了floors，需要点赞字段
  static getComments({
    @required id,
    @required void Function(List<Floor> commentList, int totalPage) onSuccess,
    @required OnFailure onFailure,
    @required int page,
  }) async {
    try {
      var commentResponse = await feedbackDio.get(
        'floors',
        queryParameters: {
          'post_id': '$id',
          'page': '$page',
          'page_size': '10',
        },
      );
      List<Floor> commentList = [];
      for (Map<String, dynamic> json in commentResponse.data['data']['list']) {
        commentList.add(Floor.fromJson(json));
      }
      onSuccess(commentList, commentResponse.data['data']['total']);
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static Future<void> postHitLike({
    @required id,
    @required bool isLiked,
    @required OnSuccess onSuccess,
    @required OnFailure onFailure,
  }) async {
    AsyncTimer.runRepeatChecked('postHitLike', () async {
      try {
        await feedbackDio.post('post/likeOrUnlike/modify',
            formData: FormData.fromMap({
              'post_id': '$id',
              'op': isLiked ? 0 : 1,
            }));
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static postHitFavorite({
    @required id,
    @required bool isFavorite,
    @required OnSuccess onSuccess,
    @required OnFailure onFailure,
  }) async {
    AsyncTimer.runRepeatChecked('postHitFavorite', () async {
      try {
        await feedbackDio.post('post/favOrUnfav/modify',
            formData: FormData.fromMap({
              'post_id': id,
              'op': isFavorite ? 0 : 1,
            }));
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static Future<void> postHitDislike({
    @required id,
    @required bool isDisliked,
    @required OnSuccess onSuccess,
    @required OnFailure onFailure,
  }) async {
    AsyncTimer.runRepeatChecked('postHitDislike', () async {
      try {
        await feedbackDio.post('post/disOrUndis/modify',
            formData: FormData.fromMap({
              'post_id': '$id',
              'op': isDisliked ? 0 : 1,
            }));
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  ///暂时没有接口，后面改
  static Future<void> commentHitLike(
      {@required id,
      @required bool isLiked,
      @required OnSuccess onSuccess,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('commentHitLike', () async {
      try {
        await feedbackDio.post(isLiked ? 'commit/dislike' : 'commit/like',
            formData: FormData.fromMap({
              'id': '$id',
              'token': CommonPreferences().feedbackToken.value,
            }));
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }
  ///暂时没有接口，后面改
  static officialCommentHitLike(
      {@required id,
      @required bool isLiked,
      @required OnSuccess onSuccess,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('officialCommentHitLike', () async {
      try {
        await feedbackDio.post(isLiked ? 'answer/dislike' : 'answer/like',
            formData: FormData.fromMap({
              'id': '$id',
              'token': CommonPreferences().feedbackToken.value,
            }));
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }
  ///TODO：暂时没加带图片
  static sendComment(
      {@required id,
      @required content,
      @required OnSuccess onSuccess,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('sendComment', () async {
      try {
        await feedbackDio.post(
          'floor',
          formData: FormData.fromMap({
            'post_id': id,
            'content': content,
          }),
        );
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static sendPost(
      {@required type,
      @required title,
      @required content,
      departmentId,
      tagId,
      @required campus,
      @required List<File> images,
      @required OnSuccess onSuccess,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('sendPost', () async {
      try {
        List uploadImages = [];
        if (images.isNotEmpty) {
          images.asMap().map((index, value) => MapEntry(
              index,
              uploadImages.add(
                  MultipartFile.fromFile(
                    value.path,
                    filename: 'p${images[index].hashCode}i$index.jpg',
                    contentType: MediaType("image", "jpg"),
                  )
              ),
          ));
        }
        await feedbackDio.post('post',
            formData: FormData.fromMap({
              'type': type,
              'title': title,
              'content': content,
              'department_id': departmentId,
              'tag_id': tagId,
              'campus': campus,
              'images': uploadImages,
            }));
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }
  ///暂时没有接口，后面改
  static rate(
      {@required id,
      @required rating,
      @required OnSuccess onSuccess,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('rate', () async {
      try {
        await feedbackDio.post(
          'answer/commit',
          formData: FormData.fromMap({
            'token': CommonPreferences().feedbackToken.value,
            'answer_id': id,
            'score': rating.toInt(),
            'commit': '评分',
          }),
        );
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static deletePost(
      {@required id,
      @required OnSuccess onSuccess,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('deletePost', () async {
      try {
        await feedbackDio.get(
          'post/delete',
          queryParameters: {
            'post_id': id,
          },
        );
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static reportQuestion(
      {@required id,
      @required reason,
      @required OnSuccess onSuccess,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('reportQuestion', () async {
      try {
        await feedbackDio.post(
          'report',
          formData: FormData.fromMap({
            'type': 1,///TODO:1为帖子举报，2为楼层举报，暂时只有一种
            'post_id': id,
            'reason': reason,
          }),
        );
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static deleteFloor(
    {@required id,
    @required OnSuccess onSuccess,
    @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('deletePost', () async {
      try {
        await feedbackDio.get(
          'floor/delete',
          queryParameters: {
            'floor_id': id,
          },
        );
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }
}

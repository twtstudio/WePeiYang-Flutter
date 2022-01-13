import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show required;
import 'package:http_parser/http_parser.dart';

import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/feedback/network/comment.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/network/tag.dart';

class FeedbackDio extends DioAbstract {
  // @override
  // String baseUrl = 'http://47.94.198.197:10805/api/user/';
  @override
  String baseUrl = 'https://areas.twt.edu.cn/api/user/';

  @override
  List<InterceptorsWrapper> interceptors = [
    InterceptorsWrapper(onResponse: (response, handler) {
      var code = response?.data['ErrorCode'] ?? 0;
      switch (code) {
        case 0: // 成功
          return handler.next(response);
        case 10: // 含有敏感词，需要把敏感词也展示出来
          return handler.reject(
              WpyDioError(
                  error: response.data['msg'] +
                      '\n' +
                      response.data['data']['bad_word_list']
                          .toSet()
                          .toList()
                          .toString()),
              true);
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
      var cid = await pushChannel.invokeMethod<String>("getCid");
      var response = await feedbackDio.post(
        'login',
        formData: FormData.fromMap({
          'wpyToken': CommonPreferences().token.value,
          'cid': cid,
        }),
      );
      if (response.data['data'] != null &&
          response.data['data']['token'] != null) {
        CommonPreferences().feedbackToken.value =
            response.data['data']['token'];
        if (onResult != null) onResult(response.data['data']['token']);
      } else {
        throw WpyDioError(error: '校务专区登录失败, 请刷新');
      }
    } on DioError catch (e) {
      if (onFailure != null) onFailure(e);
    }
  }

  static getTags(token,
      {@required OnResult<List<Tag>> onResult,
      @required OnFailure onFailure}) async {
    try {
      var response = await feedbackDio.get('tag/get/all', queryParameters: {
        'token': token,
      });
      if (response.data['data'][0]['children'].length != 0) {
        List<Tag> tagList = [];
        for (Map<String, dynamic> json in response.data['data'][0]
            ['children']) {
          tagList.add(Tag.fromJson(json));
        }
        onResult(tagList);
      } else {
        throw WpyDioError(error: '校务专区获取标签失败, 请刷新');
      }
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static getPosts(
      {keyword,
      @required tagId,
      @required page,
      @required void Function(List<Post> list, int totalPage) onSuccess,
      @required OnFailure onFailure}) async {
    try {
      var pref = CommonPreferences();
      var response = await feedbackDio.get(
        'question/search',
        queryParameters: {
          'searchType': pref.feedbackSearchType.value,
          'searchString': keyword ?? '',
          'tagList': '[$tagId]',
          'limits': '20',
          'token': pref.feedbackToken.value,
          'page': '$page',
        },
      );
      List<Post> list = [];
      for (Map<String, dynamic> json in response.data['data']['data']) {
        list.add(Post.fromJson(json));
      }
      onSuccess(list, response.data['data']['last_page']);
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
        'question/get/myQuestion',
        queryParameters: {
          'limits': 0,
          'token': CommonPreferences().feedbackToken.value,
          'page': 1,
        },
      );
      List<Post> list = [];
      for (Map<String, dynamic> json in response.data['data']) {
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
        'question/get/byId',
        queryParameters: {
          'id': id,
          'token': CommonPreferences().feedbackToken.value,
        },
      );
      var post = Post.fromJson(response.data['data']);
      onResult(post);
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static getOfficialComment({
    @required id,
    @required void Function(List<Comment> officialCommentList) onSuccess,
    @required OnFailure onFailure,
  }) async {
    try {
      var officialCommentResponse =
          await feedbackDio.get('question/get/answer', queryParameters: {
        'question_id': '$id',
        'token': CommonPreferences().feedbackToken.value,
      });
      List<Comment> officialCommentList = [];
      for (Map<String, dynamic> json in officialCommentResponse.data['data']) {
        officialCommentList.add(Comment.fromJson(json));
      }
      onSuccess(officialCommentList);
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static getComments({
    @required id,
    @required void Function(List<Comment> commentList, int totalPage) onSuccess,
    @required OnFailure onFailure,
    @required int page,
  }) async {
    try {
      var commentResponse = await feedbackDio.get(
        'question/get/commitPaginated',
        queryParameters: {
          'question_id': '$id',
          'token': CommonPreferences().feedbackToken.value,
          'limits': 10,
          'page': page,
        },
      );
      List<Comment> commentList = [];
      for (Map<String, dynamic> json in commentResponse.data['data']['data']) {
        commentList.add(Comment.fromJson(json));
      }
      onSuccess(commentList, commentResponse.data['data']['last_page']);
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static getFavoritePosts({
    @required OnResult<List<Post>> onResult,
    @required OnFailure onFailure,
  }) async {
    try {
      var response = await feedbackDio.get(
        'favorite/get/all',
        queryParameters: {'token': CommonPreferences().feedbackToken.value},
      );
      List<Post> list = [];
      for (Map<String, dynamic> json in response.data['data']) {
        list.add(Post.fromJson(json));
      }
      onResult(list);
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
        await feedbackDio.post(isLiked ? 'question/dislike' : 'question/like',
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

  static postHitFavorite({
    @required id,
    @required bool isFavorite,
    @required OnSuccess onSuccess,
    @required OnFailure onFailure,
  }) async {
    AsyncTimer.runRepeatChecked('postHitFavorite', () async {
      try {
        await feedbackDio.post(
            isFavorite ? 'question/unfavorite' : 'question/favorite',
            formData: FormData.fromMap({
              'question_id': id,
              'token': CommonPreferences().feedbackToken.value,
            }));
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

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

  static sendComment(
      {@required id,
      @required content,
      @required OnSuccess onSuccess,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('sendComment', () async {
      try {
        await feedbackDio.post(
          'commit/add/question',
          formData: FormData.fromMap({
            'token': CommonPreferences().feedbackToken.value,
            'question_id': id,
            'contain': content,
          }),
        );
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static sendPost(
      {@required title,
      @required content,
      @required tagId,
      @required campus,
      @required List<File> imgList,
      @required OnSuccess onSuccess,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('sendPost', () async {
      try {
        var response = await feedbackDio.post('question/add',
            formData: FormData.fromMap({
              'token': CommonPreferences().feedbackToken.value,
              'name': title,
              'description': content,
              'tagList': '[$tagId]',
              'campus': campus,
            }));
        if (imgList.isNotEmpty) {
          // TODO 这里之后改成一起调用吧，一个个上传太慢了
          for (int index = 0; index < imgList.length; index++) {
            var data = FormData.fromMap({
              'token': CommonPreferences().feedbackToken.value,
              'newImg': MultipartFile.fromBytes(
                imgList[index].readAsBytesSync(),
                filename: 'p${response.data['data']['question_id']}i$index.jpg',
                contentType: MediaType("image", "jpg"),
              ),
              'question_id': response.data['data']['question_id'],
            });
            await feedbackDio.post('image/add', formData: data);
          }
        }
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

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
        await feedbackDio.post(
          'question/delete',
          formData: FormData.fromMap({
            'token': CommonPreferences().feedbackToken.value,
            'question_id': id,
          }),
        );
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  /// 举报问题 / 评论
  static report(
      {@required id,
        @required isQuestion,
        @required reason,
        @required OnSuccess onSuccess,
        @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('reportQuestion', () async {
      var target = isQuestion ? 'question' : 'commit';
      try {
        await feedbackDio.post(
          '$target/complain',
          formData: FormData.fromMap({
            'token': CommonPreferences().feedbackToken.value,
            '${target}_id': id,
            'reason': reason,
          }),
        );
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }
}

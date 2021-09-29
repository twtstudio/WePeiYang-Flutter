import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/feedback/model/comment.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/model/post.dart';
import 'package:we_pei_yang_flutter/feedback/model/tag.dart';
import 'package:we_pei_yang_flutter/main.dart';

class FeedbackDio extends DioAbstract {
  // String baseUrl = 'http://47.94.198.197:10805/api/user/';
  @override
  String baseUrl = 'https://areas.twt.edu.cn/api/user/';

  @override
  List<InterceptorsWrapper> interceptors = [
    InterceptorsWrapper(onResponse: (Response response) {
      var code = response?.data['ErrorCode'] ?? 0;
      switch (code) {
        case 0: // 成功
          return response;
        case 10: // 含有敏感词，需要把敏感词也展示出来
          throw WpyDioError(
              error: response.data['msg'] +
                  '\n' +
                  response.data['data']['bad_word_list']
                      .toSet()
                      .toList()
                      .toString());
        default: // 其他错误
          throw WpyDioError(error: response.data['msg']);
      }
    })
  ];
}

final feedbackDio = FeedbackDio();

FeedbackNotifier notifier = Provider.of<FeedbackNotifier>(
    WePeiYangApp.navigatorState.currentContext,
    listen: false);

class FeedbackService with AsyncTimer {
  static getToken({OnResult<String> onResult, OnFailure onFailure}) async {
    try {
      var cid = await messageChannel.invokeMethod<String>("getCid");
      var response = await feedbackDio.post(
        'login',
        formData: FormData.fromMap({
          'username': CommonPreferences().account.value,
          'password': CommonPreferences().password.value,
          'cid': cid,
        }),
      );
      if (response.data['data'] != null &&
          response.data['data']['token'] != null) {
        CommonPreferences().feedbackToken.value =
            response.data['data']['token'];
        if (onResult != null) onResult(response.data['data']['token']);
      } else {
        throw DioError(error: '校务专区登录失败, 请刷新');
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
        List<Tag> tagList = List();
        for (Map<String, dynamic> json in response.data['data'][0]
            ['children']) {
          tagList.add(Tag.fromJson(json));
        }
        onResult(tagList);
      } else {
        throw DioError(error: '校务专区获取标签失败, 请刷新');
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
      var response = await feedbackDio.get(
        'question/search',
        queryParameters: {
          'searchString': keyword ?? '',
          'tagList': '[$tagId]',
          'limits': '20',
          'token': Provider.of<FeedbackNotifier>(
                  WePeiYangApp.navigatorState.currentContext,
                  listen: false)
              .token,
          'page': '$page',
        },
      );
      List<Post> list = List();
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
          'token': notifier.token,
          'page': 1,
        },
      );
      List<Post> list = List();
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
          'token': notifier.token,
        },
      );
      var post = Post.fromJson(response.data['data']);
      onResult(post);
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static getComments({
    @required id,
    @required
        void Function(
                List<Comment> officialCommentList, List<Comment> commentList)
            onSuccess,
    @required OnFailure onFailure,
  }) async {
    try {
      var officialCommentResponse =
          await feedbackDio.get('question/get/answer', queryParameters: {
        'question_id': '$id',
        'token': notifier.token,
      });
      var commentResponse = await feedbackDio.get(
        'question/get/commit',
        queryParameters: {
          'question_id': '$id',
          'token': notifier.token,
        },
      );
      List<Comment> officialCommentList = List();
      List<Comment> commentList = List();
      for (Map<String, dynamic> json in officialCommentResponse.data['data']) {
        officialCommentList.add(Comment.fromJson(json));
      }
      for (Map<String, dynamic> json in commentResponse.data['data']) {
        commentList.add(Comment.fromJson(json));
      }
      onSuccess(officialCommentList, commentList);
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
        queryParameters: {'token': notifier.token},
      );
      List<Post> list = List();
      for (Map<String, dynamic> json in response.data['data']) {
        list.add(Post.fromJson(json));
      }
      onResult(list);
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static postHitLike({
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
              'token': notifier.token,
            }));
        onSuccess();
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
              'token': notifier.token,
            }));
        onSuccess();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static commentHitLike(
      {@required id,
      @required bool isLiked,
      @required OnSuccess onSuccess,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('commentHitLike', () async {
      try {
        await feedbackDio.post(isLiked ? 'commit/dislike' : 'commit/like',
            formData: FormData.fromMap({
              'id': '$id',
              'token': notifier.token,
            }));
        onSuccess();
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
              'token': notifier.token,
            }));
        onSuccess();
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
            'token': notifier.token,
            'question_id': id,
            'contain': content,
          }),
        );
        onSuccess();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static sendPost(
      {@required title,
      @required content,
      @required tagId,
      @required List<File> imgList,
      @required OnSuccess onSuccess,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('sendPost', () async {
      try {
        var response = await feedbackDio.post('question/add',
            formData: FormData.fromMap({
              'token': notifier.token,
              'name': title,
              'description': content,
              'tagList': '[$tagId]',
              'campus': 0,
            }));
        if (imgList.isNotEmpty) {
          for (int index = 0; index < imgList.length; index++) {
            var data = FormData.fromMap({
              'token': notifier.token,
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
        onSuccess();
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
            'token': notifier.token,
            'answer_id': id,
            'score': rating.toInt(),
            'commit': '评分',
          }),
        );
        onSuccess();
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
            'token': notifier.token,
            'question_id': id,
          }),
        );
        onSuccess();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }
}

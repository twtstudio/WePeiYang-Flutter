import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/new_network/dio_manager.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/feedback/model/comment.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/model/post.dart';
import 'package:we_pei_yang_flutter/feedback/model/tag.dart';
import 'package:we_pei_yang_flutter/main.dart';

class FeedbackDio extends DioAbstract {
  @override
  // String baseUrl = 'http://47.94.198.197:10805/api/user/';

  String baseUrl =  'https://areas.twt.edu.cn/api/user/';

  @override
  Map<String, String> headers = {};

  @override
  List<InterceptorsWrapper> interceptors = [];
}

final _client = FeedbackDio();

bool _hitLikeLock = false;
bool _hitFavoriteLock = false;
bool _sendCommentLock = false;
bool _sendPostLock = false;
bool _rateLock = false;
bool _deleteLock = false;

FeedbackNotifier notifier = Provider.of<FeedbackNotifier>(
    WePeiYangApp.navigatorState.currentContext,
    listen: false);

Future getToken(
    {@required void Function(String token) onSuccess,
    @required void Function() onFailure}) async {
  try {
    Response response = await _client.post(
      'login',
      queryParameters: {
        'username': CommonPreferences().account.value,
        'password': CommonPreferences().password.value,
      },
    );
    if (null != response.data['data'] &&
        null != response.data['data']['token']) {
      CommonPreferences().feedbackToken.value = response.data['data']['token'];
      onSuccess(response.data['data']['token']);
    } else {
      onFailure();
    }
  } on DioError catch (e) {
    log('校务专区网络问题\t$e\n\tMessage: ${e.message}');
    onFailure();
  }
}

Future getTags(token,
    {@required void Function(List<Tag> tagList) onSuccess,
    @required void Function() onFailure}) async {
  try {
    Response response = await _client.get('tag/get/all', queryParameters: {
      'token': token,
    });
    if (0 == response.data['ErrorCode'] &&
        0 != response.data['data'][0]['children'].length) {
      List<Tag> tagList = List();
      for (Map<String, dynamic> json in response.data['data'][0]['children']) {
        tagList.add(Tag.fromJson(json));
      }
      onSuccess(tagList);
    } else {
      log(response.data.toString());
      onFailure();
    }
  } on DioError catch (e) {
    log('校务专区网络问题\t$e\n\tMessage: ${e.message}');
    onFailure();
  }
}

Future getPosts(
    {keyword,
    @required tagId,
    @required page,
    @required void Function(List<Post> list, int totalPage) onSuccess,
    @required onFailure}) async {
  try {
    Response response = await _client.get(
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
    if (0 == response.data['ErrorCode']) {
      List<Post> list = List();
      for (Map<String, dynamic> json in response.data['data']['data']) {
        list.add(Post.fromJson(json));
      }
      onSuccess(list, response.data['data']['last_page']);
    } else {
      onFailure();
    }
  } on DioError catch (e) {
    log('校务专区网络问题\t$e\n\tMessage: ${e.message}');
    onFailure();
  }
}

Future getMyPosts({
  @required void Function(List<Post> list) onSuccess,
  @required void Function() onFailure,
}) async {
  try {
    log("notifier.token ${notifier.token}");
    Response response = await _client.get(
      'question/get/myQuestion',
      queryParameters: {
        'limits': 0,
        'token': notifier.token,
        'page': 1,
      },
    );
    if (0 == response.data['ErrorCode']) {
      List<Post> list = List();
      for (Map<String, dynamic> json in response.data['data']) {
        list.add(Post.fromJson(json));
      }
      onSuccess(list);
    } else {
      log("${response.data.toString()}");
      onFailure();
    }
  } on DioError catch (e) {
    log('校务专区网络问题\t$e\n\tMessage: ${e.message}');
    onFailure();
  }
}

Future getPostById({
  @required int id,
  @required void Function(Post post) onSuccess,
  @required void Function() onFailure,
}) async {
  try {
    Response response = await _client.get(
      'question/get/byId',
      queryParameters: {
        'id': id,
        'token': notifier.token,
      },
    );
    if (0 == response.data['ErrorCode']) {
      Post post = Post.fromJson(response.data['data']);
      onSuccess(post);
    } else {
      onFailure();
    }
  } on DioError catch (e) {
    log('校务专区网络问题\t$e\n\tMessage: ${e.message}');
    onFailure();
  }
}

Future getComments({
  @required id,
  @required
      void Function(
              List<Comment> officialCommentList, List<Comment> commentList)
          onSuccess,
  @required void Function() onFailure,
}) async {
  try {
    Response officialCommentResponse =
        await _client.get('question/get/answer', queryParameters: {
      'question_id': '$id',
      'token': notifier.token,
    });
    Response commentResponse = await _client.get(
      'question/get/commit',
      queryParameters: {
        'question_id': '$id',
        'token': notifier.token,
      },
    );
    if (0 == officialCommentResponse.data['ErrorCode'] &&
        0 == commentResponse.data['ErrorCode']) {
      List<Comment> officialCommentList = List();
      List<Comment> commentList = List();
      for (Map<String, dynamic> json in officialCommentResponse.data['data']) {
        officialCommentList.add(Comment.fromJson(json));
      }
      for (Map<String, dynamic> json in commentResponse.data['data']) {
        commentList.add(Comment.fromJson(json));
        print(json.toString());
        print(commentList.length);
      }
      onSuccess(officialCommentList, commentList);
    } else {
      onFailure();
    }
  } on DioError catch (e) {
    log('校务专区网络问题\t$e\n\tMessage: ${e.message}');
    onFailure();
  }
}

Future getFavoritePosts({
  @required void Function(List<Post> list) onSuccess,
  @required void Function() onFailure,
}) async {
  try {
    Response response = await _client.get(
      'favorite/get/all',
      queryParameters: {'token': notifier.token},
    );
    if (0 == response.data['ErrorCode']) {
      List<Post> list = List();
      for (Map<String, dynamic> json in response.data['data']) {
        list.add(Post.fromJson(json));
      }
      onSuccess(list);
    } else {
      onFailure();
    }
  } on DioError catch (e) {
    log('校务专区网络问题\t$e\n\tMessage: ${e.message}');
    onFailure();
  }
}

Future postHitLike({
  @required id,
  @required bool isLiked,
  @required void Function() onSuccess,
  @required void Function() onFailure,
}) async {
  if (!_hitLikeLock) {
    _hitLikeLock = true;
    try {
      Response response = await _client.post(
          isLiked ? 'question/dislike' : 'question/like',
          queryParameters: {
            'id': '$id',
            'token': notifier.token,
          });
      if (0 == response.data['ErrorCode']) {
        onSuccess();
      } else {
        onFailure();
      }
      _hitLikeLock = false;
    } on DioError catch (e) {
      log('校务专区网络问题\t$e\n\tMessage: ${e.message}');
      onFailure();
      _hitLikeLock = false;
    }
  }
}

Future postHitFavorite({
  @required id,
  @required bool isFavorite,
  @required void Function() onSuccess,
  @required void Function() onFailure,
}) async {
  if (!_hitFavoriteLock) {
    _hitFavoriteLock = true;
    try {
      Response response = await _client.post(
          isFavorite ? 'question/unfavorite' : 'question/favorite',
          queryParameters: {
            'question_id': id,
            'token': notifier.token,
          });
      if (0 == response.data['ErrorCode']) {
        onSuccess();
      } else {
        onFailure();
      }
      _hitFavoriteLock = false;
    } on DioError catch (e) {
      log('校务专区网络问题\t$e\n\tMessage: ${e.message}');
      onFailure();
      _hitFavoriteLock = false;
    }
  }
}

Future commentHitLike(
    {@required id,
    @required bool isLiked,
    @required void Function() onSuccess,
    @required void Function() onFailure}) async {
  if (!_hitLikeLock) {
    _hitLikeLock = true;
    try {
      Response response = await _client
          .post(isLiked ? 'commit/dislike' : 'commit/like', queryParameters: {
        'id': '$id',
        'token': notifier.token,
      });
      if (0 == response.data['ErrorCode']) {
        onSuccess();
      } else {
        onFailure();
      }
      _hitLikeLock = false;
    } on DioError catch (e) {
      log('校务专区网络问题\t$e\n\tMessage: ${e.message}');
      onFailure();
      _hitLikeLock = false;
    }
  }
}

Future officialCommentHitLike(
    {@required id,
    @required bool isLiked,
    @required void Function() onSuccess,
    @required void Function() onFailure}) async {
  if (!_hitLikeLock) {
    _hitLikeLock = true;
    try {
      Response response = await _client
          .post(isLiked ? 'answer/dislike' : 'answer/like', queryParameters: {
        'id': '$id',
        'token': notifier.token,
      });
      if (0 == response.data['ErrorCode']) {
        onSuccess();
      } else {
        onFailure();
      }
      _hitLikeLock = false;
    } on DioError catch (e) {
      log('校务专区网络问题\t$e\n\tMessage: ${e.message}');
      onFailure();
      _hitLikeLock = false;
    }
  }
}

Future sendComment(
    {@required id,
    @required content,
    @required void Function() onSuccess,
    @required void Function() onFailure}) async {
  if (!_sendCommentLock) {
    _sendCommentLock = true;
    try {
      Response response = await _client.post(
        'commit/add/question',
        queryParameters: {
          'token': notifier.token,
          'question_id': id,
          'contain': content,
        },
      );
      if (0 == response.data['ErrorCode']) {
        onSuccess();
      } else {
        onFailure();
      }
      _sendCommentLock = false;
    } on DioError catch (e) {
      log('校务专区网络问题\t$e\n\tMessage: ${e.message}');
      onFailure();
      _sendCommentLock = false;
    }
  }
}

Future sendPost(
    {@required title,
    @required content,
    @required tagId,
    @required List<File> imgList,
    @required void Function() onSuccess,
    @required void Function() onFailure,
    @required void Function() onUploadImageFailure}) async {
  if (!_sendPostLock) {
    _sendPostLock = true;
    try {
      Response response = await _client.post('question/add', queryParameters: {
        'token': notifier.token,
        'name': title,
        'description': content,
        'tagList': '[$tagId]',
        'campus': 0,
      });
      if (0 == response.data['ErrorCode']) {
        // debugPrint(
        //     "send question success ${response.data['data']['question_id']}");

        if (imgList.isNotEmpty) {
          for (int index = 0; index < imgList.length; index++) {
            FormData data = FormData.fromMap({
              'token': notifier.token,
              'newImg': MultipartFile.fromBytes(
                imgList[index].readAsBytesSync(),
                filename: 'p${response.data['data']['question_id']}i$index.jpg',
                contentType: MediaType("image", "jpg"),
              ),
              'question_id': response.data['data']['question_id'],
            });
            Response uploadImgResponse =
                await _client.post('image/add', formData: data);
            if (0 != uploadImgResponse.data['ErrorCode']) {
              onUploadImageFailure();
              log(response.data['data'].toString());
              log(uploadImgResponse.data.toString());
            }
            if (0 == uploadImgResponse.data['ErrorCode'] &&
                index == imgList.length - 1) {
              onSuccess();
            }
          }
        } else {
          onSuccess();
        }
      } else {
        onFailure();
      }
      _sendPostLock = false;
    } on DioError catch (e) {
      log('校务专区网络问题\t$e\n\tMessage: ${e.message}');
      onFailure();
      _sendPostLock = false;
    }
  }
}

Future rate(
    {@required id,
    @required rating,
    @required void Function() onSuccess,
    @required void Function() onFailure}) async {
  if (!_rateLock) {
    _rateLock = true;
    try {
      Response response = await _client.post(
        'answer/commit',
        queryParameters: {
          'token': notifier.token,
          'answer_id': id,
          'score': rating.toInt(),
          'commit': '评分',
        },
      );
      if (0 == response.data['ErrorCode']) {
        onSuccess();
      } else {
        onFailure();
      }
      _rateLock = false;
    } on DioError catch (e) {
      log('校务专区网络问题\t$e\n\tMessage: ${e.message}');
      onFailure();
      _rateLock = false;
    }
  }
}

Future deletePost(
    {@required id,
    @required void Function() onSuccess,
    @required void Function() onFailure}) async {
  if (!_deleteLock) {
    _deleteLock = true;
    try {
      Response response = await _client.post(
        'question/delete',
        queryParameters: {
          'token': notifier.token,
          'question_id': id,
        },
      );
      if (0 == response.data['ErrorCode']) {
        onSuccess();
      } else {
        onFailure();
      }
      _deleteLock = false;
    } on DioError catch (e) {
      log('校务专区网络问题\t$e\n\tMessage: ${e.message}');
      onFailure();
      _deleteLock = false;
    }
  }
}

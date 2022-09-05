import 'dart:io';

import 'package:flutter/material.dart' show required;
import 'package:http_parser/http_parser.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';

class FeedbackDio extends DioAbstract {
  @override
  String baseUrl = '${EnvConfig.QNHD}api/v1/f/';

  // String baseUrl = 'https://www.zrzz.site:7013/api/v1/f/';

  @override
  List<InterceptorsWrapper> interceptors = [
    InterceptorsWrapper(onRequest: (options, handler) {
      options.headers['token'] = CommonPreferences.lakeToken.value;
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
          var data = response.data['data'];
          if (data == null || data['error'] == null) return;
          return handler.reject(WpyDioError(error: data['error']), true);
      }
    })
  ];
}

class FeedbackPicPostDio extends DioAbstract {
  @override
  String baseUrl = EnvConfig.QNHDPIC;

  @override
  List<InterceptorsWrapper> interceptors = [
    InterceptorsWrapper(onRequest: (options, handler) {
      options.headers['token'] = CommonPreferences.lakeToken.value;
      return handler.next(options);
    }, onResponse: (response, handler) {
      var code = response?.data['code'] ?? 0;
      switch (code) {
        case 200: // 成功
          return handler.next(response);
        default: // 其他错误
          return handler.reject(WpyDioError(error: response.data['msg']), true);
      }
    })
  ];
}

class FeedbackAdminPostDio extends DioAbstract {
  @override
  String baseUrl = '${EnvConfig.QNHD}api/v1/b/';

  // String baseUrl = 'https://www.zrzz.site:7013/api/v1/b/';

  @override
  List<InterceptorsWrapper> interceptors = [
    InterceptorsWrapper(onRequest: (options, handler) {
      options.headers['token'] = CommonPreferences.lakeToken.value;
      return handler.next(options);
    }, onResponse: (response, handler) {
      var code = response?.data['code'] ?? 0;
      switch (code) {
        case 200: // 成功
          return handler.next(response);
        default: // 其他错误
          return handler.reject(WpyDioError(error: response.data['msg']), true);
      }
    })
  ];
}

final feedbackDio = FeedbackDio();
final feedbackPicPostDio = FeedbackPicPostDio();
final feedbackAdminPostDio = FeedbackAdminPostDio();

class FeedbackService with AsyncTimer {
  static getToken(
      {OnResult<String> onResult,
      OnFailure onFailure,
      bool forceRefresh = false}) async {
    try {
      var response;
      if (CommonPreferences.lakeToken.value != null &&
          CommonPreferences.lakeToken.value != "" &&
          !forceRefresh) {
        response =
            await feedbackDio.get('auth/${CommonPreferences.lakeToken.value}');
      } else {
        response = await feedbackDio.get('auth/token', queryParameters: {
          'token': CommonPreferences.token.value,
        });
      }
      if (response.data['data'] != null &&
          response.data['data']['token'] != null) {
        CommonPreferences.lakeToken.value = response.data['data']['token'];
        CommonPreferences.lakeUid.value =
            response.data['data']['uid'].toString();
        if (response.data['data']['user'] != null) {
          CommonPreferences.isSuper.value =
              response.data['data']['user']['is_super'];
          CommonPreferences.isSchAdmin.value =
              response.data['data']['user']['is_sch_admin'];
          CommonPreferences.isStuAdmin.value =
              response.data['data']['user']['is_stu_admin'];
          CommonPreferences.isUser.value =
              response.data['data']['user']['is_user'];
        }
        if (onResult != null) onResult(response.data['data']['token']);
      }
    } on DioError catch (e) {
      if (!forceRefresh) {
        getToken(forceRefresh: true);
      } else if (onFailure != null) onFailure(e);
    }
  }

  static getTokenByPw(
    String user,
    String passwd, {
    OnSuccess onSuccess,
    OnFailure onFailure,
  }) async {
    try {
      var response = await feedbackDio.get('auth/passwd', queryParameters: {
        'user': user,
        'password': passwd,
      });
      if (response.data['data']['token'] != null)
        CommonPreferences.lakeToken.value = response.data['data']['token'];
      onSuccess();
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

  static uploadAvatars(String avatar,
      {@required OnSuccess onSuccess, @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('avatar', () async {
      try {
        var data = FormData.fromMap({
          'avatar': avatar,
        });
        feedbackDio.post("user/avatar", formData: data);
        onSuccess();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static Future<void> postPic(
      {@required List<File> images,
      @required OnResult<List<String>> onResult,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('postPic', () async {
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
        var response =
            await feedbackPicPostDio.post('upload/image', formData: formData);
        List<String> list = [];
        for (String json in response.data['data']['urls']) {
          list.add(json);
        }
        onResult(list);
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static Future<List<WPYTab>> getTabList() async {
    var response = await feedbackDio.get('posttypes');
    List<WPYTab> list = [];
    for (Map<String, dynamic> json in response.data['data']['list']) {
      list.add(WPYTab.fromJson(json));
    }
    return list;
  }

  static Future<Error> getError(
    name,
  ) async {
    Error error;
    var response = await feedbackDio.post('tag',
        formData: FormData.fromMap({
          'name': '$name',
        }));
    Map<String, dynamic> json = response.data['data'];
    error = Error.fromJson(json);
    return error;
  }

  static getHotTags({
    @required OnResult<List<Tag>> onSuccess,
    @required OnFailure onFailure,
  }) async {
    try {
      var response = await feedbackDio.get('tags/hot');
      List<Tag> list = [];
      for (Map<String, dynamic> json in response.data['data']['list']) {
        list.add(Tag.fromJson(json));
      }
      onSuccess(list);
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static getFestCards({
    @required OnResult<List<Festival>> onSuccess,
    @required OnFailure onFailure,
  }) async {
    try {
      var response = await feedbackDio.get('banners');
      List<Festival> list = [];
      for (Map<String, dynamic> json in response.data['data']['list']) {
        list.add(Festival.fromJson(json));
      }
      onSuccess(list);
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static getNotices({
    @required OnResult<List<Notice>> onResult,
    @required OnFailure onFailure,
  }) async {
    try {
      var response = await feedbackDio.get(
        'message/notices/department',
      );
      List<Notice> list = [];
      for (Map<String, dynamic> json in response.data['data']['list']) {
        list.add(Notice.fromJson(json));
      }
      onResult(list);
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static getRecTag({
    @required OnResult<Tag> onSuccess,
    @required OnFailure onFailure,
  }) async {
    try {
      var response = await feedbackDio.get('tag/recommend');
      Tag tag;
      Map<String, dynamic> json = response.data['data']['tag'];
      tag = Tag.fromJson(json);

      onSuccess(tag);
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static searchTags(
      {@required name,
      @required OnResult<List<SearchTag>> onResult,
      @required OnFailure onFailure}) async {
    try {
      var response = await feedbackDio.get(
        'tags',
        queryParameters: {
          'name': '$name',
        },
      );
      List<SearchTag> list = [];
      for (Map<String, dynamic> json in response.data['data']['list']) {
        list.add(SearchTag.fromJson(json));
      }
      onResult(list);
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static Future<void> postTags({
    @required name,
    @required void Function(PostTagId postTagId) onSuccess,
    @required onFailure,
  }) async {
    AsyncTimer.runRepeatChecked('postTags', () async {
      try {
        var response = await feedbackDio.post('tag',
            formData: FormData.fromMap({
              'name': '$name',
            }));
        Map<String, dynamic> json = response.data['data'];
        onSuccess?.call(PostTagId.fromJson(json));
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static getPosts(
      {keyword,
      departmentId,
      tagId,
      searchMode,
      etag,
      @required type,
      @required page,
      @required void Function(List<Post> list, int totalPage) onSuccess,
      @required OnFailure onFailure}) async {
    try {
      var response = await feedbackDio.get(
        'posts',
        queryParameters: {
          'type': '$type',
          'search_mode': searchMode ?? 0,
          'etag': etag ?? '',
          'content': keyword ?? '',
          'tag_id': tagId ?? '',
          'department_id': departmentId ?? '',

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
    @required page,
    @required page_size,
    @required OnFailure onFailure,
  }) async {
    try {
      var response = await feedbackDio.get(
        'posts/user',
        queryParameters: {
          'page': '$page',
          'page_size': '$page_size',
        },
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
    @required page_size,
    @required page,
    @required OnFailure onFailure,
  }) async {
    try {
      var response = await feedbackDio.get(
        'posts/fav',
        queryParameters: {
          'page': '$page',
          'page_size': '$page_size',
        },
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

  static getFloorReplyById({
    @required int floorId,
    int page,
    @required OnResult<List<Floor>> onResult,
    @required OnFailure onFailure,
  }) async {
    try {
      var response = await feedbackDio.get(
        'floor/replys',
        queryParameters: {
          'floor_id': '$floorId',
          'page': '$page',
          'page_size': '10',
          'pageBase': '0',
        },
      );
      final floor = FloorList.fromJson(response.data['data']);
      onResult(floor.list);
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static visitPost({
    @required int id,
    @required OnFailure onFailure,
  }) async {
    try {
      await feedbackDio.post('post/visit',
          formData: FormData.fromMap({
            'post_id': '$id',
          }));
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

  static getOfficialComment({
    @required id,
    @required void Function(List<Floor> officialCommentList) onSuccess,
    @required OnFailure onFailure,
  }) async {
    try {
      var commentResponse = await feedbackDio.get(
        'post/replys',
        queryParameters: {
          'post_id': '$id',
        },
      );
      List<Floor> officialCommentList = [];
      for (Map<String, dynamic> json in commentResponse.data['data']['list']) {
        officialCommentList.add(Floor.fromJson(json));
      }
      onSuccess(officialCommentList);
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static getFloorById({
    @required int id,
    @required OnResult<Floor> onResult,
    @required OnFailure onFailure,
  }) async {
    try {
      var response = await feedbackDio.get(
        'floor',
        queryParameters: {
          'floor_id': '$id',
        },
      );
      var floor = Floor.fromJson(response.data['data']['floor']);
      onResult(floor);
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  ///comments改成了floors，需要点赞字段
  static getComments({
    @required id,
    @required order,
    @required onlyOwner,
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
          'order': '$order',
          'only_owner': '$onlyOwner'
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
    @required bool isLike,
    @required OnSuccess onSuccess,
    @required OnFailure onFailure,
  }) async {
    AsyncTimer.runRepeatChecked('postHitLike', () async {
      try {
        await feedbackDio.post('post/like',
            formData: FormData.fromMap({
              'post_id': '$id',
              'op': isLike ? 0 : 1,
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
        await feedbackDio.post('post/fav',
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
        await feedbackDio.post('post/dis',
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

  static Future<void> changeNickname({
    @required String nickName,
    @required OnSuccess onSuccess,
    @required OnFailure onFailure,
  }) async {
    AsyncTimer.runRepeatChecked('changeNickname', () async {
      try {
        await feedbackDio.post('user/name',
            formData: FormData.fromMap({
              'name': '$nickName',
            }));
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static getUserInfo({
    @required OnSuccess onSuccess,
    @required OnFailure onFailure,
  }) async {
    try {
      var response = await feedbackDio.get('user');
      CommonPreferences.lakeUid.value =
          response.data['data']['user']['id'].toString();
      CommonPreferences.lakeNickname.value =
          response.data['data']['user']['nickname'];
      CommonPreferences.isSuper.value =
          response.data['data']['user']['is_super'];
      CommonPreferences.isSchAdmin.value =
          response.data['data']['user']['is_sch_admin'];
      CommonPreferences.avatar.value = response.data['data']['user']['avatar'];
      CommonPreferences.isStuAdmin.value =
          response.data['data']['user']['is_stu_admin'];
      CommonPreferences.levelPoint.value =
          response.data['data']['user']['level_point'];
      CommonPreferences.level.value =
          response.data['data']['user']['level_info']['level'];
      CommonPreferences.nextLevelPoint.value =
          response.data['data']['user']['level_info']['next_level_point'];
      CommonPreferences.curLevelPoint.value =
          response.data['data']['user']['level_info']['cur_level_point'];
      CommonPreferences.levelName.value =
          response.data['data']['user']['level_info']['level_name'];
      onSuccess?.call();
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static Future<void> commentHitLike(
      {@required id,
      @required bool isLike,
      @required OnSuccess onSuccess,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('commentHitLike', () async {
      try {
        await feedbackDio.post('floor/like',
            formData: FormData.fromMap({
              'floor_id': '$id',
              'op': isLike ? 0 : 1,
            }));
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static Future<void> commentHitDislike(
      {@required id,
      @required bool isDis,
      @required OnSuccess onSuccess,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('commentHitDislike', () async {
      try {
        await feedbackDio.post('floor/dis',
            formData: FormData.fromMap({
              'floor_id': '$id',
              'op': isDis ? 0 : 1,
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
              'token': CommonPreferences.lakeToken.value,
            }));
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static sendFloor(
      {@required id,
      @required content,
      @required List<String> images,
      @required OnSuccess onSuccess,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('sendFloor', () async {
      try {
        var formData = FormData.fromMap({
          'post_id': id,
          'content': content,
        });
        if (images.isNotEmpty) {
          for (int i = 0; i < images.length; i++)
            formData.fields.addAll([MapEntry('images', images[i])]);
        }
        await feedbackDio.post('floor', formData: formData);
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static replyFloor(
      {@required id,
      @required content,
      @required List<String> images,
      @required OnSuccess onSuccess,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('replyFloor', () async {
      try {
        var formData = FormData.fromMap({
          'reply_to_floor': id,
          'content': content,
        });
        if (images.isNotEmpty) {
          for (int i = 0; i < images.length; i++)
            formData.fields.addAll([MapEntry('images', images[i])]);
        }
        await feedbackDio.post('floor/reply', formData: formData);
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static replyOfficialFloor(
      {@required id,
      @required content,
      @required List<String> images,
      @required OnSuccess onSuccess,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('replyOfficialFloor', () async {
      try {
        var formData = FormData.fromMap({
          'post_id': id,
          'content': content,
        });
        if (images.isNotEmpty) {
          for (int i = 0; i < images.length; i++)
            formData.fields.addAll([MapEntry('images', images[i])]);
        }
        await feedbackDio.post('post/reply', formData: formData);
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
      @required List<String> images,
      @required OnSuccess onSuccess,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('sendPost', () async {
      try {
        var formData = FormData.fromMap({
          'type': type,
          'title': title,
          'content': content,
          'department_id': departmentId,
          'tag_id': tagId,
          'campus': campus,
        });
        if (images.isNotEmpty) {
          for (int i = 0; i < images.length; i++)
            formData.fields.addAll([MapEntry('images', images[i])]);
        }
        await feedbackDio.post('post', formData: formData);
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
          'post/solve',
          formData: FormData.fromMap({
            'post_id': '$id',
            'rating': '$rating',
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

  /// 举报问题 / 评论
  static report(
      {@required id,
      floorId,
      @required isQuestion,
      @required reason,
      @required OnSuccess onSuccess,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('report', () async {
      try {
        var formData = FormData();
        if (isQuestion) {
          formData = FormData.fromMap({
            'type': 1,
            'post_id': id,
            'reason': reason,
          });
        } else {
          formData = FormData.fromMap({
            'type': 2,
            'post_id': id,
            'floor_id': floorId,
            'reason': reason,
          });
        }
        await feedbackDio.post(
          'report',
          formData: formData,
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
    AsyncTimer.runRepeatChecked('deleteFloor', () async {
      try {
        await feedbackDio.get(
          'floor/delete',
          queryParameters: {
            'floor_id': '$id',
          },
        );
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static adminDeletePost(
      {@required id,
      @required OnSuccess onSuccess,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('adminDeletePost', () async {
      try {
        await feedbackAdminPostDio.get(
          'post/delete',
          queryParameters: {
            'id': id,
          },
        );
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static adminDeleteReply(
      {@required floorId,
      @required OnSuccess onSuccess,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('adminDeleteReply', () async {
      try {
        await feedbackAdminPostDio.get(
          'floor/delete',
          queryParameters: {
            'floor_id': floorId,
          },
        );
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static adminTopPost(
      {@required id,
      @required hotIndex,
      @required OnSuccess onSuccess,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('adminTopPost', () async {
      try {
        await feedbackAdminPostDio.post('post/value',
            formData: FormData.fromMap({
              'post_id': id,
              'value': hotIndex,
            }));
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static adminChangeETag(
      {@required id,
      @required value,
      @required OnSuccess onSuccess,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('adminChangeETag', () async {
      try {
        await feedbackAdminPostDio.post('post/etag',
            formData: FormData.fromMap({
              'post_id': id,
              'value': value,
            }));
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static superAdminOpenBox(
      {@required uid,
      @required OnResult<String> onResult,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('superAdminDeleteReply', () async {
      try {
        var response = await feedbackAdminPostDio.get(
          'user/detail',
          queryParameters: {
            'uid': uid,
          },
        );
        var obd = response.data['data']['detail'];
        String openBoxDetail = 'hh';
        if (obd != null)
          openBoxDetail =
              '学号：${obd["userNumber"] ?? '无学号'}\n昵称：${obd["nickname"] ?? '无昵称'}\n电话：${obd["telephone"] ?? '无电话'}\n邮箱：${obd["email"] ?? '无邮箱'}\ntoken：${obd["token"] ?? '无token'}\n真名：${obd["realname"] ?? '无真名'}\n性别：${obd["gender"] ?? '无性别'}\n学院/部：${obd["department"] ?? '无学院/部'}\n专业：${obd["major"] ?? '无专业'}\n种类：${obd["stuType"] ?? '无种类'}\n校区：${obd["campus"] ?? '无校区'}\n身份证号：${obd["idNumber"] ?? '无身份证号'}\n';
        onResult(openBoxDetail);
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static adminResetName(
      {@required id,
      @required OnSuccess onSuccess,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('adminResetName', () async {
      try {
        await feedbackAdminPostDio.post('user/nickname/reset',
            formData: FormData.fromMap({
              'uid': id,
            }));
        onSuccess?.call();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }
}

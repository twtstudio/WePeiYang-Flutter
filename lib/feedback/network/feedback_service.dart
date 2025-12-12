import 'dart:async';
import 'dart:io';

import 'package:http_parser/http_parser.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/token/lake_token_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/type_util.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';

class FeedbackDio extends DioAbstract {
  @override
  String baseUrl = '${EnvConfig.QNHD}api/v1/f/';

  //String baseUrl = 'http://8.141.166.181:7013/api/v1/f/';

  @override
  List<Interceptor> interceptors = [
    InterceptorsWrapper(onRequest: (options, handler) async {
      options.headers['token'] = (await LakeTokenManager().token);
      return handler.next(options);
    }, onResponse: (response, handler) {
      var code = response.data['code'] ?? 0;
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
          return handler.reject(WpyDioException(error: data['error']), true);
      }
    })
  ];
}

class FeedbackPicPostDio extends DioAbstract {
  @override
  String baseUrl = EnvConfig.QNHDPIC;

  @override
  List<Interceptor> interceptors = [
    InterceptorsWrapper(onRequest: (options, handler) async {
      options.headers['token'] = (await LakeTokenManager().token);
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

class FeedbackAdminPostDio extends DioAbstract {
  @override
  String baseUrl = '${EnvConfig.QNHD}api/v1/b/';

  @override
  List<Interceptor> interceptors = [
    InterceptorsWrapper(onRequest: (options, handler) async {
      options.headers['token'] = (await LakeTokenManager().token);
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

final feedbackDio = FeedbackDio();
final feedbackPicPostDio = FeedbackPicPostDio();
final feedbackAdminPostDio = FeedbackAdminPostDio();

class FeedbackService with AsyncTimer {

  static List<String> get shieldComment =>
      CommonPreferences.shieldComment.value;

  //判断是否改屏蔽
  static bool CommentBlockCheck(Floor item) {
    final content = item.content ?? '';
    for (final pattern in shieldComment) {
      if (pattern.trim().isEmpty) continue;

      // 判断是否包含正则特殊字符
      final isRegex = RegExp(r'[.^$*+?{}\[\]()|\\]').hasMatch(pattern);

      if (isRegex) {
        // 按正则表达式匹配
        try {
          final reg = RegExp(pattern);
          if (reg.hasMatch(content)) return true;//匹配上
        } catch (e) {
          // 正则格式错误，忽略
          continue;
        }
      } else {
        //精准匹配
        if (pattern == content) return true;//匹配上
      }
    }

    //没匹配上，开始该评论的评论的匹配
    if(item.subFloors.isNotEmpty) {
      List<Floor> subFloors = [];
      for (final subitem in item.subFloors) {
        if (!CommentBlockCheck(subitem)) {
          subFloors.add(subitem);
        }
      }
      item.subFloors = subFloors;
    }

    return false;
  }


  static getTokenByPw(
    String user,
    String passwd, {
    required OnSuccess onSuccess,
    required OnFailure onFailure,
  }) async {
    try {
      var response = await feedbackDio.get('auth/passwd', queryParameters: {
        'user': user,
        'password': passwd,
      });
      if (response.data['data']['token'] != null)
        CommonPreferences.lakeToken.value = response.data['data']['token'];
      onSuccess();
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static getDepartments(token,
      {required OnResult<List<Department>> onResult,
      required OnFailure onFailure}) async {
    try {
      var response = await feedbackDio.get('departments');
      if (response.data['data']['total'] != 0) {
        List<Department> departmentList = [];
        for (Map<String, dynamic> json in response.data['data']['list']) {
          departmentList.add(Department.fromJson(json));
        }
        onResult(departmentList);
      } else {
        throw WpyDioException(error: '校务专区获取标签失败, 请刷新');
      }
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static uploadAvatars(String avatar,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('avatar', () async {
      try {
        var data = FormData.fromMap({
          'avatar': avatar,
        });
        feedbackDio.post("user/avatar", formData: data);
        onSuccess();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  static Future<void> postPic(
      {required List<File> images,
      required OnResult<List<String>> onResult,
      required OnFailure onFailure}) async {
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

  static Future<List<WPYTab>> getTabList() async {
    var response = await feedbackDio.get('posttypes');
    List<WPYTab> list = [];
    for (Map<String, dynamic> json in response.data['data']['list']) {
      list.add(WPYTab.fromJson(json));
    }
    return list;
  }

  static getHotTags({
    required OnResult<List<Tag>> onSuccess,
    required OnFailure onFailure,
  }) async {
    try {
      var response = await feedbackDio.get('tags/hot');
      List<Tag> list = [];
      for (Map<String, dynamic> json in response.data['data']['list']) {
        list.add(Tag.fromJson(json));
      }
      onSuccess(list);
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static getFestCards({
    required OnResult<List<Festival>> onSuccess,
    required OnFailure onFailure,
  }) async {
    try {
      var response = await feedbackDio.get('banners');
      List<Festival> list = [];
      for (Map<String, dynamic> json in response.data['data']['list']) {
        list.add(Festival.fromJson(json));
      }
      onSuccess(list);
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static getNotices({
    required OnResult<List<Notice>> onResult,
    required OnFailure onFailure,
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
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static getRecTag({
    required OnResult<Tag> onSuccess,
    required OnFailure onFailure,
  }) async {
    try {
      var response = await feedbackDio.get('tag/recommend');
      Tag tag;
      Map<String, dynamic> json = response.data['data']['tag'];
      tag = Tag.fromJson(json);

      onSuccess(tag);
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static searchTags(
      {required name,
      required OnResult<List<SearchTag>> onResult,
      required OnFailure onFailure}) async {
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
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static Future<void> postTags({
    required name,
    required void Function(PostTagId postTagId) onSuccess,
    required onFailure,
  }) async {
    AsyncTimer.runRepeatChecked('postTags', () async {
      try {
        var response = await feedbackDio.post('tag',
            formData: FormData.fromMap({
              'name': '$name',
            }));
        Map<String, dynamic> json = response.data['data'];
        onSuccess.call(PostTagId.fromJson(json));
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  static Future<void> postShare({
    required id,
    required type,
    required onSuccess,
    required onFailure,
  }) async {
    AsyncTimer.runRepeatChecked('share', () async {
      try {
        await feedbackDio.post('share',
            formData: FormData.fromMap({
              'object_id': id,
              'type': type,
            }));
        onSuccess?.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  static Future<Tuple2<List<Post>, int>> getPosts({
    keyword,
    departmentId,
    tagId,
    searchMode,
    eTag,
    required type,
    required page,
  }) async {
    var response = await feedbackDio.get(
      'posts',
      queryParameters: {
        'type': '$type',
        'search_mode': searchMode ?? 0,
        'etag': eTag ?? '',
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
      final item = Post.fromJson(json);
      list.add(item);
    }
    return Tuple2(list, response.data['data']['total']);
  }

  static getMyPosts({
    required OnResult<List<Post>> onResult,
    required page,
    required page_size,
    required OnFailure onFailure,
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
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static getAnyonePosts({
    required OnResult<List<Post>> onResult,
    required uid,
    required page,
    required page_size,
    required OnFailure onFailure,
  }) async {
    try {
      // 注意這裏用的dio和上面那個不一樣哦
      var response = await feedbackAdminPostDio.get(
        'posts/user',
        queryParameters: {
          'uid': '$uid',
          'type': '0',
          'page': '$page',
          'page_size': '$page_size',
        },
      );
      List<Post> list = [];
      for (Map<String, dynamic> json in response.data['data']['list']) {
        list.add(Post.fromJson(json));
      }
      onResult(list);
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static getFavoritePosts({
    required OnResult<List<Post>> onResult,
    required page_size,
    required page,
    required OnFailure onFailure,
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
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static getHistoryPosts({
    required OnResult<List<Post>> onResult,
    required page_size,
    required page,
    required OnFailure onFailure,
  }) async {
    try {
      var response = await feedbackDio.get(
        'posts/history',
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
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static getFloorReplyById({
    required int floorId,
    required int page,
    required OnResult<List<Floor>> onResult,
    required OnFailure onFailure,
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
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static visitPost({
    required int id,
    required OnFailure onFailure,
  }) async {
    try {
      await feedbackDio.post('post/visit',
          formData: FormData.fromMap({'post_id': '$id'}));
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static getPostById({
    required int id,
    required OnResult<Post> onResult,
    required OnFailure onFailure,
  }) async {
    try {
      var response = await feedbackDio.get(
        'post',
        queryParameters: {'id': '$id'},
      );
      var post = Post.fromJson(response.data['data']['post']);
      onResult(post);
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static getOfficialComment({
    required id,
    required void Function(List<Floor> officialCommentList) onSuccess,
    required OnFailure onFailure,
  }) async {
    try {
      var commentResponse = await feedbackDio.get(
        'post/replys',
        queryParameters: {'post_id': '$id'},
      );
      List<Floor> officialCommentList = [];
      for (Map<String, dynamic> json in commentResponse.data['data']['list']) {
        officialCommentList.add(Floor.fromJson(json));
      }
      onSuccess(officialCommentList);
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static getFloorById({
    required int id,
    required OnResult<Floor> onResult,
    required OnFailure onFailure,
  }) async {
    try {
      var response = await feedbackDio.get(
        'floor',
        queryParameters: {'floor_id': '$id'},
      );
      var floor = Floor.fromJson(response.data['data']['floor']);
      onResult(floor);
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  ///comments改成了floors，需要点赞字段
  static getComments({
    required id,
    required order,
    required onlyOwner,
    required void Function(List<Floor> commentList, int totalPage) onSuccess,
    required OnFailure onFailure,
    required int page,
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
        final item = Floor.fromJson(json);
        //判断是否屏蔽
        bool isBlock = CommentBlockCheck(item);
        if (isBlock) continue;
        //用户屏蔽由后端来做
        commentList.add(item);
      }
      onSuccess(commentList, commentResponse.data['data']['total']);
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static Future<void> postHitLike({
    required id,
    required bool isLike,
    required OnSuccess onSuccess,
    required OnFailure onFailure,
  }) async {
    AsyncTimer.runRepeatChecked('postHitLike', () async {
      try {
        await feedbackDio.post('post/like',
            formData: FormData.fromMap({
              'post_id': '$id',
              'op': isLike ? 0 : 1,
            }));
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  static postHitFavorite({
    required id,
    required bool isFavorite,
    required OnSuccess onSuccess,
    required OnFailure onFailure,
  }) async {
    AsyncTimer.runRepeatChecked('postHitFavorite', () async {
      try {
        await feedbackDio.post('post/fav',
            formData: FormData.fromMap({
              'post_id': id,
              'op': isFavorite ? 0 : 1,
            }));
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  static Future<void> postHitDislike({
    required id,
    required bool isDisliked,
    required OnSuccess onSuccess,
    required OnFailure onFailure,
  }) async {
    AsyncTimer.runRepeatChecked('postHitDislike', () async {
      try {
        await feedbackDio.post('post/dis',
            formData: FormData.fromMap({
              'post_id': '$id',
              'op': isDisliked ? 0 : 1,
            }));
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  static Future<void> changeNickname({
    required String nickName,
    required OnSuccess onSuccess,
    required OnFailure onFailure,
  }) async {
    AsyncTimer.runRepeatChecked('changeNickname', () async {
      try {
        await feedbackDio.post('user/name',
            formData: FormData.fromMap({'name': '$nickName'}));
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  static getUserInfo({
    required OnSuccess onSuccess,
    required OnFailure onFailure,
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
      onSuccess.call();
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static Future<void> commentHitLike(
      {required id,
      required bool isLike,
      required OnSuccess onSuccess,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('commentHitLike', () async {
      try {
        await feedbackDio.post('floor/like',
            formData: FormData.fromMap({
              'floor_id': '$id',
              'op': isLike ? 0 : 1,
            }));
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  static Future<void> commentHitDislike(
      {required id,
      required bool isDis,
      required OnSuccess onSuccess,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('commentHitDislike', () async {
      try {
        await feedbackDio.post('floor/dis',
            formData: FormData.fromMap({
              'floor_id': '$id',
              'op': isDis ? 0 : 1,
            }));
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  ///暂时没有接口，后面改
  static officialCommentHitLike(
      {required id,
      required bool isLiked,
      required OnSuccess onSuccess,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('officialCommentHitLike', () async {
      try {
        await feedbackDio.post(isLiked ? 'answer/dislike' : 'answer/like',
            formData: FormData.fromMap({
              'id': '$id',
              'token': await LakeTokenManager().token,
            }));
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  static sendFloor(
      {required id,
      required content,
      required List<String> images,
      required OnSuccess onSuccess,
      required OnFailure onFailure}) async {
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
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  static replyFloor(
      {required id,
      required content,
      required List<String> images,
      required OnSuccess onSuccess,
      required OnFailure onFailure}) async {
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
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  static replyOfficialFloor(
      {required id,
      required content,
      required List<String> images,
      required OnSuccess onSuccess,
      required OnFailure onFailure}) async {
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
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  static sendPost(
      {required type,
      required title,
      required content,
      departmentId,
      tagId,
      List<int> masked = const [],
      required campus,
      required List<String> images,
      required OnSuccess onSuccess,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('sendPost', () async {
      try {
        var formData = FormData.fromMap({
          'type': type,
          'title': title,
          'content': content,
          'department_id': departmentId,
          'tag_id': tagId,
          'campus': campus,
          'masked': masked.join(','),
        });
        if (images.isNotEmpty) {
          for (int i = 0; i < images.length; i++)
            formData.fields.addAll([MapEntry('images', images[i])]);
        }
        await feedbackDio.post('post', formData: formData);
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  ///暂时没有接口，后面改
  static rate(
      {required String id,
      required String rating,
      required OnSuccess onSuccess,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('rate', () async {
      try {
        await feedbackDio.post(
          'post/solve',
          formData: FormData.fromMap({
            'post_id': id,
            'rating': rating,
          }),
        );
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  static deletePost(
      {required id,
      required OnSuccess onSuccess,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('deletePost', () async {
      try {
        await feedbackDio.get(
          'post/delete',
          queryParameters: {'post_id': id},
        );
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 举报问题 / 评论
  static report(
      {required id,
      floorId,
      required isQuestion,
      required reason,
      required OnSuccess onSuccess,
      required OnFailure onFailure}) async {
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
        await feedbackDio.post('report', formData: formData);
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  static deleteFloor(
      {required id,
      required OnSuccess onSuccess,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('deleteFloor', () async {
      try {
        await feedbackDio.get(
          'floor/delete',
          queryParameters: {'floor_id': '$id'},
        );
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  static adminDeletePost(
      {required id,
      String? reason,
      required OnSuccess onSuccess,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('adminDeletePost', () async {
      try {
        await feedbackAdminPostDio.get(
          'post/delete',
          queryParameters: {
            'id': id,
            if (reason != null) 'reason': reason,
          },
        );
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  static adminDeleteReply(
      {required floorId,
      required OnSuccess onSuccess,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('adminDeleteReply', () async {
      try {
        await feedbackAdminPostDio.get(
          'floor/delete',
          queryParameters: {'floor_id': floorId},
        );
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  static adminTopPost(
      {required id,
      required hotIndex,
      required OnSuccess onSuccess,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('adminTopPost', () async {
      try {
        await feedbackAdminPostDio.post('post/value',
            formData: FormData.fromMap({
              'post_id': id,
              'value': hotIndex,
            }));
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  static adminFloorTopPost(
      {required id,
      required hotIndex,
      required OnSuccess onSuccess,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('adminFloorTopPost', () async {
      try {
        await feedbackAdminPostDio.post('floor/value',
            formData: FormData.fromMap({
              'floor_id': id,
              'value': hotIndex,
            }));
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  static adminChangeETag(
      {required id,
      required value,
      required OnSuccess onSuccess,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('adminChangeETag', () async {
      try {
        await feedbackAdminPostDio.post('post/etag',
            formData: FormData.fromMap({
              'post_id': id,
              'value': value,
            }));
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  static superAdminOpenBox(
      {required uid,
      required OnResult<Map<String, String>> onResult,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('superAdminDeleteReply', () async {
      try {
        var response = await feedbackAdminPostDio.get(
          'user/detail',
          queryParameters: {'uid': uid},
        );
        var obd = response.data['data']['detail'];
        Map<String, String> openBoxDetail = {};
        if (obd != null)
          openBoxDetail = {
            '真名': obd["realname"] ?? '无真名',
            '学号': obd["userNumber"] ?? '无学号',
            '学院/部': obd["department"] ?? '无学院/部',
            '身份证号': obd["idNumber"] ?? '无身份证号',
            '归属地': '在线查询身份证号归属地',
            '电话': obd["telephone"] ?? '无电话',
            '邮箱': obd["email"] ?? '无邮箱',
            '性别': obd["gender"] ?? '无性别',
            '专业': obd["major"] ?? '无专业',
            '种类': obd["stuType"] ?? '无种类',
            '校区': obd["campus"] ?? '无校区',
          };
        onResult(openBoxDetail);
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  static adminResetName(
      {required id,
      required OnSuccess onSuccess,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('adminResetName', () async {
      try {
        await feedbackAdminPostDio.post('user/nickname/reset',
            formData: FormData.fromMap({'uid': id}));
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  static adminResetAva(
      {required id,
      required OnSuccess onSuccess,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('adminResetAva', () async {
      try {
        await feedbackAdminPostDio.post('user/avatar/reset',
            formData: FormData.fromMap({'uid': id}));
        onSuccess.call();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 获取iOS是否显示拉黑按钮
  static Future<bool> getIOSShowBlock() async {
    try {
      final res = await feedbackDio.get('setting');
      return res.data['data']['data']['ios_lahei'];
    } catch (e) {
      return false;
    }
  }

  /// 后端只返回hidden = false的所有数据
  static Future<List<AvatarBox>> getAllAvatarBox() async {
    List<AvatarBox> avatarBoxList = [];
    try {
      var res = await feedbackDio.get('frame/all');
      var list = AvatarBoxList.fromJson(res.data['data']);
      avatarBoxList.clear();
      avatarBoxList.addAll(list.avatarFrameList);
    } on DioException catch (e) {
      print(e.error);
    }
    return avatarBoxList;
  }

  static Future<List<AvatarBox>> getTypeAvatarBox(String type) async {
    List<AvatarBox> avatarBoxList = [];
    try {
      var res = await feedbackDio
          .get('frame/type_url', queryParameters: {'type': type});
      var list = AvatarBoxList.fromJson(res.data['data']);
      avatarBoxList.clear();
      avatarBoxList.addAll(list.avatarFrameList);
    } on DioException catch (e) {
      print(e.error);
    }
    return avatarBoxList;
  }

  static Future<void> setAvatarBox(AvatarBox avatarBox) async {
    try {
      var res = await feedbackDio.post('frame/set',
          formData: FormData.fromMap({'aid': avatarBox.id}));
      if (res.data['code'] == 200) {
        ToastProvider.success('好耶!头像框设置成功! (≧ω≦)/');
        CommonPreferences.avatarBoxMyUrl.value = avatarBox.addr;
      } else {
        ToastProvider.error('坏耶!头像框设置失败!');
      }
    } on DioException catch (e) {
      ToastProvider.error('坏耶!头像框设置失败!');
      print(e.error);
    }
  }

  static Future<void> updateVote(
      {required int id, required List<int> options}) async {
    var res = await feedbackDio.post('post/vote',
        formData:
            FormData.fromMap({'vote_id': id, 'selected': options.join(',')}));
    if (res.data['code'] == 200) {
      ToastProvider.success('投票成功');
      return;
    }
    throw WpyDioException(error: res.data['msg']);
  }

  static Future<void> addVote({
    required int type,
    required String title,
    required List<String> options,
    required int campus,
    required String tagId,
    required int maxSelect,
  }) async {
    final formData = FormData.fromMap({
      'type': type,
      'title': title,
      'campus': campus,
      'tag_id': tagId,
      'max_selection': maxSelect,
    });
    options.forEach((element) {
      formData.fields.addAll([MapEntry('options', element)]);
    });
    final res = await feedbackDio.post('post/vote/new', formData: formData);
    print("==> d ${res.data}");
    if (res.data['code'] == 200) {
      return;
    }
    throw WpyDioException(error: res.data['msg']);
  }
}

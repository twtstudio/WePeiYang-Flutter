import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';
import 'package:flutter/foundation.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/message/message_model.dart';

class MessageRepository {
  static Future<FeedbackDetailMessages> getDetailMessages(int page) async {
    var token = CommonPreferences().feedbackToken.value;
    var response = await messageApi.get("get",
        queryParameters: {"token": token, "limits": 10, "page": page});
    FeedbackDetailMessages messages =
        FeedbackDetailMessages.fromJson(response.data);
    debugPrint("getDetailMessages");
    debugPrint(CommonPreferences().feedbackToken.value);
    debugPrint(response.data.toString());
    return messages;
  }

  static Future<TotalMessageData> getAllMessages() async {
    var token = CommonPreferences().feedbackToken.value;
    var response =
        await messageApi.get("qid", queryParameters: {"token": token});
    TotalMessageData data = TotalMessageData.fromJson(response.data);
    debugPrint('getAllMessages');
    debugPrint(token);
    debugPrint(response.data.toString());
    return data;
  }

  static setQuestionRead(int questionId) async {
    var token = CommonPreferences().feedbackToken.value;
    await messageApi.post("question",
        queryParameters: {"token": token, "question_id": questionId});
  }
}

final messageApi = MessageServer();

class MessageServer extends DioForNative {
  MessageServer() {
    options.connectTimeout = 3000;
    options.receiveTimeout = 3000;
    options.responseType = ResponseType.plain;
    options.baseUrl = 'http://47.94.198.197:10805/api/user/message/';
    options.headers = {"Connection": "close"};
    interceptors.add(ApiInterceptor());
  }
}

class ApiInterceptor extends InterceptorsWrapper {
  @override
  onRequest(RequestOptions options) async {
    // debugPrint('---api-request--->url--> ${options.baseUrl}${options.path}' +
    //     ' queryParameters: ${options.queryParameters}');
//    debugPrint('---api-request--->data--->${options.data}');
    return options;
  }

  @override
  onResponse(Response response) async {
    final String data = response.data.toString();
    final bool isCompute = data.length > 10 * 1024;
    final Map<dynamic, dynamic> _map =
        isCompute ? await compute(parseData, data) : parseData(data);
    FeedbackMessageBaseData respData = FeedbackMessageBaseData.fromJson(_map);
    if (respData.success) {
      response.data = respData.data;
      return messageApi.resolve(response);
    } else {
      /// TODO: 不知道开放接口会返回什么错误信息
      // if (respData.code == 2) {
      //   // 如果cookie过期,需要清除本地存储的登录信息
      //   // StorageManager.localStorage.deleteItem(UserModel.keyUser);
      //   throw const UnAuthorizedException(); // 需要登录
      // } else {
      //   throw NotSuccessException.fromRespData(respData);
      // }
      throw NotSuccessException.fromRespData(respData);
    }
  }
}

class NotSuccessException implements Exception {
  String message;

  NotSuccessException.fromRespData(FeedbackMessageBaseData respData) {
    message = respData.message;
  }

  @override
  String toString() {
    return 'NotExpectedException{respData: $message}';
  }
}

Map<dynamic, dynamic> parseData(String data) {
  return jsonDecode(data);
}

class FeedbackMessageBaseData {
  int code;
  String message;
  dynamic data;

  bool get success => code == 0;

  FeedbackMessageBaseData.fromJson(Map<String, dynamic> json) {
    code = json['ErrorCode'];
    message = json['msg'];
    data = json['data'];
  }
}

class FeedbackDetailMessages {
  int currentPage;
  List<FeedbackMessageItem> data;
  int to;
  int total;
  int from;

  FeedbackDetailMessages.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'] ?? 0;
    data = (json['data'] as List ?? [])
        .map<FeedbackMessageItem>((m) => FeedbackMessageItem.fromJson(m))
        .toList();
    from = json['from'] ?? 0;
    to = json['to'] ?? 0;
    total = json['total'] ?? 0;
  }
}

class FeedbackMessageItem {
  int id, type;
  String createdAt, updatedAt;
  Contain contain;
  Question question;

  FeedbackMessageItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['create_at'];
    type = json['type'] ?? 0;
    updatedAt = json['update_at'];
    contain = Contain.fromJson(json['contain'] ?? '');
    question = Question.fromJson(json['question'] ?? '');
  }

  Map get json => {
        "id": id,
        "type": type,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "contain": contain.toJson(),
        "question": question.toJson(),
      };
}

class Contain {
  int id;
  String content;
  int userId;
  int adminId;
  int likeCount;
  int rating;
  String createTime;
  String updatedTime;
  String userName;
  String adminName;
  bool isLiked;

  Contain({
    this.id,
    this.content,
    this.userId,
    this.adminId,
    this.likeCount,
    this.rating,
    this.createTime,
    this.updatedTime,
    this.userName,
    this.adminName,
    this.isLiked,
  });

  Contain.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    content = json['contain'];
    userId = json['user_id'];
    adminId = json['admin_id'];
    likeCount = json['likes'];
    rating = json['score'];
    createTime = json['created_at'];
    updatedTime = json['updated_at'];
    userName = json['username'];
    adminName = json['adminname'];
    isLiked = json['is_liked'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['contain'] = this.content;
    data['user_id'] = this.userId;
    data['admin_id'] = this.adminId;
    data['likes'] = this.likeCount;
    data['created_at'] = this.createTime;
    data['updated_at'] = this.updatedTime;
    data['username'] = this.userName;
    data['adminname'] = this.adminName;
    data['is_liked'] = this.isLiked;
    return data;
  }
}

class Question {
  int id;
  String title;
  String content;
  int campus;
  int userId;
  int isSolved;
  int isCommentForbidden;
  int likeCount;
  String createTime;
  String updatedTime;
  String userName;
  int commentCount;
  List<String> imgUrlList;
  List<String> thumbImgUrlList;
  String topImgUrl;
  List<Tag> tags;
  bool isLiked;
  bool isFavorite;
  bool isOwner;

  Question(
      {this.id,
      this.title,
      this.content,
      this.campus,
      this.userId,
      this.isSolved,
      this.isCommentForbidden,
      this.likeCount,
      this.createTime,
      this.updatedTime,
      this.userName,
      this.commentCount,
      this.imgUrlList,
      this.thumbImgUrlList,
      this.topImgUrl,
      this.tags,
      this.isLiked,
      this.isFavorite,
      this.isOwner});

  Question.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['name'];
    content = json['description'];
    campus = json['campus'];
    userId = json['user_id'];
    isSolved = json['solved'];
    isCommentForbidden = json['no_commit'];
    likeCount = json['likes'];
    createTime = json['created_at'];
    updatedTime = json['updated_at'];
    userName = json['username'];
    commentCount = json['msgCount'];
    if (json['url_list'] != null) {
      imgUrlList = new List<String>();
      json['url_list'].forEach((v) {
        imgUrlList.add(v);
      });
    }
    if (json['thumb_url_list'] != null) {
      thumbImgUrlList = new List<String>();
      json['thumb_url_list'].forEach((v) {
        thumbImgUrlList.add(v);
      });
    }
    topImgUrl = json['thumbImg'];
    if (json['tags'] != null) {
      tags = new List<Tag>();
      json['tags'].forEach((v) {
        tags.add(new Tag.fromJson(v));
      });
    }
    isLiked = json['is_liked'];
    isFavorite = json['is_favorite'];
    isOwner = json['is_owner'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.title;
    data['description'] = this.content;
    data['campus'] = this.campus;
    data['user_id'] = this.userId;
    data['solved'] = this.isSolved;
    data['no_commit'] = this.isCommentForbidden;
    data['likes'] = this.likeCount;
    data['created_at'] = this.createTime;
    data['updated_at'] = this.updatedTime;
    data['username'] = this.userName;
    data['msgCount'] = this.commentCount;
    data['thumbImg'] = this.topImgUrl;
    if (this.tags != null) {
      data['tags'] = this.tags.map((v) => v.toJson()).toList();
    }
    data['is_liked'] = this.isLiked;
    data['is_owner'] = this.isOwner;
    return data;
  }
}

class Tag {
  int id;
  String name;

  Tag({this.id, this.name});

  Tag.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

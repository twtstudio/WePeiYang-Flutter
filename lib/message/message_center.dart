import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';
import 'package:flutter/foundation.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/feedback/model/comment.dart';
import 'package:we_pei_yang_flutter/feedback/model/post.dart';
import 'package:we_pei_yang_flutter/message/feedback_message_page.dart';
import 'package:we_pei_yang_flutter/message/message_model.dart';
import 'package:we_pei_yang_flutter/message/user_mails_page.dart';

import '../main.dart';

class MessageRepository {
  static Future<FeedbackDetailMessages> getDetailMessages(
      MessageType type, int page) async {
    var token = CommonPreferences().feedbackToken.value;
    var response = await messageApi.get("get", queryParameters: {
      "token": token,
      "limits": 10,
      "page": page,
      "type": type.index
    });
    FeedbackDetailMessages messages =
        FeedbackDetailMessages.fromJson(response.data);
    return messages;
  }

  static Future<TotalMessageData> getAllMessages() async {
    var token = CommonPreferences().feedbackToken.value;
    TotalMessageData data;
    try {
      var response = await messageApi.get(
        "qid",
        queryParameters: {"token": token},
      );
      data = TotalMessageData.fromJson(response.data);
    } catch (e) {
      data = null;
      print(e.toString());
    }
    return data;
  }

  static setQuestionRead(int questionId) async {
    var token = CommonPreferences().feedbackToken.value;
    await messageApi.post("question",
        queryParameters: {"token": token, "question_id": questionId});
    await messageChannel.invokeMethod<String>(
      "cancelNotification",
      {"id": questionId},
    );
  }

  static Future<UserMessages> getUserMails(int page) async {
    var token = CommonPreferences().token.value;
    var response = await Dio().get(
      "https://api.twt.edu.cn/api/notification/history/user",
      options: Options(
        headers: {
          "DOMAIN": AuthDio.DOMAIN,
          "ticket": AuthDio.ticket,
          "token": token,
        },
      ),
    );
    var messages = UserMessages.fromJson(response.data);
    return messages;
  }
}

final messageApi = MessageServer();

class MessageServer extends DioForNative {
  MessageServer() {
    options.connectTimeout = 3000;
    options.receiveTimeout = 3000;
    options.responseType = ResponseType.plain;
    // options.baseUrl = 'http://47.94.198.197:10805/api/user/message/';
    options.baseUrl = 'https://areas.twt.edu.cn/api/user/message/';
    options.headers = {"Connection": "close"};
    interceptors.add(ApiInterceptor());
    interceptors.add(LogInterceptor());
  }
}

class ApiInterceptor extends InterceptorsWrapper {
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
  int id, type, visible;
  String createdAt, updatedAt;
  Comment comment;
  Post post;

  FeedbackMessageItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    visible = json['visible'] ?? 0;
    createdAt = json['created_at'];
    type = json['type'] ?? 0;
    updatedAt = json['updated_at'];
    comment = json['contain'] == "" || json['contain'] == null
        ? null
        : Comment.fromJson(json['contain']);
    post = Post.fromJson(json['question'] ?? '');
  }

  Map get json => {
        "id": id,
        "type": type,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "contain": comment.toJson(),
        "question": post.toJson(),
      };
}

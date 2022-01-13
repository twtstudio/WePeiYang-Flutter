import 'dart:convert' show jsonDecode;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show compute;

import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/feedback/network/comment.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/message/feedback_message_page.dart';
import 'package:we_pei_yang_flutter/message/message_model.dart';
import 'package:we_pei_yang_flutter/message/user_mails_page.dart';

class MessageService {
  static Future<FeedbackDetailMessages> getDetailMessages(
      MessageType type, int page) async {
    var token = CommonPreferences().feedbackToken.value;
    var response = await messageDio.get("get", queryParameters: {
      "token": token,
      "limits": 10,
      "page": page,
      "type": type.index
    });
    return FeedbackDetailMessages.fromJson(response.data);
  }

  static Future<TotalMessageData> getAllMessages() async {
    var token = CommonPreferences().feedbackToken.value;
    TotalMessageData data;
    try {
      var response =
          await messageDio.get("qid", queryParameters: {"token": token});
      data = TotalMessageData.fromJson(response.data);
    } catch (e) {
      data = null;
    }
    return data;
  }

  static setQuestionRead(int questionId) async {
    var token = CommonPreferences().feedbackToken.value;
    await messageDio.post("question",
        queryParameters: {"token": token, "question_id": questionId});
    await pushChannel
        .invokeMethod<String>("cancelNotification", {"id": questionId});
  }

  static Future<UserMessages> getUserMails(int page) async {
    var response = await userDio
        .get('https://api.twt.edu.cn/api/notification/history/user');
    var messages = UserMessages.fromJson(response.data);
    return messages;
  }

  static Future<bool> setFeedbackMessageReadAll() async {
    try {
      await messageDio.post("readAll",
          formData: FormData.fromMap(
              {"token": CommonPreferences().feedbackToken.value}));
      return true;
    } catch (_) {
      return false;
    }
  }
}

final userDio = UserNotificationDio();
final messageDio = MessageDio();

class UserNotificationDio extends DioAbstract {
  @override
  Map<String, String> headers = {
    "DOMAIN": AuthDio.DOMAIN,
    "ticket": AuthDio.ticket,
    "token": CommonPreferences().token.value
  };
}

class MessageDio extends DioAbstract {
  // @override
  // String baseUrl = 'http://47.94.198.197:10805/api/user/message/';

  @override
  String baseUrl = 'https://areas.twt.edu.cn/api/user/message/';

  @override
  Map<String, String> headers = {"Connection": "close"};

  @override
  List<InterceptorsWrapper> interceptors = [ApiInterceptor()];

  /// 这里不能改，因为下面手动解析的字符串
  @override
  ResponseType responseType = ResponseType.plain;
}

class ApiInterceptor extends InterceptorsWrapper {
  @override
  onResponse(response, handler) async {
    final String data = response.data.toString();
    final bool isCompute = data.length > 10 * 1024;
    final Map<dynamic, dynamic> _map =
        isCompute ? await compute(parseData, data) : parseData(data);
    FeedbackMessageBaseData respData = FeedbackMessageBaseData.fromJson(_map);
    if (respData.success) {
      response.data = respData.data;
      return handler.resolve(response);
    } else {
      return handler.reject(WpyDioError(error: respData.message), true);
    }
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
}

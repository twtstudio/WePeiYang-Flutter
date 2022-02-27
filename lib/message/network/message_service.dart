import 'dart:convert' show jsonDecode;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/message/model/message_model.dart';
import 'package:we_pei_yang_flutter/message/user_mails_page.dart';

class MessageService {
  static getUnreadMessagesCount(
      {@required OnResult<MessageCount> onResult,
      @required OnFailure onFailure}) async {
    try {
      var response = await messageDio.get("count");
      onResult(MessageCount.fromJson(response.data['count']));
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static getLikeMessages(
      {@required int page,
      @required void Function(List<LikeMessage> list, int total) onSuccess,
      @required OnFailure onFailure}) async {
    try {
      var response = await messageDio.get("likes", queryParameters: {
        "page_size": 10,
        "page": page,
      });
      List<LikeMessage> list = [];
      for (Map<String, dynamic> json in response.data['list']) {
        list.add(LikeMessage.fromJson(json));
      }
      onSuccess(list, response.data['total']);
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static getFloorMessages(
      {@required page,
      @required void Function(List<FloorMessage> list, int totalPage) onSuccess,
      @required OnFailure onFailure}) async {
    try {
      var response = await messageDio.get("floors", queryParameters: {
        "page_size": 10,
        "page": page,
      });
      List<FloorMessage> list = [];
      for (Map<String, dynamic> json in response.data['list']) {
        list.add(FloorMessage.fromJson(json));
      }
      onSuccess(list, response.data['total']);
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static getReplyMessages(
      {@required page,
        @required void Function(List<ReplyMessage> list, int totalPage) onSuccess,
        @required OnFailure onFailure}) async {
    try {
      var response = await messageDio.get("replys", queryParameters: {
        "page_size": 10,
        "page": page,
      });
      List<ReplyMessage> list = [];
      for (Map<String, dynamic> json in response.data['list']) {
        list.add(ReplyMessage.fromJson(json));
      }
      onSuccess(list, response.data['total']);
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static getNoticeMessages(
      {@required page,
        @required void Function(List<NoticeMessage> list, int totalPage) onSuccess,
        @required OnFailure onFailure}) async {
    try {
      var response = await messageDio.get("notices", queryParameters: {
        "page_size": 10,
        "page": page,
      });
      List<NoticeMessage> list = [];
      for (Map<String, dynamic> json in response.data['list']) {
        list.add(NoticeMessage.fromJson(json));
      }
      onSuccess(list, response.data['total']);
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static setLikeMessageRead(int id, int type,
      {OnSuccess onSuccess, OnFailure onFailure}) async {
    try {
      await messageDio.post("like/read",
          formData: FormData.fromMap({"id": id, "type": type}));
      onSuccess();
    } on DioError catch (e) {
      onFailure(e);
    }

    ///涉及推送原生部分代码，随后再改
    // await pushChannel
    //     .invokeMethod<String>("cancelNotification", {"id": questionId});
  }

  static setReplyMessageRead(int id,
      {OnSuccess onSuccess, OnFailure onFailure}) async {
    try {
      await messageDio.post("reply/read",
          formData: FormData.fromMap({"id": id}));
      onSuccess();
    } on DioError catch (e) {
      onFailure(e);
    }

    ///涉及推送原生部分代码，随后再改
    // await pushChannel
    //     .invokeMethod<String>("cancelNotification", {"id": questionId});
  }

  static setFloorMessageRead(int id,
      {OnSuccess onSuccess, OnFailure onFailure}) async {
    try {
      await messageDio.post("floor/read",
          formData: FormData.fromMap({"id": id}));
      onSuccess();
    } on DioError catch (e) {
      onFailure(e);
    }
    ///涉及推送原生部分代码，随后再改
    // await pushChannel
    //     .invokeMethod<String>("cancelNotification", {"id": questionId});
  }

  static setNoticeMessageRead(int id,
      {OnSuccess onSuccess, OnFailure onFailure}) async {
    try {
      await messageDio.post("notice/read",
          formData: FormData.fromMap({"id": id}));
      onSuccess();
    } on DioError catch (e) {
      onFailure(e);
    }

    ///涉及推送原生部分代码，随后再改
    // await pushChannel
    //     .invokeMethod<String>("cancelNotification", {"id": questionId});
  }

  static setAllMessageRead({OnSuccess onSuccess, OnFailure onFailure}) async {
    try {
      await messageDio.post("all");
      onSuccess();
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static Future<UserMessages> getUserMails(int page) async {
    var response = await userDio
        .get('https://api.twt.edu.cn/api/notification/history/user');
    var messages = UserMessages.fromJson(response.data);
    return messages;
  }
}

final messageDio = MessageDio();
final userDio = UserNotificationDio();


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
  String baseUrl = 'https://www.zrzz.site:7013/api/v1/f/message/';

  @override
  Map<String, String> headers = {
    'token': CommonPreferences().feedbackToken.value
  };

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

  bool get success => code == 200;

  FeedbackMessageBaseData.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['msg'];
    data = json['data'];
  }
}

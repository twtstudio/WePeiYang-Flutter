import 'dart:convert' show jsonDecode;

import 'package:flutter/foundation.dart' show compute;
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/token/lake_token_manager.dart';
import 'package:we_pei_yang_flutter/message/model/message_model.dart';

class MessageService {
  static getUnreadMessagesCount(
      {required OnResult<MessageCount> onResult,
      required OnFailure onFailure}) async {
    try {
      var response = await messageDio.get("count");
      onResult(MessageCount.fromJson(response.data['count']));
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static getLikeMessages(
      {required int page,
      required void Function(List<LikeMessage> list, int total) onSuccess,
      required OnFailure onFailure}) async {
    try {
      var response = await messageDio.get("likes", queryParameters: {
        "page_size": '20',
        "page": '$page',
      });
      List<LikeMessage> list = [];
      for (Map<String, dynamic> json in response.data['list']) {
        list.add(LikeMessage.fromJson(json));
      }
      onSuccess(list, response.data['total']);
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static getFloorMessages(
      {required page,
      required void Function(List<FloorMessage> list, int totalPage) onSuccess,
      required OnFailure onFailure}) async {
    try {
      var response = await messageDio.get("floors", queryParameters: {
        "page_size": '20',
        "page": '$page',
      });
      List<FloorMessage> list = [];
      for (Map<String, dynamic> json in response.data['list']) {
        list.add(FloorMessage.fromJson(json));
      }
      onSuccess(list, response.data['total']);
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static getReplyMessages(
      {required page,
      required void Function(List<ReplyMessage> list, int totalPage) onSuccess,
      required OnFailure onFailure}) async {
    try {
      var response = await messageDio.get("replys", queryParameters: {
        "page_size": '20',
        "page": '$page',
      });
      List<ReplyMessage> list = [];
      for (Map<String, dynamic> json in response.data['list']) {
        list.add(ReplyMessage.fromJson(json));
      }
      onSuccess(list, response.data['total']);
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static getNoticeMessages(
      {required page,
      required void Function(List<NoticeMessage> list, int totalPage) onSuccess,
      required OnFailure onFailure}) async {
    try {
      var response = await messageDio.get("notices", queryParameters: {
        "page_size": '20',
        "page": '$page',
      });
      List<NoticeMessage> list = [];
      for (Map<String, dynamic> json in response.data['list']) {
        list.add(NoticeMessage.fromJson(json));
      }
      onSuccess(list, response.data['total']);
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static setLikeMessageRead(int id, int type,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    try {
      await messageDio.post("like/read",
          formData: FormData.fromMap({"id": id, "type": type}));
      onSuccess();
    } on DioException catch (e) {
      onFailure(e);
    }

    ///涉及推送原生部分代码，随后再改
    // await pushChannel
    //     .invokeMethod<String>("cancelNotification", {"id": questionId});
  }

  static setReplyMessageRead(int id,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    try {
      await messageDio.post("reply/read",
          formData: FormData.fromMap({"id": id}));
      onSuccess();
    } on DioException catch (e) {
      onFailure(e);
    }

    ///涉及推送原生部分代码，随后再改
    // await pushChannel
    //     .invokeMethod<String>("cancelNotification", {"id": questionId});
  }

  static setFloorMessageRead(int id,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    try {
      await messageDio.post("floor/read",
          formData: FormData.fromMap({"id": id}));
      onSuccess();
    } on DioException catch (e) {
      onFailure(e);
    }

    ///涉及推送原生部分代码，随后再改
    // await pushChannel
    //     .invokeMethod<String>("cancelNotification", {"id": questionId});
  }

  static setPostFloorMessageRead(int postId,
      {OnSuccess? onSuccess, OnFailure? onFailure}) async {
    try {
      await messageDio.post("floor/read_in_post",
          formData: FormData.fromMap({"post_id": postId}));
      onSuccess?.call();
    } on DioException catch (e) {
      onFailure?.call(e);
    }
  }

  static setNoticeMessageRead(int id,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    try {
      await messageDio.post("notice/read",
          formData: FormData.fromMap({"id": id}));
      onSuccess();
    } on DioException catch (e) {
      onFailure(e);
    }

    ///涉及推送原生部分代码，随后再改
    // await pushChannel
    //     .invokeMethod<String>("cancelNotification", {"id": questionId});
  }

  static setAllMessageRead(
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    try {
      await messageDio.post("all");
      onSuccess();
    } on DioException catch (e) {
      onFailure(e);
    }
  }
}

final messageDio = MessageDio();

class MessageDio extends DioAbstract {
  @override
  String baseUrl = '${EnvConfig.QNHD}api/v1/f/message/';

  @override
  List<Interceptor> interceptors = [
    InterceptorsWrapper(onRequest: (options, handler) async {
      options.headers['token'] = await LakeTokenManager().token;
      return handler.next(options);
    }),
    ApiInterceptor()
  ];

  /// 这里不能改，因为下面手动解析的字符串
  @override
  ResponseType responseType = ResponseType.plain;
}

class ApiInterceptor extends InterceptorsWrapper {
  @override
  onResponse(response, handler) async {
    final String data = response.data.toString();
    final bool isCompute = data.length > 10 * 1024;
    final Map<String, dynamic> _map =
        isCompute ? await compute(parseData, data) : parseData(data);
    FeedbackMessageBaseData respData = FeedbackMessageBaseData.fromJson(_map);
    if (respData.success) {
      response.data = respData.data;
      return handler.resolve(response);
    } else {
      return handler.reject(WpyDioException(error: respData.message), true);
    }
  }
}

Map<String, dynamic> parseData(String data) {
  return jsonDecode(data);
}

class FeedbackMessageBaseData {
  int code;
  String message;
  dynamic data;

  bool get success => code == 200;

  FeedbackMessageBaseData.fromJson(Map<String, dynamic> json)
      : this.code = json['code'],
        this.message = json['msg'],
        this.data = json['data'];
}

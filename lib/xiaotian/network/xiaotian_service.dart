import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'dart:math';
import '../../commons/network/wpy_dio.dart';
import '../model/xiaotian_model.dart';

class AIRequestException implements Exception {
  final String message;

  AIRequestException(this.message);

  @override
  String toString() => "AI request error: $message";
}

class aiTianDio extends DioAbstract {
  @override
  String get baseUrl => "https://student.tju.edu.cn/ai";

  @override
  List<Interceptor> interceptors = [
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers.addAll({
          "Authorization": CommonPreferences.token.value,
        });
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (response.statusCode != 200) {
          throw AIRequestException(response.data);
        }
        handler.next(response);
      },
    )
  ];
}
//热门话题
class HotTopic {
  final String topic;
  final String tag;
  final int count;
  final String summary;
  final String type;

  HotTopic({
    required this.topic,
    required this.tag,
    required this.count,
    required this.summary,
    required this.type,
  });

  factory HotTopic.fromJson(Map<String, dynamic> json) {
    return HotTopic(
      topic: json['topic'] ?? '',
      tag: json['tag'] ?? '',
      count: json['count'] ?? 0,
      summary: json['summary'] ?? '',
      type: json['type'] ?? '',
    );
  }
}

/// API 单例
class AiService {

  static final AiTianDio = aiTianDio();

  Stream<ChatEvent> streamChat({
    required String prompt,
    required String sessionId,
    String? searchTime,
    String? searchType,
    Map<String, String>? headers,
  }) {
    final streamController = StreamController<ChatEvent>();

    final params = {
      'prompt': prompt,
      'session_id': sessionId,
      'user_id': CommonPreferences.userNumber.value,
      'student_info': jsonEncode({
        'studentNumber': CommonPreferences.userNumber.value,
        'deptName': CommonPreferences.department.value,
        'specialty': CommonPreferences.major.value,
        'education':CommonPreferences.stuType.value,
      }),
      'search_time': searchTime ?? 'noLimit',
      'search_type': searchType ?? 'no',
    };

    final url = Uri.https('student.tju.edu.cn', '/ai-rag/api/chat/stream');
    var request = http.Request("POST", url)
      ..bodyFields = params
      ..headers.addAll({
        "Authorization": CommonPreferences.token.value,       //获取账号token
        "Accept": "text/event-stream",
        'Content-Type': 'application/x-www-form-urlencoded',
        ...?headers,
      });

    http.Client().send(request).then((response) {
      final stream = response.stream.transform(utf8.decoder);
      bool firstDataEventYielded = false;

      stream.listen(
            (data) {
          final dataLines = data.split("\n").where((element) => element.trim().isNotEmpty).toList();
          for (String line in dataLines) {
            line = line.trim();
            if (line.startsWith('event:')) continue;
            if (!line.startsWith('data:')) continue;

            final payload = line.substring(5).trimLeft();
            if (payload.isEmpty || payload == '[DONE]') continue;

            try {
              final map = jsonDecode(payload);
              if (!firstDataEventYielded && map.keys.any((k) => ['token', 'sources', 'question', 'trace_id', 'error'].contains(k))) {
                firstDataEventYielded = true;
              }

              if (map['token'] != null) streamController.add(ChatEvent.token(map['token']));
              if (map['question'] != null) streamController.add(ChatEvent.followup(map['question']));
              if (map['sources'] != null) {
                final list = (map['sources'] as List).map((e) => Source.fromJson(e as Map<String, dynamic>)).toList();
                streamController.add(ChatEvent.source(list));
              }
              if (map['trace_id'] != null) streamController.add(ChatEvent.traceId(map['trace_id'].toString()));
              if (map['error'] != null) streamController.add(ChatEvent.error(map['error'].toString()));
            } catch (e) {
              // Ignore json parsing errors for incomplete data chunks
            }
          }
        },
        onDone: () {
          if (!streamController.isClosed) streamController.close();
        },
        onError: (e, st) {
          if (!streamController.isClosed) {
            streamController.add(ChatEvent.error('Stream failed: $e'));
            streamController.close();
          }
        },
        cancelOnError: true,
      );
    }).catchError((e, st) {
      if (!streamController.isClosed) {
        streamController.add(ChatEvent.error('Failed to send request: $e'));
        streamController.close();
      }
    });

    return streamController.stream;
  }


  /* 历史会话列表 */
  Future<List<HistorySession>> getAllSessions(String userId) async {
    final rs = await AiTianDio.get('/ai-api/ai/get_all_sessions/$userId');
    final list = (jsonDecode(rs.data['msg']) as List)
        .map((e) => HistorySession.fromJson(e))
        .toList();
    return list;
  }

  /* 历史会话详情 */
  Future<List<HistoryChatMessage>> getConversation({
    required String sessionId,
    required String userId,
  }) async {
    final rs = await AiTianDio.get(
      '/ai-api/ai/get_conversation',
      queryParameters: {'sessionId': sessionId, 'userId': userId},
    );
    final list = (jsonDecode(rs.data['msg']) as List)
        .map((e) => HistoryChatMessage.fromJson(e))
        .toList();
    return list;
  }

  /*热门话题推荐*/
  Future<List<HotTopic>> getHotTopics({String timeRange = 'month'}) async {
    try {
      final requestBody = {
        "time_range": timeRange,
      };

      final response = await AiTianDio.post(
        '-rag/api/analysis/hot_topics',
        data: requestBody,
      );

      if (response.data['status'] == 'success' && response.data['data'] is List) {

        final List<dynamic> topicListJson = response.data['data'];

        List<HotTopic> topics = topicListJson
            .map((jsonItem) => HotTopic.fromJson(jsonItem as Map<String, dynamic>))
            .toList();

        return topics;
      } else {
        print('获取热榜业务失败或数据格式不正确: ${response.data}');
        return [];
      }
    } on DioException catch (e) {
      print("获取热榜请求失败: ${e.response?.data ?? e.message}");
      return []; // 请求失败时，返回一个空列表
    } catch (e) {
      // 捕获其他可能的异常，比如数据解析错误
      print('获取热榜时发生未知错误: $e');
      return []; // 同样返回空列表
    }
  }

  //发送意见反馈
  Future<Response> updateLikeStatus({
    required String traceId,
    required String likeCount,  // "0"=无操作, "1"=赞, "2"=踩
    String? state,              // "1"=有害, "2"=不准确, "3"=没帮助, "4"=其他
    String? feedbackInformation,
  }) async {
    try {
      final data = {
        "traceId": traceId,
        "likeCount": likeCount,
        if (state != null) "state": state,
        if (feedbackInformation != null) "feedbackInformation": feedbackInformation,
      };

      final response = await AiTianDio.post(
        "/ai-api/questionRecords/exportByTraceId",
        data: data,
      );
      return response;
    } on DioException catch (e) {
      print("请求失败: ${e.response?.data ?? e.message}");
      rethrow;
    }
  }
}

//创建会话id
String getSessionId() {
  final ts = DateTime.now().millisecondsSinceEpoch;
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final rand = List.generate(12, (_) => chars[Random().nextInt(chars.length)]).join();
  return '$ts-$rand';
}
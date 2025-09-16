import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'dart:math';
import 'xiaotian_model.dart';


const XIAOTIAN_URL = 'https://student.tju.edu.cn/ai';

/// API 单例
class AiTjuApi {
  AiTjuApi._();
  static final _instance = AiTjuApi._();
  factory AiTjuApi() => _instance;


  final Dio dio = Dio(
    BaseOptions(
      baseUrl: XIAOTIAN_URL,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 120),
    ),
  );

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
      'user_id': CommonPreferences.userNumber.value,        //获取账号学号
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


  /// Cho phép cập nhật header mặc định (Cookie/Authorization...) nếu muốn
  // void updateDefaultHeaders(Map<String, String> headers) {
  //   dio.options.headers.addAll(headers);
  // }
  //
  // Stream<ChatEvent> streamChat({
  //   required String prompt,
  //   required String sessionId,
  //   required String userId,
  //   List<String>? files,
  //   String? searchTime,
  //   String? searchType,
  //   Map<String, String>? headers, // header
  // }) async* {
  //   // 1. 创建并启动计时器
  //   final stopwatch = Stopwatch()..start();
  //   bool firstLineReceived = false;
  //   bool firstDataEventYielded = false;
  //
  //   print(" T0: [${stopwatch.elapsedMilliseconds}ms] 开始执行 streamChat 方法...");
  //
  //   final params = <String, dynamic>{
  //     'prompt': prompt,
  //     'sessionId': sessionId,
  //     'userId': userId,
  //     if (files != null) 'files': files,
  //     if (searchTime != null) 'searchTime': searchTime,
  //     if (searchType != null) 'searchType': searchType,
  //   };
  //
  //   try {
  //     final rs = await dio.get(
  //       '/ai-api/ai/stream',
  //       queryParameters: params,
  //       options: Options(
  //         responseType: ResponseType.stream,
  //         headers: {
  //           'Accept': 'text/event-stream',
  //           ...?headers,
  //         },
  //       ),
  //     );
  //
  //
  //     final lines = rs.data.stream
  //         .cast<List<int>>()
  //         .transform(utf8.decoder)
  //         .transform(const LineSplitter());
  //
  //     await for (final line in lines) {
  //       // 3. 记录收到第一行数据的时间点
  //       if (!firstLineReceived) {
  //         firstLineReceived = true;
  //       }
  //
  //       if (!line.startsWith('data:')) {
  //         continue;
  //       }
  //
  //       final payload = line.substring(5).trimLeft();
  //       if (payload.isEmpty) continue;
  //       if (payload == '[DONE]') break;
  //
  //       try {
  //         final map = jsonDecode(payload);
  //
  //         // 4. 记录解析并准备推送第一个有效事件的时间点
  //         if (!firstDataEventYielded) {
  //           // 确保这是一个有内容的事件，而不是空的 keep-alive 包
  //           if (map.keys.any((k) => ['token', 'sources', 'question', 'trace_id', 'error'].contains(k))) {
  //             firstDataEventYielded = true;
  //           }
  //         }
  //
  //         // --- 原有逻辑 ---
  //         if (map['token'] != null) yield ChatEvent.token(map['token']);
  //         if (map['sources'] != null) {
  //           final list = (map['sources'] as List)
  //               .map((e) => Source.fromJson(e as Map<String, dynamic>))
  //               .toList();
  //           yield ChatEvent.source(list);
  //         }
  //         if (map['question'] != null) {
  //           yield ChatEvent.followup(map['question'].toString());
  //         }
  //         if (map['trace_id'] != null) {
  //           yield ChatEvent.traceId(map['trace_id'].toString());
  //         }
  //         if (map['error'] != null) {
  //           yield ChatEvent.error(map['error'].toString());
  //         }
  //       } catch (e, st) {
  //         // print("解析失败: $e\n$st");
  //       }
  //     }
  //   } on DioException catch(e) {
  //     print("Dio Error at [${stopwatch.elapsedMilliseconds}ms]: $e");
  //     // 重新抛出异常，让上层能捕获
  //     rethrow;
  //   } finally {
  //     stopwatch.stop();
  //     print(" T_End: [${stopwatch.elapsedMilliseconds}ms] streamChat 方法执行完毕。");
  //   }
  // }


  /// ============== 1b. Fetch full Answer 链接token==============
  /// Return fullText (token) + rawSse (所有 SSE ）
  Future<({String fullText, String rawSse})> fetchFullAnswer({
    required String prompt,
    required String sessionId,
    required String userId,
    List<String>? files,
    String? searchTime,
    String? searchType,
    Map<String, String>? headers,
  }) async {
    final params = <String, dynamic>{
      'prompt': prompt,
      'sessionId': sessionId,
      'userId': userId,
      if (files != null) 'files': files,
      if (searchTime != null) 'searchTime': searchTime,
      if (searchType != null) 'searchType': searchType,
    };

    final rs = await dio.get(
      '/ai-api/ai/stream',
      queryParameters: params,
      options: Options(
        responseType: ResponseType.stream,
        headers: headers,
      ),
    );

    final stringStream = utf8.decoder.bind(rs.data.stream.cast<List<int>>());
    final lines = const LineSplitter().bind(stringStream);

    final full = StringBuffer();
    final raw = StringBuffer();
    final eventData = StringBuffer();

    await for (final line in lines) {
      raw.writeln(line);

      if (line.isEmpty) {
        final dataStr = eventData.toString();
        eventData.clear();
        if (dataStr.isEmpty) continue;
        if (dataStr == '[DONE]') break;
        try {
          final map = jsonDecode(dataStr);
          final token = map['token'];
          if (token is String) full.write(token);
        } catch (_) {}
        continue;
      }

      if (line.startsWith('data:')) {
        final payload = line.length >= 5 ? line.substring(5).trimLeft() : '';
        if (payload.isNotEmpty) {
          if (eventData.isNotEmpty) eventData.write('\n');
          eventData.write(payload);
        }
      }
    }

    return (fullText: full.toString(), rawSse: raw.toString());
  }

  /* 历史会话列表 */
  Future<List<HistorySession>> getAllSessions(String userId) async {
    final rs = await dio.get('/ai-api/ai/get_all_sessions/$userId');
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
    final rs = await dio.get(
      '/ai-api/ai/get_conversation',
      queryParameters: {'sessionId': sessionId, 'userId': userId},
    );
    final list = (jsonDecode(rs.data['msg']) as List)
        .map((e) => HistoryChatMessage.fromJson(e))
        .toList();
    return list;
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

      final response = await dio.post(
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

String getSessionId() {
  final ts = DateTime.now().millisecondsSinceEpoch;
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final rand = List.generate(12, (_) => chars[Random().nextInt(chars.length)]).join();
  return '$ts-$rand';
}
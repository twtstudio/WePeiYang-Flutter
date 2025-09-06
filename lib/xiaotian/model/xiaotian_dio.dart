import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
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

  // 2. 添加 LogInterceptor 拦截器
  void setupDio() {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,  // 是否打印请求头
        requestBody: true,    // 是否打印请求体
        responseHeader: true, // 是否打印响应头
        responseBody: true,   // 是否打印响应体
        error: true,          // 是否打印错误信息
        logPrint: (obj) => print(obj.toString()), // 使用 print 函数来输出日志
      ),
    );
  }

  /// Cho phép cập nhật header mặc định (Cookie/Authorization...) nếu muốn
  void updateDefaultHeaders(Map<String, String> headers) {
    dio.options.headers.addAll(headers);
  }

  /*  SSE 流式对话 */
  Stream<ChatEvent> streamChat({
    required String prompt,
    required String sessionId,
    required String userId,
    List<String>? files,
    String? searchTime,
    String? searchType,
    Map<String, String>? headers, // header
  }) async* {
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
        headers: {
          'Accept': 'text/event-stream',
          ...?headers,
        },
      ),
    );

    // stream bytes -> utf8 ->  SSE
    final lines = rs.data.stream
        .cast<List<int>>() // Stream<Uint8List> -> Stream<List<int>>
        .transform(utf8.decoder) // -> Stream<String>
        .transform(const LineSplitter()); // -> Stream<String> each lines

    final eventData = StringBuffer();

    await for (final line in lines) {
      print("原始行: $line");
      if (line.isEmpty) {
        final dataStr = eventData.toString();
        eventData.clear();
        if (dataStr.isEmpty) continue;
        print("完整块: $dataStr");
        if (dataStr == '[DONE]') break;
        try {
          final map = jsonDecode(dataStr);
          print("解析后的 JSON: $map");
          if (map['token'] != null) yield ChatEvent.token(map['token']);
          if (map['sources'] != null) {
            final list = (map['sources'] as List)
                .map((e) => Source.fromJson(e as Map<String, dynamic>))
                .toList();
            yield ChatEvent.source(list);
          }
          if (map['question'] != null) {
            yield ChatEvent.followup(map['question'].toString());
          }
          if (map['trace_id'] != null) {
            yield ChatEvent.traceId(map['trace_id'].toString());
          }
          if (map['error'] != null) {
            yield ChatEvent.error(map['error'].toString());
          }
        } catch (e, st) {
          print("解析失败: $e\n$st");
        }
        continue;
      }

      if (line.startsWith('data:')) {
        final payload = line.length >= 5 ? line.substring(5).trimLeft() : '';
        if (payload.isNotEmpty) {
          if (eventData.isNotEmpty) eventData.write('\n');
          eventData.write(payload);
        }
      } else {
        print('不是data: $line');
      }
    }
  }

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
}

String getSessionId() {
  final ts = DateTime.now().millisecondsSinceEpoch;
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final rand = List.generate(12, (_) => chars[Random().nextInt(chars.length)]).join();
  return '$ts-$rand';
}
import 'dart:io';
import 'package:dio/dio.dart';
import 'aliyun_isi_protocol.dart';

class AliyunIsiClient {
  final String appKey;
  final Dio _dio;

  // RESTful API 基础地址 (上海 Region)
  static const String _baseUrl = "http://nls-gateway.cn-shanghai.aliyuncs.com/stream/v1/asr";

  AliyunIsiClient({
    required this.appKey,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  /// 上传音频文件进行识别
  Future<AliyunAsrResponse> recognizeAudio({
    required String token,
    required String filePath,
    int sampleRate = 16000,
    AudioFormat format = AudioFormat.wav,
    bool enablePunctuation = true,
  }) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception("Audio file not found at $filePath");
    }

    // 读取音频二进制数据
    final audioBytes = await file.readAsBytes();

    // 构造 Query 参数
    final queryParameters = {
      'appkey': appKey,
      'format': format.value,
      'sample_rate': sampleRate,
      'enable_punctuation_prediction': enablePunctuation,
      'enable_inverse_text_normalization': true,
      'enable_voice_detection': false,
    };

    try {
      final response = await _dio.post(
        _baseUrl,
        queryParameters: queryParameters,
        options: Options(
          headers: {
            'X-NLS-Token': token,
            'Content-Type': 'application/octet-stream',
          },
          // 确保 Dio 不会因为 4xx/5xx 抛出异常，让我们自己处理
          validateStatus: (status) => true,
        ),
        data: Stream.fromIterable(audioBytes.map((e) => [e])), // 流式上传
      );

      // 处理 API 返回
      if (response.data is Map<String, dynamic>) {
        return AliyunAsrResponse.fromJson(response.data);
      } else {
        return AliyunAsrResponse(
          status: response.statusCode,
          message: "Unknown response format: ${response.data}",
        );
      }
    } catch (e) {
      return AliyunAsrResponse(
        status: -1,
        message: "Network Error: $e",
      );
    }
  }
}
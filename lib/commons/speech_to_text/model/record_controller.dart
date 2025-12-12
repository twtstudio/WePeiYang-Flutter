import 'dart:async';
import 'package:flutter/foundation.dart';
import '../API/aliyun_isi_client.dart';
import '../API/aliyun_token_client.dart';
import 'speech_record_manager.dart';

enum RecordState {
  idle,
  recording,
  processing,
  success,
  error,
}

class RecordController extends ChangeNotifier {
  final AliyunTokenClient _tokenClient;
  final AliyunIsiClient _isiClient;
  final SpeechRecordManager _recordManager;

  RecordState _state = RecordState.idle;
  String _resultText = "";
  // 新增：如果需要把错误信息传给 UI 用于 Toast，可以用这个变量
  String _errorMessage = "";

  RecordController({
    required String accessKeyId,
    required String accessKeySecret,
    required String appKey,
  })  : _tokenClient = AliyunTokenClient(
    accessKeyId: accessKeyId,
    accessKeySecret: accessKeySecret,
  ),
        _isiClient = AliyunIsiClient(appKey: appKey),
        _recordManager = SpeechRecordManager();

  // Getters for UI
  RecordState get state => _state;
  String get resultText => _resultText;
  String get errorMessage => _errorMessage;
  bool get isRecording => _state == RecordState.recording;

  /// 初始化资源
  Future<void> init() async {
    await _recordManager.init();
  }

  @override
  void dispose() {
    _recordManager.dispose();
    super.dispose();
  }

  /// 切换录音状态：如果正在录音，则停止并识别；否则，开始录音。
  Future<void> toggleRecording() async {
    if (_state == RecordState.recording) {
      await _stopAndRecognize();
    } else if (_state == RecordState.idle || _state == RecordState.success || _state == RecordState.error) {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      // 1. 开始录音时，清空上一次的结果
      _resultText = "";
      _errorMessage = "";

// 不要设置 _resultText = "[正在启动...]"，仅更新状态
      _updateState(RecordState.processing);

      final token = await _tokenClient.getToken();
      if (token == null) {
        _errorMessage = "[Token 获取失败]";
        _updateState(RecordState.error);
        return;
      }

      await _recordManager.startRecording();
      // _resultText = "[正在录音... 点击按钮停止]";
      _updateState(RecordState.recording);
    } catch (e) {
      _errorMessage = "启动异常: $e";
      _updateState(RecordState.error);
    }
  }

  Future<void> _stopAndRecognize() async {
    try {
      final path = await _recordManager.stopRecording();

      // 捕获 '录音文件生成失败' 的异常
      if (path == null) {
        throw Exception("录音文件生成失败 (路径无效或文件未写入)");
      }

      // _resultText = "[正在识别...]";
      _updateState(RecordState.processing);

      final token = await _tokenClient.getToken();
      if (token == null) throw Exception("Token 失效");

      final response = await _isiClient.recognizeAudio(token: token, filePath: path);

      if (response.isSuccess) {
        _resultText = response.result ?? "";
        _updateState(RecordState.success);
      } else {
        _errorMessage = "识别失败: ${response.message}";
        _updateState(RecordState.error);
      }
    } catch (e) {
      _errorMessage = "处理异常: $e";
      _updateState(RecordState.error);
    }
  }

  void _updateState(RecordState newState) {
    _state = newState;
    notifyListeners();
  }

}
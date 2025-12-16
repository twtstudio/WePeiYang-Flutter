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
  // 如果需要把错误信息传给 UI 用于 Toast，可以用这个变量
  String _errorMessage = "";
  // 定时器和最大录音时间
  Timer? _maxDurationTimer;
  static const Duration _maxRecordDuration = Duration(seconds: 58);

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


  @override
  void dispose() {
    _maxDurationTimer?.cancel();
    _recordManager.dispose();
    super.dispose();
  }

  /// 切换录音状态：如果正在录音，则停止并识别；否则，开始录音。
  Future<void> toggleRecording() async {
    if (_state == RecordState.recording) {
      // 在手动停止时，先取消定时器，再执行停止逻辑
      _maxDurationTimer?.cancel();
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

      //仅更新状态
      _updateState(RecordState.processing);
      final hasPermission = await _recordManager.ensurePermission();
      if (!hasPermission) {
        // 如果用户拒绝，设置错误信息并返回
        _errorMessage = "请授予麦克风权限以使用语音输入";
        _updateState(RecordState.error);
        return;
      }

      final token = await _tokenClient.getToken();
      if (token == null) {
        _errorMessage = "[Token 获取失败]";
        _updateState(RecordState.error);
        return;
      }

      await _recordManager.startRecording();

      _updateState(RecordState.recording);
      //启动 60 秒定时器
      _maxDurationTimer = Timer(_maxRecordDuration, () {
        //定时器触发，检查是否仍在录音，并强制停止
        if (_state == RecordState.recording) {
          debugPrint('60秒录音时间到，自动停止。');
          // 注意：这里调用 toggleRecording 会执行 _maxDurationTimer?.cancel()
          // 故不需要在此处重复 cancel
          toggleRecording();
          // 设置一个特定的错误信息，供 UI 弹出 Toast 提示用户
          _errorMessage = '录音时间已达上限（60秒），已自动停止。';
        }
        _maxDurationTimer?.cancel(); // 确保定时器被清理
      });
    } catch (e) {
      _maxDurationTimer?.cancel(); // 失败也要取消定时器
      _errorMessage = "启动异常: $e";
      _updateState(RecordState.error);

    }
  }

  Future<void> _stopAndRecognize() async {
    // 确保在停止处理前，取消任何可能正在运行的定时器
    _maxDurationTimer?.cancel();
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
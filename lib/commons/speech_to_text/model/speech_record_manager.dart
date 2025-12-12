import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechRecordManager {
  final Record _recorder = Record();

  String? _currentRecordingPath;

  /// 初始化录音机
  Future<void> init() async {
    // 权限检查和请求
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Microphone permission not granted');
    }

    // 检查是否有录音权限（record 库自带的方法）
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission not granted (Record internal check failed)');
    }
  }

  /// 资源释放 (record 库中是 dispose)
  Future<void> dispose() async {
    // 释放资源，防止内存泄漏
    // record^4.4.4 版本中，dispose 是 Future<void>
    await _recorder.dispose();
  }

  /// 开始录音
  /// 返回录音文件的临时路径
  Future<String> startRecording() async {
    // 确保权限已授予
    if (!await _recorder.hasPermission()) {
      await init();
    }

    // 停止之前的录音（以防万一）
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }

    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/temp_record.wav';
    _currentRecordingPath = path;

    // 启动录音
    await _recorder.start(
      path: path,
      // 使用 pcm16bits 编码，以匹配 WAV 格式（在指定了 .wav 路径时通常可以生成 WAV 容器）
      encoder: AudioEncoder.pcm16bit,
      samplingRate: 16000,
      numChannels: 1,
    );

    return path;
  }

  /// 停止录音
  /// 返回录音文件的完整路径
  Future<String?> stopRecording() async {
    // 停止录音，并返回文件路径
    final path = await _recorder.stop();

    // record 库的 stop() 方法会返回录制的文件路径（或 null）
    if (path != null && await File(path).exists()) {
      final resultPath = path;
      _currentRecordingPath = null;
      return resultPath;
    }

    _currentRecordingPath = null;
    return null;
  }

  /// 获取当前录音状态
  Future<bool> Function() get isRecording => _recorder.isRecording;

  /// 暴露一个检查录音状态的异步方法 (可选)
  Future<bool> isRecordingAsync() => _recorder.isRecording();
}
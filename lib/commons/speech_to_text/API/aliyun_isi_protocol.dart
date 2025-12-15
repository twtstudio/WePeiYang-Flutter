/// 阿里云一句话识别的响应体
class AliyunAsrResponse {
  final String? taskId;
  final int? status;
  final String? message;
  final String? result;

  AliyunAsrResponse({
    this.taskId,
    this.status,
    this.message,
    this.result,
  });

  factory AliyunAsrResponse.fromJson(Map<String, dynamic> json) {
    return AliyunAsrResponse(
      taskId: json['task_id'],
      status: json['status'],
      message: json['message'],
      result: json['result'],
    );
  }

  bool get isSuccess => status == 20000000;

  @override
  String toString() {
    return 'Status: $status, Result: $result, Msg: $message';
  }
}

class aliyunInfo{
  static const accessKeyId = "LTAI5tRMxDtuW"+"3oVG8VXAooD";
  static const accessKeySecret = "3cDr1j9uQwkWf1d"+"7KIUbS4Q72zIRXG";
  static const appKey= "OEcw3CQ"+"Av1uM8QAJ";
}

/// 音频编码格式
enum AudioFormat {
  pcm,
  wav,
  opus,
  amr,
}

extension AudioFormatExt on AudioFormat {
  String get value => toString().split('.').last;
}
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
  static const accessKeyId = "LTAI5tGc3G6"+"r4EEkbrhAXL1k";
  static const accessKeySecret = "8BAV7BVqky"+"KDKzWBPA4W4Lkd8Ivk4k";
  static const appKey= "UrF8OYA"+"AvLMNW0oq";
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
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// 阿里云 AccessToken 生成 SDK
class AliyunTokenClient {
  final String accessKeyId;
  final String accessKeySecret;
  final String regionId;
  final bool useHttps;

  late final Dio _dio;
  late final String _endpoint;

  // 缓存 Token，避免每次都请求
  String? _cachedToken;
  int? _expireTimestamp; // 服务器返回的过期时间戳(秒)

  AliyunTokenClient({
    required this.accessKeyId,
    required this.accessKeySecret,
    this.regionId = "cn-shanghai",
    this.useHttps = true,
    Dio? dio,
  }) {
    _dio = dio ?? Dio();
    _endpoint = useHttps
        ? 'https://nls-meta.$regionId.aliyuncs.com/'
        : 'http://nls-meta.$regionId.aliyuncs.com/';
  }

  // -----------------------------
  // 工具函数
  // -----------------------------

  String _percentEncode(String value) {
    return Uri.encodeComponent(value)
        .replaceAll('+', '%20')
        .replaceAll('*', '%2A')
        .replaceAll('%7E', '~');
  }

  String _timestamp() {
    final now = DateTime.now().toUtc();
    return now.toIso8601String().split('.').first + 'Z';
  }

  String _nonce() {
    return const Uuid().v4();
  }

  String _canonicalQueryString(Map<String, String> params) {
    final keys = params.keys.toList()..sort();
    return keys
        .map((key) => '${_percentEncode(key)}=${_percentEncode(params[key]!)}')
        .join('&');
  }

  String _stringToSign(String method, String canonicalQS) {
    return '$method&${_percentEncode("/")}&${_percentEncode(canonicalQS)}';
  }

  String _sign(String stringToSign) {
    final key = utf8.encode('$accessKeySecret&');
    final data = utf8.encode(stringToSign);
    final hmacSha1 = Hmac(sha1, key);
    final digest = hmacSha1.convert(data);
    return _percentEncode(base64.encode(digest.bytes));
  }

  // 获取 Token 的主函数
  Future<String?> getToken() async {
    // 1. 检查缓存是否有效
    if (_isTokenValid()) {
      // print("使用本地缓存 Token");
      return _cachedToken;
    }
    const method = "GET";

    // 1. 参数
    final params = <String, String>{
      'AccessKeyId': accessKeyId,
      'Action': 'CreateToken',
      'Version': '2019-02-28',
      'Format': 'JSON',
      'RegionId': regionId,
      'SignatureMethod': 'HMAC-SHA1',
      'SignatureVersion': '1.0',
      'SignatureNonce': _nonce(),
      'Timestamp': _timestamp(),
    };

    // 2. 规范化参数
    final canonicalQS = _canonicalQueryString(params);

    // 3. 构造签名
    final stringToSign = _stringToSign(method, canonicalQS);
    final signature = _sign(stringToSign);

    // 4. 最终 query string
    final finalQS = 'Signature=$signature&$canonicalQS';

    final url = '$_endpoint?$finalQS';

    try {
      final response = await _dio.get(url);

      final data = response.data;

      if (data is Map && data["Token"] != null) {
        final tokenData = data["Token"];
        // 保存 Token ID
        _cachedToken = tokenData["Id"];
        // 保存过期时间 (文档说明 ExpireTime 是 Unix 时间戳，单位秒)
        if (tokenData["ExpireTime"] != null) {
          _expireTimestamp = tokenData["ExpireTime"];
        }

        return _cachedToken;
      }
      print("token获取失败：$data");
      return null;
    } catch (e) {
      print("token请求失败：$e");
      return null;
    }
  }

  /// 检查 Token 是否有效
  bool _isTokenValid() {
    if (_cachedToken == null || _expireTimestamp == null) return false;

    final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // 设置一个安全缓冲期，比如提前 60 秒认为过期，防止网络延迟导致刚好过期
    const int bufferSeconds = 60;

    return currentTimestamp < (_expireTimestamp! - bufferSeconds);
  }

}


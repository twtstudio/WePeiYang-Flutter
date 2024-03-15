import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui show instantiateImageCodec, Codec;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Image.network方法显示HTTPS图片时忽略证书
@Deprecated('暂时用不上')
class NetworkImageSSL extends ImageProvider<NetworkImageSSL> {
  const NetworkImageSSL(this.url, {this.scale = 1.0, this.headers});

  final String url;

  final double scale;

  final Map<String, String>? headers;

  @override
  Future<NetworkImageSSL> obtainKey(ImageConfiguration configuration) {
    return new SynchronousFuture<NetworkImageSSL>(this);
  }

  // @override
  // ImageStreamCompleter load(NetworkImageSSL key, DecoderCallback decode) {
  //   return MultiFrameImageStreamCompleter(
  //       codec: _loadAsync(key), scale: key.scale);
  // }

  static final HttpClient _httpClient = new HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);

  Future<ui.Codec> _loadAsync(NetworkImageSSL key) async {
    assert(key == this);

    final Uri resolved = Uri.base.resolve(key.url);
    final HttpClientRequest request = await _httpClient.getUrl(resolved);
    headers?.forEach((String name, String value) {
      request.headers.add(name, value);
    });
    final HttpClientResponse response = await request.close();
    if (response.statusCode != HttpStatus.ok)
      throw new Exception('HTTP请求失败，状态码: ${response.statusCode}, $resolved');

    final Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    if (bytes.lengthInBytes == 0)
      throw new Exception('NetworkImageSSL是一个空文件: $resolved');

    return await ui.instantiateImageCodec(bytes);
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final NetworkImageSSL typedOther = other;
    return url == typedOther.url && scale == typedOther.scale;
  }

  @override
  int get hashCode => hashValues(url, scale);

  @override
  String toString() => '$runtimeType("$url", scale: $scale)';
}

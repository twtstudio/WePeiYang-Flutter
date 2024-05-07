import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:pointycastle/export.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:xml/xml.dart';

class DesService {
  static Uint8List padPKCS7(Uint8List src, int blockSize) {
    final padLength = blockSize - (src.length % blockSize);
    final padded = Uint8List(src.length + padLength)
      ..setRange(0, src.length, src);
    padded.fillRange(src.length, padded.length, padLength);
    return padded;
  }

  static String desEncode(String plainText, String keyString, String ivString) {
    final keyBytes = utf8.encode(keyString);
    final ivBytes = utf8.encode(ivString);

    final key = Uint8List.fromList(keyBytes);
    final iv = Uint8List.fromList(ivBytes);

    final cipher = CBCBlockCipher(DESedeEngine())
      ..init(true, ParametersWithIV(KeyParameter(key), iv));

    final paddedText =
        padPKCS7(Uint8List.fromList(utf8.encode(plainText)), cipher.blockSize);
    final encryptedBytes = _processBlocks(cipher, paddedText);
    return hex.encode(encryptedBytes).toUpperCase();
  }

  static Uint8List _processBlocks(BlockCipher cipher, Uint8List input) {
    final output = Uint8List(input.length);
    for (int offset = 0; offset < input.length; offset += cipher.blockSize) {
      cipher.processBlock(input, offset, output, offset);
    }
    return output;
  }
}

class EncryptedPathInterceptor extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers["User-Agent"] =
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3";
    final source_string = "method=${options.path}"
        "&${options.queryParameters.entries.map((e) => "${e.key}=${e.value}").join("&")}";

    options.path = getEncryptedString(source_string);
    options.queryParameters = {};
    print("encrypted_path: ${options.path}");
    return handler.next(options);
  }

  String getEncryptedString(String source) {
    return DesService.desEncode(source, "neusofteducationplatform", "01234567");
  }
}

class XMLSerializerInterceptor extends InterceptorsWrapper {
  Map<String, dynamic> parseXml(XmlElement element) {
    final map = <String, dynamic>{};
    for (var child in element.children) {
      if (child is XmlElement) {
        if (child.children.isEmpty ||
            child.children.every((c) => c is XmlText && c.value.isEmpty)) {
          map[child.name.local] = '';
        } else if (child.children.length == 1 &&
            child.children.single is XmlText) {
          map[child.name.local] = child.children.single.value;
        } else {
          map[child.name.local] = parseXml(child);
        }
      }
    }
    return map;
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;
    if (data is String) {
      final xml = XmlDocument.parse(data);
      response.data = parseXml(xml.rootElement);
    }
    return handler.next(response);
  }
}

class CasDio extends DioAbstract {
  @override
  String get baseUrl => "https://f.tju.edu.cn/tp_up/up/mobile/ifs/";

  @override
  List<Interceptor> get interceptors => [
        EncryptedPathInterceptor(),
        XMLSerializerInterceptor(),
      ];
}

final casDio = CasDio();

class CasService {
  static Future<String> getQRContent(String sid) async {
    final response = await casDio.get(
      "getAccountQRcodeInfo",
      queryParameters: {"ID_NUMBER": sid},
    );
    return response.data["message"];
  }
}

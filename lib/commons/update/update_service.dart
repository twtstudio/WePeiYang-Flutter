import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/update/update.dart';

class UpdateDio extends DioAbstract {
  @override
  ResponseType responseType = ResponseType.plain;
}

final _dio = UpdateDio();

class UpdateService {
  static void checkUpdate(
      {OnResult onResult, OnSuccess onSuccess, OnFailure onFailure}) async {
    try {
      var response = await _dio
          .get('https://mobile-api.twt.edu.cn/api/app/latest-version/2');
      var version = await UpdateManager.parseJson(response.data.toString());
      if (version == null && onSuccess != null) onSuccess();
      if (version != null && onResult != null) onResult(version);
    } on DioError catch (e) {
      if (onFailure != null) onFailure(e);
    }
  }

  static Future<Response> downloadApk(String urlPath, String savePath,
          {ProgressCallback onReceiveProgress}) =>
      _dio.download(urlPath, savePath,
          onReceiveProgress: onReceiveProgress,
          options: Options(sendTimeout: 25000, receiveTimeout: 300000));
}
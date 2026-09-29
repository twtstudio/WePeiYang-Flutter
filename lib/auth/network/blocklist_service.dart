import '../../commons/environment/config.dart';
import '../../commons/network/wpy_dio.dart';
import '../../commons/token/lake_token_manager.dart';

class BlockListDio extends DioAbstract {
  @override
  String baseUrl = '${EnvConfig.QNHD}api/v1/f/blocklist';

  @override
  List<Interceptor> interceptors = [
    InterceptorsWrapper(onRequest: (options, handler) async {
      options.headers['token'] = (await LakeTokenManager().token);
      return handler.next(options);
    }, onResponse: (response, handler) {
      var code = response.data['code'] ?? 0;
      switch (code) {
        case 200: // 成功
          return handler.next(response);
        default: // 其他错误
          return handler.reject(
              WpyDioException(error: response.data['msg']), true);
      }
    })
  ];
}

final blockListDio = BlockListDio();

class BlockListService {

  //TODO:还需要修改
  //获取屏蔽用户人员名单
  static Future<List<String>> getBlockList({
    required OnFailure onFailure,
}) async {
    try {
      List<String> list = [];
      var result = await blockListDio.get('list');
      for (var json in result.data) {

      }
      return list;
    } on DioException catch (e) {
      onFailure(e);
      return [];
    }
  }

  //添加屏蔽用户
  static addBlock(String uid, {
    required OnSuccess onSuccess,
    required OnFailure onFailure,
  }) async {
    try {
      var data = FormData.fromMap({
        'uid': uid,
      });
      blockListDio.post('add', formData: data);
      onSuccess();
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  static deleteBlock(String uid, {
    required OnSuccess onSuccess,
    required OnFailure onFailure,
  }) async {
    try {
      var data = FormData.fromMap({
        'uid': uid,
      });
      blockListDio.post('delete', formData: data);
      onSuccess();
    } on DioException catch (e) {
      onFailure(e);
    }
  }

}
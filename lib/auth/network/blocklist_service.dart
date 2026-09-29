import '../../commons/environment/config.dart';
import '../../commons/network/wpy_dio.dart';
import '../../commons/token/lake_token_manager.dart';
import '../model/block_list_item.dart';

class BlockListDio extends DioAbstract {
  @override
  ///与 FeedbackDio 保持一致：baseUrl 收在 /api/v1/f/，具体路径用相对写法
  String baseUrl = '${EnvConfig.QNHD}api/v1/f/';

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

  ///获取当前登录用户的完整黑名单。
  ///接口不分页，最多 100 条，按加入时间倒序；
  ///被屏蔽用户已注销或被删除时 user_info 返回占位信息。
  static getBlockList({
    required void Function(List<BlockListItem> list) onSuccess,
    required OnFailure onFailure,
  }) async {
    try {
      var result = await blockListDio.get('blocklist');
      List<BlockListItem> list = [];
      for (Map<String, dynamic> json in result.data['data']['list']) {
        list.add(BlockListItem.fromJson(json));
      }
      onSuccess(list);
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  ///添加屏蔽用户。
  ///不能屏蔽自己、已注销或不存在以及受保护的用户；重复添加会失败；
  ///每个用户最多屏蔽 100 人。具体原因由后端通过 msg 返回。
  static addBlock(int uid, {
    required OnSuccess onSuccess,
    required OnFailure onFailure,
  }) async {
    try {
      var data = FormData.fromMap({
        'uid': uid,
      });
      await blockListDio.post('blocklist/add', formData: data);
      onSuccess();
    } on DioException catch (e) {
      onFailure(e);
    }
  }

  ///移除已屏蔽用户。后端当前实现使用 GET。
  static deleteBlock(int uid, {
    required OnSuccess onSuccess,
    required OnFailure onFailure,
  }) async {
    try {
      await blockListDio.get('blocklist/delete', queryParameters: {
        'uid': uid,
      });
      onSuccess();
    } on DioException catch (e) {
      onFailure(e);
    }
  }

}
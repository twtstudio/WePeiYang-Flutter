import '../../commons/environment/config.dart';
import '../../commons/network/wpy_dio.dart';
import '../../commons/token/lake_token_manager.dart';
import '../model/block_list_item.dart';

class BlockListDio extends DioAbstract {
  @override
  String baseUrl = '${EnvConfig.QNHD}api/v1/f/';

  @override
  List<Interceptor> interceptors = [
    InterceptorsWrapper(onRequest: (options, handler) async {
      try {
        options.headers['token'] = await LakeTokenManager().token;
        return handler.next(options);
      } catch (error) {
        return handler.reject(DioException(
          requestOptions: options,
          error: error is DioException ? error.error : error,
        ));
      }
    }, onResponse: (response, handler) {
      final data = response.data;
      if (data is! Map) {
        return handler.reject(WpyDioException(error: '屏蔽接口返回格式异常'), true);
      }
      if (data['code'] == 200) return handler.next(response);
      final message = data['msg'];
      return handler.reject(
        WpyDioException(
          error: message is String && message.isNotEmpty
              ? message
              : '屏蔽操作失败，请稍后重试',
        ),
        true,
      );
    })
  ];
}

final blockListDio = BlockListDio();

class BlockListService {
  /// 获取完整黑名单，按加入时间倒序返回，
  static Future<List<BlockListItem>> getBlockList() async {
    final response = await blockListDio.get('blocklist');
    final list = response.data['data']['list'] as List;
    return list
        .map((item) => BlockListItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// 添加成功后返回条目，供管理页面直接更新列表
  static Future<BlockListItem> addBlock(int uid) async {
    final response = await blockListDio.post(
      'blocklist/add',
      formData: FormData.fromMap({'uid': uid}),
    );
    return BlockListItem.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// 取消屏蔽
  static Future<void> deleteBlock(int uid) async {
    await blockListDio.get('blocklist/delete', queryParameters: {'uid': uid});
  }
}

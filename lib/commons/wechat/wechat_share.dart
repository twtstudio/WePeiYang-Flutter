import 'dart:io';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fluwx/fluwx.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/util/log/log.dart';
import 'post_share_link.dart';

/// 微北洋 × 微信开放平台：网页卡片分享。
///
/// 只负责"把应用内内容以卡片形式发到微信"，不涉及微信登录与支付。
///
/// 用法：
///   1. App 启动时调一次 [register]（见 main.dart）
///   2. 需要分享时调 [sharePost] 或 [shareWebPage]
///
/// 注意：微信的分享结果不会同步返回，而是走 [register] 里注册的回调。
/// 排查问题时看日志的 `[wechat]` 标签及完整回调，不能仅凭 -1 判断签名。
class WeChatShare {
  WeChatShare._();

  // --------------------------------------------------------------- 配置区

  /// ⚠️ 待填：微信开放平台 → 管理中心 → 移动应用 →「微北洋android」的 AppID。
  ///
  /// 必须是**移动应用**的 AppID（wx 开头），不是公众号 / 网站应用 / 小程序的。
  /// 这里还是占位值时，[register] 会跳过注册、[shareWebPage] 会拒绝分享，
  /// 但不会崩——填上真值即可启用，其他代码一行都不用改。
  static const String appId = 'wx2fc77fe50d01cf2c';

  static const String _placeholderAppId = 'wx0000000000000000';

  /// 网页卡片的地址；messageExt 只携带参数，不保证微信会唤起应用。
  static String landingPageForPost(int postId) => PostShareLink.webUrl(postId);

  /// 微信对缩略图的硬限制：超过 32KB 会导致整个分享请求发送失败。
  static const int maxThumbnailBytes = 32 * 1024;

  /// 卡片描述的建议长度。超出会被微信自己截断，先截好省得排版难看。
  static const int _maxDescriptionLength = 40;

  /// 下载网络图的超时。分享是用户主动触发的，不能让界面干等。
  static const Duration _downloadTimeout = Duration(seconds: 5);

  /// ⚠️ 临时诊断标签：非空时会在每次分享前打一条日志，
  /// 便于在日志页区分是哪个测试变体。问题定位后连同测试入口一起删除。
  static String debugVariant = '';

  // --------------------------------------------------------------- 注册

  static final Fluwx _fluwx = Fluwx();
  static bool _registered = false;
  static bool _subscribed = false;
  static const _testChannel = MethodChannel('com.twt.service/wechat_test');
  static const appMessageTestEnabled =
      bool.fromEnvironment('WECHAT_APP_MESSAGE_TEST');

  static void _subscribe() {
    if (_subscribed) return;
    _subscribed = true;
    _testChannel.setMethodCallHandler((call) async {
      if (call.method == 'diagnostic') {
        Log.i('应用消息测试: ${call.arguments}', tag: 'wechat');
      }
    });
    _fluwx.addSubscriber((response) {
      Log.i('微信回调: ${response.toRecord()}', tag: 'wechat');
      final ext = switch (response) {
        WeChatLaunchFromWXRequest r => r.extMsg,
        WeChatShowMessageFromWXRequest r => r.extMsg,
        _ => null,
      };
      if (ext != null) {
        unawaited(_openSharedPost(ext));
      }
    });
  }

  static Future<void> _openSharedPost(String ext) async {
    final id = PostShareLink.postIdFromAppUrl(ext);
    if (id == null || !Platform.isAndroid) return;
    Log.i('微信应用入口打开帖子: id=$id', tag: 'wechat');
    try {
      // Queue the same native event used by URL schemes and push messages.
      // It survives cold start and is consumed after login/home is ready.
      await const MethodChannel('com.twt.service/message')
          .invokeMethod<void>('openSharedPost', id);
    } catch (e, s) {
      Log.e(e, s, 'wechat');
    }
  }

  /// AppID 是否已经填成真实值。
  static bool get isConfigured => appId != _placeholderAppId;

  /// 在 App 启动时调用一次即可；重复调用是安全的（内部幂等）。
  ///
  /// 返回是否注册成功。AppID 尚未配置时返回 false，但不报错。
  static Future<bool> register() async {
    if (!Platform.isAndroid) return false;
    if (_registered) return true;
    _subscribe();
    if (!isConfigured) {
      Log.w('微信 AppID 仍是占位值，跳过注册，分享功能不可用', tag: 'wechat');
      return false;
    }

    try {
      // 只在 Android 注册：iOS 还需要 universal link，项目尚未配置。
      final ok = await _fluwx.registerApi(
        appId: appId,
        doOnAndroid: true,
        doOnIOS: false,
      );
      _registered = ok;

      if (ok) {
        // Replay the initial WeChat intent after the subscriber is ready.
        await _fluwx.attemptToResumeMsgFromWx();
      }

      Log.i('微信 SDK 注册${ok ? '成功' : '失败'}', tag: 'wechat');
      return ok;
    } catch (e, s) {
      Log.e(e, s, 'wechat');
      return false;
    }
  }

  /// 微信是否已安装。没装就不该去调起分享。
  static Future<bool> isWeChatInstalled() async {
    try {
      if (!await register()) return false;
      return await _fluwx.isWeChatInstalled;
    } catch (e, s) {
      Log.e(e, s, 'wechat');
      return false;
    }
  }

  // --------------------------------------------------------------- 分享

  /// 发一张网页卡片到微信。
  ///
  /// [scene] 传 [WeChatScene.session] 是发给好友/群（微信会弹出会话选择页），
  /// 传 [WeChatScene.timeline] 是发朋友圈（朋友圈不显示 description）。
  ///
  /// 返回 true 只代表"请求成功交给了微信"，真实结果在回调里。
  static Future<bool> shareWebPage({
    required String webPageUrl,
    required String title,
    String? description,
    String? messageExt,
    Uint8List? thumbnail,
    WeChatScene scene = WeChatScene.session,
  }) async {
    if (!await register()) {
      Log.w('微信 SDK 未注册，无法分享', tag: 'wechat');
      return false;
    }

    if (debugVariant.isNotEmpty) {
      Log.w('变体[$debugVariant] 发起网页分享', tag: 'wechat');
    }

    try {
      final sent = await _fluwx.share(
        WeChatShareWebPageModel(
          webPageUrl,
          title: title,
          description: description,
          messageExt: messageExt,
          scene: scene,
          thumbData: thumbnail,
        ),
      );
      Log.w('share() 返回 = $sent', tag: 'wechat');
      return sent;
    } catch (e, s) {
      Log.e(e, s, 'wechat');
      return false;
    }
  }

  /// 分享一个帖子（求实论坛）。
  ///
  /// [coverImageUrl] 传帖子首图，会先压到 32KB 以内再当缩略图；
  /// 压缩失败会自动放弃缩略图，不影响卡片本身。
  static Future<bool> sharePost({
    required int postId,
    required String title,
    String? description,
    String? coverImageUrl,
    // ⚠️ 以下两个参数仅供临时诊断使用，问题定位后删除
    bool toTimeline = false,
    bool withThumbnail = true,
  }) async {
    final thumbnail =
        withThumbnail ? await buildThumbnail(coverImageUrl) : null;
    return shareWebPage(
      webPageUrl: landingPageForPost(postId),
      title: title,
      description: description,
      messageExt: PostShareLink.appUrl(postId),
      thumbnail: thumbnail,
      scene: toTimeline ? WeChatScene.timeline : WeChatScene.session,
    );
  }

  /// Experimental app message; only the recipient's device can prove app launch.
  static Future<bool> sharePostAppMessageForTest({
    required int postId,
    required String title,
    String? description,
    String? coverImageUrl,
  }) async {
    if (!Platform.isAndroid || !appMessageTestEnabled) return false;
    if (!await register()) return false;
    try {
      final thumbnail = await buildThumbnail(coverImageUrl);
      final sent = await _testChannel.invokeMethod<bool>('shareAppMessage', {
        'postId': postId,
        'title': title,
        'description': description,
        'thumbnail': thumbnail,
      });
      Log.i('应用消息测试发送返回: $sent（不代表点击唤起成功）', tag: 'wechat');
      return sent == true;
    } catch (e, s) {
      Log.e(e, s, 'wechat');
      return false;
    }
  }

  /// ⚠️ 临时诊断用：发一条纯文本消息。
  ///
  /// 目的：区分"整个 AppID 被微信拒绝"和"网页类型特有的问题"。
  /// 问题定位后请删除此方法。
  static Future<bool> sharePlainText(String text) async {
    if (!_registered) {
      Log.w('微信 SDK 未注册，无法分享', tag: 'wechat');
      return false;
    }

    if (debugVariant.isNotEmpty) {
      Log.w('变体[$debugVariant] 发起文字分享', tag: 'wechat');
    }

    try {
      final sent = await _fluwx.share(
        WeChatShareTextModel(text, scene: WeChatScene.session),
      );
      Log.w('share() 返回 = $sent', tag: 'wechat');
      return sent;
    } catch (e, s) {
      Log.e(e, s, 'wechat');
      return false;
    }
  }

  /// ⚠️ 临时诊断用：把本进程的 logcat 抓进日志页。
  ///
  /// 微信 SDK 的内部日志（wxSdkVersion、checkArgs、token 等）只打到 logcat，
  /// release 包里我们的日志页看不到，所以这里主动捞一次。
  /// 问题定位后请删除此方法。
  static Future<void> dumpWeChatLogcat() async {
    try {
      final r = await Process.run('logcat', ['-d', '-v', 'time', '-t', '2000']);
      final text = r.stdout.toString();
      final lines = text.split('\n').where((l) =>
          l.contains('MicroMsg') ||
          l.contains('WXApi') ||
          l.contains('wxSdkVersion') ||
          l.contains('OPEN_SDK_VERSION') ||
          l.contains('checkArgs') ||
          l.contains('handleIntent') ||
          l.contains('sendReq') ||
          l.contains('token'));
      var n = 0;
      for (final line in lines) {
        Log.w('LOGCAT| $line', tag: 'wechat');
        n++;
      }
      Log.w('LOGCAT 抓取完成，命中 $n 行', tag: 'wechat');
    } catch (e, s) {
      Log.e(e, s, 'wechat');
    }
  }

  /// ⚠️ 临时诊断用：**先清空 logcat → 再分享 → 然后抓取**。
  ///
  /// 这样 logcat 窗口里只剩分享相关的日志，能抓到 SDK 的
  /// sendReq / handleIntent / wxSdkVersion 等细节。
  /// 问题定位后请删除此方法。
  static Future<void> diagnoseShareWithLog({
    required int postId,
    required String title,
    String? description,
  }) async {
    try {
      await Process.run('logcat', ['-c']);
      Log.w('已清空 logcat，准备分享', tag: 'wechat');
    } catch (_) {}

    await sharePost(postId: postId, title: title, description: description);

    // 留时间从微信返回；期间 Dart 定时器仍会执行
    await Future.delayed(const Duration(seconds: 12));
    await dumpWeChatLogcat();
  }

  /// 把帖子正文压成一句能看的卡片描述：去 html 标签、折叠空白、按长度截断。
  static String buildDescription(
    String? content, {
    String fallback = '快来看看吧~',
  }) {
    if (content == null) return fallback;

    final plain = content
        .replaceAll(RegExp(r'<[^>]*>'), ' ') // html 标签
        .replaceAll(RegExp(r'&[a-zA-Z#0-9]+;'), ' ') // html 实体
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (plain.isEmpty) return fallback;

    // 按 runes 截断，避免把 emoji 的代理对切成半个字符。
    final runes = plain.runes.toList();
    if (runes.length <= _maxDescriptionLength) return plain;
    return '${String.fromCharCodes(runes.take(_maxDescriptionLength))}…';
  }

  // --------------------------------------------------------------- 缩略图

  /// 下载网络图并压到 32KB 以内，用作卡片缩略图。
  ///
  /// 全程 best-effort：下载失败、格式不支持、压不进 32KB 都返回 null ——
  /// 这时微信会退回用落地页自己的图，分享本身不受影响。
  static Future<Uint8List?> buildThumbnail(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return null;

    // imageUrls 里存的是相对路径，必须拼上图片 CDN 前缀。
    // 优先 thumb/（体积小，更容易压进 32KB），拿不到再退回 origin/。
    final base = EnvConfig.QNHDPIC;
    final raw = await _downloadBytes('${base}download/thumb/$imageUrl') ??
        await _downloadBytes('${base}download/origin/$imageUrl');
    if (raw == null || raw.isEmpty) return null;

    // 微信建议 128×128。从大尺寸+高质量开始，逐步降级直到能进 32KB。
    for (final size in const [128, 96, 64]) {
      for (final quality in const [85, 70, 55, 40, 25]) {
        final compressed = await _compress(raw, size, quality);
        if (compressed != null &&
            compressed.lengthInBytes <= maxThumbnailBytes) {
          Log.d(
            '缩略图压缩完成: ${size}px/q$quality, '
            '${compressed.lengthInBytes}B',
            tag: 'wechat',
          );
          return compressed;
        }
      }
    }

    Log.w('缩略图压不进 32KB，放弃使用缩略图', tag: 'wechat');
    return null;
  }

  /// 下载图片。用独立的 Dio 实例：图床是公开的，不需要带项目的拦截器和 token。
  static Future<Uint8List?> _downloadBytes(String url) async {
    try {
      final response = await Dio(
        BaseOptions(
          connectTimeout: _downloadTimeout,
          receiveTimeout: _downloadTimeout,
        ),
      ).get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final data = response.data;
      if (data == null || data.isEmpty) return null;
      return Uint8List.fromList(data);
    } catch (e, s) {
      Log.e(e, s, 'wechat');
      return null;
    }
  }

  static Future<Uint8List?> _compress(
    Uint8List raw,
    int size,
    int quality,
  ) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        raw,
        minWidth: size,
        minHeight: size,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      // 压缩失败时插件返回空数组，这里统一按失败处理。
      if (result.isEmpty) return null;
      return result;
    } catch (e, s) {
      Log.e(e, s, 'wechat');
      return null;
    }
  }
}

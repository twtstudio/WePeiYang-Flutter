import 'package:webview_flutter/webview_flutter.dart';
import 'package:we_pei_yang_flutter/commons/webview/javascript_channels/img_save_channel.dart';
import 'package:we_pei_yang_flutter/commons/webview/javascript_channels/share_channel.dart';

class WebViewChannelConfig {
  final String name;
  final void Function(JavaScriptMessage) onMessageReceived;

  const WebViewChannelConfig(this.name, this.onMessageReceived);
}

class WebViewConfig {
  final String page;
  final String url;
  final List<WebViewChannelConfig> channels;

  WebViewConfig._(this.page, this.url, this.channels);

  factory WebViewConfig.fromJson(Map map) {
    final page = map['page'] ?? "";
    final url = map['url'] ?? "";
    final chs = <WebViewChannelConfig>[];

    for (final c in '${map['channels']}'.split(',')) {
      if (c == WebViewChannels.share.value) {
        chs.add(ShareChannel.config(page));
      } else if (c == WebViewChannels.saveImg.value) {
        chs.add(ImgSaveChannel.config(page));
      }
    }

    return WebViewConfig._(page, url, chs);
  }
}

enum WebViewChannels { share, saveImg }

extension WebViewChannelsExt on WebViewChannels {
  String get value => ['share', 'saveImg'][index];
}

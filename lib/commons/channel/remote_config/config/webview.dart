import 'package:we_pei_yang_flutter/commons/webview/javascript_channels/img_save_channel.dart';
import 'package:we_pei_yang_flutter/commons/webview/javascript_channels/share_channel.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewConfig {
  final String page;
  final String url;
  final List<JavascriptChannel> channels;

  WebViewConfig._(this.page, this.url, this.channels);

  factory WebViewConfig.fromJson(Map map) {
    final page = map['page'] ?? "";
    final url = map['url'] ?? "";
    final _channels = <JavascriptChannel>[];

    void addChannel(String c) {
      if (c == WebViewChannels.share.value) {
        _channels.add(ShareChannel(page));
      } else if (c == WebViewChannels.saveImg.value) {
        _channels.add(ImgSaveChannel(page));
      }
    }

    '${map['channels']}'.split(',').forEach(addChannel);

    return WebViewConfig._(page, url, _channels);
  }
}

enum WebViewChannels { share, saveImg }

extension WebViewChannelsExt on WebViewChannels {
  String get value => ['share', 'saveImg'][index];
}

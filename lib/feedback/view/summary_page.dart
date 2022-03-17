// @dart = 2.12

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/channel/image_save/image_save.dart';
import 'package:we_pei_yang_flutter/commons/channel/share/share.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FeedbackSummaryPage extends StatefulWidget {
  const FeedbackSummaryPage({Key? key}) : super(key: key);

  @override
  _FeedbackSummaryPageState createState() => _FeedbackSummaryPageState();
}

class _FeedbackSummaryPageState extends State<FeedbackSummaryPage> {
  double opacity = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "校务专区总结",
          style: FontManager.YaHeiRegular.copyWith(
            fontSize: 16,
            color: Color.fromRGBO(36, 43, 69, 1),
          ),
        ),
        elevation: 0,
        brightness: Brightness.light,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: GestureDetector(
              child: Icon(Icons.arrow_back,
                  color: Color.fromRGBO(53, 59, 84, 1), size: 32),
              onTap: () => Navigator.pop(context)),
        ),
      ),
      body: Opacity(
        opacity: opacity,
        child: WebView(
          initialUrl: "https://areas.twt.edu.cn/summary",
          javascriptMode: JavascriptMode.unrestricted,
          onPageFinished: (_) {
            setState(() {
              opacity = 1.0;
            });
          },
          onWebResourceError: (WebResourceError error) {
            ToastProvider.error('加载遇到了错误');
          },
          javascriptChannels: <JavascriptChannel>[
            JavascriptChannel(
              name: "Toast",
              onMessageReceived: (JavascriptMessage message) async {
                try {
                  Uint8List bytes =
                      base64.decode(message.message.split(",")[1]);
                  final fileName =
                      "校务总结页面${DateTime.now().millisecondsSinceEpoch}.jpg";
                  await ImageSave.saveImageToAlbum(bytes, fileName)
                      .then((path) async {
                    await ShareManager.shareImgToQQ(path);
                  });
                } catch (_) {
                  ToastProvider.error('分享失败');
                }
              },
            ),
          ].toSet(),
        ),
      ),
    );
  }
}

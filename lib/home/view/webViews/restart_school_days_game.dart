import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

class RestartSchoolDaysGamePage extends StatefulWidget {
  const RestartSchoolDaysGamePage({Key key}) : super(key: key);

  @override
  _RestartSchoolDaysGamePageState createState() =>
      _RestartSchoolDaysGamePageState();
}

class _RestartSchoolDaysGamePageState extends State<RestartSchoolDaysGamePage> {
  double opacity = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("大学重开模拟器",
            style: FontManager.YaHeiRegular.copyWith(
                fontSize: 16, color: Color.fromRGBO(36, 43, 69, 1))),
        elevation: 0,
        brightness: Brightness.light,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: GestureDetector(
              child: Icon(Icons.arrow_back,
                  color: Color.fromRGBO(53, 59, 84, 1.0), size: 32),
              onTap: () => Navigator.pop(context)),
        ),
      ),
      body: Opacity(
        opacity: opacity,
        child: WebView(
          initialUrl: "http://restart.twtstudio.com",
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
                    List<Directory> tempDir =
                        await getExternalStorageDirectories(
                            type: StorageDirectory.pictures);
                    var newImg = File(
                        "${tempDir.first.path}/人生重开模拟器${DateTime.now().millisecondsSinceEpoch}.jpg")
                      ..writeAsBytesSync(bytes);
                    var channel = BasicMessageChannel(
                        'com.twt.service/saveBase64Img', StringCodec());
                    var result = await channel.send(newImg.absolute.path);
                    if (result != null) ToastProvider.success("保存成功");
                  } catch (_) {
                    ToastProvider.error('图片保存失败');
                  }
                }),
          ].toSet(),
        ),
      ),
    );
  }
}

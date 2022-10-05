import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class FiftyTwoHzPage extends StatelessWidget {
  final String url =
      'https://52Hz.twt.edu.cn/#/?token=${CommonPreferences.token.value}';
  WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var flag = await _controller.canGoBack();
        if (flag) _controller.goBack();
        return !flag;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Text('52赫兹',
                style: TextUtil.base.bold
                    .sp(16)
                    .customColor(Color.fromRGBO(36, 43, 69, 1))),
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
            )),
        body: WebView(
            initialUrl: url,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController controller) {
              this._controller = controller;
            }),
      ),
    );
  }
}

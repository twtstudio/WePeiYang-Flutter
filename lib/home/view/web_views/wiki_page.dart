import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

import '../../../commons/util/color_util.dart';

// ignore: must_be_immutable
class WikiPage extends StatelessWidget {
  static const URL = "https://wiki.tjubot.cn/";
  WebViewController? _controller;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var flag = await _controller?.canGoBack() ?? false;
        if (flag) _controller!.goBack();
        return !flag;
      },
      child: Scaffold(
        backgroundColor: ColorUtil.whiteFFColor,
        appBar: AppBar(
            title: Text(S.current.wiki,
                style: TextUtil.base.bold
                    .sp(16)
                    .customColor(ColorUtil.blue52hz)),
            elevation: 0,
            centerTitle: true,
            backgroundColor: ColorUtil.whiteFFColor,
            leading: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: GestureDetector(
                  child: Icon(Icons.arrow_back,
                      color: ColorUtil.boldTag54, size: 32),
                  onTap: () => Navigator.pop(context)),
            )),
        body: WebView(
            initialUrl: URL,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController controller) {
              this._controller = controller;
            }),
      ),
    );
  }
}

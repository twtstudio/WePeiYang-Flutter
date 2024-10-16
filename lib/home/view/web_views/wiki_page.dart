import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../commons/themes/wpy_theme.dart';

// ignore: must_be_immutable
class WikiPage extends StatelessWidget {
  static const URL = "https://wiki.tjubot.cn/";
  WebViewController? _controller;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (await _controller?.canGoBack() ?? false)
          _controller!.goBack();
        else
          Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        appBar: AppBar(
            title: Text('北洋维基',
                style: TextUtil.base.bold.sp(16).blue52hz(context)),
            elevation: 0,
            centerTitle: true,
            backgroundColor:
                WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
            leading: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: WButton(
                  child: Icon(Icons.arrow_back,
                      color: WpyTheme.of(context)
                          .get(WpyColorKey.defaultActionColor),
                      size: 32),
                  onPressed: () => Navigator.pop(context)),
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

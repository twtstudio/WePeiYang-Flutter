import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../commons/widgets/w_button.dart';

class AboutTwtPage extends StatelessWidget {
  static const URL = "https://www.twt.edu.cn/";

  @override
  Widget build(BuildContext context) {
    WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(
          WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor))
      ..loadRequest(Uri.parse(URL));
    return Scaffold(
      backgroundColor:
          WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
      appBar: AppBar(
          title: Text('关于天外天', style: TextUtil.base.bold.sp(16).label(context)),
          elevation: 0,
          centerTitle: true,
          backgroundColor:
              WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: WButton(
                child: Icon(Icons.arrow_back,
                    color: WpyTheme.of(context).get(WpyColorKey.labelTextColor),
                    size: 32),
                onPressed: () => Navigator.pop(context)),
          )),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/widgets/w_button.dart';

class AboutTwtPage extends StatelessWidget {
  static const URL = "https://i.twt.edu.cn/#/about";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
      appBar: AppBar(
          title: Text('about_twt',
              style: TextUtil.base.bold.sp(16).label(context)),
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
      body:
          WebView(initialUrl: URL, javascriptMode: JavascriptMode.unrestricted),
    );
  }
}

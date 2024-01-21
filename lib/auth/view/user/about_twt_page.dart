import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../commons/widgets/w_button.dart';

class AboutTwtPage extends StatelessWidget {
  static const URL = "https://i.twt.edu.cn/#/about";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtil.whiteFFColor,
      appBar: AppBar(
          title: Text(S.current.about_twt,
              style: TextUtil.base.bold.sp(16).blue52hz),
          elevation: 0,
          centerTitle: true,
          backgroundColor: ColorUtil.whiteFFColor,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: WButton(
                child:
                    Icon(Icons.arrow_back, color: ColorUtil.blue52hz, size: 32),
                onPressed: () => Navigator.pop(context)),
          )),
      body:
          WebView(initialUrl: URL, javascriptMode: JavascriptMode.unrestricted),
    );
  }
}

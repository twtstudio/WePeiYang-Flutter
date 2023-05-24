import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class AboutTwtPage extends StatelessWidget {
  static const URL = "https://i.twt.edu.cn/#/about";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text(S.current.about_twt,
              style: TextUtil.base.bold
                  .sp(16)
                  .customColor(Color.fromRGBO(36, 43, 69, 1))),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(53, 59, 84, 1), size: 32),
                onTap: () => Navigator.pop(context)),
          )),
      body:
          WebView(initialUrl: URL, javascriptMode: JavascriptMode.unrestricted),
    );
  }
}

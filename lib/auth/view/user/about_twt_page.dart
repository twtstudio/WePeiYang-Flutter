import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';

class AboutTwtPage extends StatelessWidget {
  static const URL = "https://i.twt.edu.cn/#/about";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text(S.current.about_twt,
              style: FontManager.YaHeiRegular.copyWith(
                  fontSize: 16,
                  color: Color.fromRGBO(36, 43, 69, 1),
                  fontWeight: FontWeight.bold)),
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
          )),
      body:
          WebView(initialUrl: URL, javascriptMode: JavascriptMode.unrestricted),
    );
  }
}

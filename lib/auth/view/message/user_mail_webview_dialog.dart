import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../commons/themes/wpy_theme.dart';

class UserMailDialog extends Dialog {
  final String url;

  UserMailDialog(this.url);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 500,
            width: 300,
            color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
            child: CustomWebView(url),
          ),
        ),
      ),
    );
  }
}

class CustomWebView extends StatefulWidget {
  final String url;

  CustomWebView(this.url);

  @override
  _CustomWebViewState createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(
          WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor))
      ..loadRequest(Uri.parse(widget.url));
  }

  /*
      initialUrl: widget.url,
      javascriptMode: JavascriptMode.unrestricted,
   */

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: controller,
    );
  }
}

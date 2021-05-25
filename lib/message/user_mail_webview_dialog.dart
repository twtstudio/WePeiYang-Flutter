import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UserMailDialog extends Dialog {
  final String url;

  UserMailDialog(this.url);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.all(
            const Radius.circular(20.0),
          ),
          child: Container(
            color: Colors.white,
            height: 500,
            width: 300,
            child: WebView(
              initialUrl: url,
            ),
          ),
        ),
      ),
    );
  }
}

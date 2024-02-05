import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/webview/wby_webview.dart';

import '../../../commons/themes/wpy_theme.dart';

class FestivalArgs {
  final String url;
  final String name;

  FestivalArgs(this.url, this.name);
}

class FestivalPage extends WbyWebView {
  final FestivalArgs args;

  FestivalPage(this.args, {Key? key, required BuildContext context})
      : super(
            page: args.name,
            backgroundColor: WpyTheme.of(context).get(WpyThemeKeys.primaryBackgroundColor),
            fullPage: false,
            key: key);

  @override
  _FestivalPageState createState() => _FestivalPageState(this.args);
}

class _FestivalPageState extends WbyWebViewState {
  FestivalArgs args;

  _FestivalPageState(this.args);

  @override
  Future<String> getInitialUrl(BuildContext context) async {
    return args.url
        .replaceAll('<token>', '${CommonPreferences.token.value}')
        .replaceAll('<laketoken>', '${CommonPreferences.lakeToken.value}');
  }
}

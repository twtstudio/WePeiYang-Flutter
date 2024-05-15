import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/channel/remote_config/config/webview.dart';
import 'package:we_pei_yang_flutter/commons/channel/remote_config/remote_config_manager.dart';
import 'package:we_pei_yang_flutter/commons/channel/statistics/umeng_statistics.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../themes/template/wpy_theme_data.dart';
import '../themes/wpy_theme.dart';
import '../widgets/w_button.dart';

class WbyWebView extends StatefulWidget {
  final String page;
  final bool fullPage;
  final WpyColorKey backgroundColor;

  const WbyWebView(
      {Key? key,
      required this.page,
      required this.fullPage,
      required this.backgroundColor})
      : super(key: key);

  @override
  WbyWebViewState createState() => WbyWebViewState();
}

enum _PageState { initUrl, initError, initWebView, showWebView }

class WbyWebViewState extends State<WbyWebView> {
  _PageState state = _PageState.initUrl;
  WebViewController _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted);

  @override
  void initState() {
    super.initState();
    UmengCommonSdk.onPageStart('webview/${widget.page}');
  }

  @override
  void dispose() {
    super.dispose();
    UmengCommonSdk.onPageEnd('webview/${widget.page}');
  }

  PreferredSizeWidget get appBar => AppBar(
        title: Text(
          widget.page,
          style: TextUtil.base.primary(context).sp(16),
        ),
        elevation: 0,
        toolbarHeight: 40,
        centerTitle: true,
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: WButton(
            child: Icon(Icons.arrow_back,
                color: WpyTheme.of(context).get(WpyColorKey.oldActionColor),
                size: 32),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );

  Future<String?> getInitialUrl(BuildContext context) async {
    return context.select(
      (RemoteConfig config) => config.webViews[widget.page]?.url,
    );
  }

  List<JavascriptChannel>? getJsChannels() {
    return context.select(
      (RemoteConfig config) => config.webViews[widget.page]?.channels,
    );
  }

  Future<void> initUrl() async {
    if (state == _PageState.initError) {
      setState(() {
        state = _PageState.initUrl;
      });
    }
    final url =
        await getInitialUrl(context).then((u) => u, onError: (_) => null);
    if (url != null) {
      setState(() {
        state = _PageState.initWebView;
        _controller.loadRequest(Uri.parse(url));
      });
    } else {
      setState(() {
        state = _PageState.initError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget top;

    if (state == _PageState.initError) {
      top = WButton(onPressed: initUrl, child: Text("遇到错误请重试"));
    } else {
      top = Loading();
    }

    top = Visibility(
      visible: !(state == _PageState.showWebView),
      child: top,
    );

    final body = Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: state == _PageState.showWebView ? 1.0 : 0.0,
          child: WebViewWidget(
            /*

            onWebViewCreated: (controller) {
              _controller = controller;
              WidgetsBinding.instance.addPostFrameCallback((_) => initUrl());
            },
            javascriptMode: JavascriptMode.unrestricted,
            gestureNavigationEnabled: true,
            onPageStarted: (_) {
              setState(() {
                state = _PageState.showWebView;
              });
            },
            onWebResourceError: (error) {
              ToastProvider.error('加载遇到了错误');
            },
            javascriptChannels: (getJsChannels() ?? []).toSet(),
             */
            controller: _controller,
          ),
        ),
        top,
      ],
    );

    return widget.fullPage
        ? body
        : Scaffold(
            backgroundColor: WpyTheme.of(context).get(widget.backgroundColor),
            body: SafeArea(
              child: Column(
                children: [
                  appBar,
                  Expanded(child: body),
                ],
              ),
            ),
          );
  }
}

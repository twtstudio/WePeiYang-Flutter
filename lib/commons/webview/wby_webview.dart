import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:we_pei_yang_flutter/commons/channel/remote_config/remote_config_manager.dart';
import 'package:we_pei_yang_flutter/commons/channel/remote_config/config/webview.dart';
import 'package:we_pei_yang_flutter/commons/channel/statistics/umeng_statistics.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';

import '../themes/template/wpy_theme_data.dart';
import '../themes/wpy_theme.dart';
import '../widgets/w_button.dart';

class WbyWebView extends StatefulWidget {
  final String page;
  final bool fullPage;
  final WpyColorKey backgroundColor;

  const WbyWebView({
    super.key,
    required this.page,
    required this.fullPage,
    required this.backgroundColor,
  });

  @override
  WbyWebViewState createState() => WbyWebViewState();
}

enum _PageState { initUrl, initError, loading, showWebView }

class WbyWebViewState extends State<WbyWebView> {
  _PageState state = _PageState.initUrl;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => state = _PageState.loading);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => state = _PageState.showWebView);
          },
          onWebResourceError: (_) {
            ToastProvider.error('加载遇到了错误');
          },
        ),
      );
    WidgetsBinding.instance.addPostFrameCallback((_) => initUrl());
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
    return context.read<RemoteConfig>().webViews[widget.page]?.url;
  }

  List<WebViewChannelConfig> getChannels(BuildContext context) {
    return context.read<RemoteConfig>().webViews[widget.page]?.channels ?? [];
  }

  Future<void> initUrl() async {
    if (state == _PageState.initError)
      setState(() => state = _PageState.initUrl);
    try {
      final url = await getInitialUrl(context);
      if (!mounted) return;
      if (url != null) {
        for (final c in getChannels(context)) {
          _controller.addJavaScriptChannel(c.name,
              onMessageReceived: c.onMessageReceived);
        }
        setState(() => state = _PageState.loading);
        await _controller.loadRequest(Uri.parse(url));
      } else {
        setState(() => state = _PageState.initError);
      }
    } catch (_) {
      if (mounted) setState(() => state = _PageState.initError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topWidget = state == _PageState.initError
        ? WButton(onPressed: initUrl, child: Text("遇到错误请重试"))
        : Loading();

    final body = Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: state == _PageState.showWebView ? 1.0 : 0.0,
          child: WebViewWidget(controller: _controller),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: state == _PageState.showWebView
              ? const SizedBox.shrink()
              : Center(child: topWidget),
        ),
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

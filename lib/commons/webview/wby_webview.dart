// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/channel/remote_config/remote_config_manager.dart';
import 'package:we_pei_yang_flutter/commons/channel/statistics/umeng_statistics.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WbyWebView extends StatefulWidget {
  final String page;
  final bool fullPage;
  final Color backgroundColor;

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
  WebViewController? _controller;

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
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        elevation: 0,
        brightness: Brightness.light,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: GestureDetector(
            child: Icon(Icons.arrow_back,
                color: Color.fromRGBO(53, 59, 84, 1), size: 32),
            onTap: () => Navigator.pop(context),
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
        print(url);
        state = _PageState.initWebView;
        _controller?.loadUrl(url);
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
      top = TextButton(onPressed: initUrl, child: Text("遇到错误请重试"));
    } else {
      top = Loading();
    }

    top = Visibility(
      visible: !(state == _PageState.showWebView),
      child: top,
    );

    final body = Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: state == _PageState.showWebView ? 1.0 : 0.0,
          child: WebView(
            onWebViewCreated: (controller) {
              _controller = controller;
              WidgetsBinding.instance?.addPostFrameCallback((_) => initUrl());
            },
            javascriptMode: JavascriptMode.unrestricted,
            onPageStarted: (_) {
              setState(() {
                state = _PageState.showWebView;
              });
            },
            onWebResourceError: (error) {
              ToastProvider.error('加载遇到了错误');
            },
            javascriptChannels: (getJsChannels() ?? []).toSet(),
          ),
        ),
        top,
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
              child: Icon(Icons.arrow_back,
                  color: Color.fromRGBO(53, 59, 84, 1), size: 32),
              onTap: () => Navigator.pop(context),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            if (!widget.fullPage)
              appBar,
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

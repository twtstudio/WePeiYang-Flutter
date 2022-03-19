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

  const WbyWebView({Key? key, required this.page}) : super(key: key);

  @override
  WbyWebViewState createState() => WbyWebViewState();
}

class WbyWebViewState extends State<WbyWebView> {
  var loadSuccess = false;

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
          style: TextStyle(fontSize: 16,color: Colors.black),
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

  Future<String> getInitialUrl(BuildContext context) async {
    return context.select(
      (RemoteConfig config) => config.webViews[widget.page]?.url,
    ).toString();
  }

  @override
  Widget build(BuildContext context) {
    final channels = context.select(
      (RemoteConfig config) => config.webViews[widget.page]?.channels,
    );

    final body = Stack(
      alignment: Alignment.center,
      children: [
        FutureBuilder(
          future: getInitialUrl(context),
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              return Opacity(
                opacity: loadSuccess ? 1.0 : 0.0,
                child: WebView(
                  initialUrl: snapshot.data.toString(),
                  javascriptMode: JavascriptMode.unrestricted,
                  onPageStarted: (_) {
                    if (!loadSuccess){
                      setState(() {
                        loadSuccess = true;
                      });
                    }
                  },
                  onWebResourceError: (error) {
                    ToastProvider.error('加载遇到了错误');
                  },
                  javascriptChannels: (channels ?? []).toSet(),
                ),
              );
            }
            return SizedBox.shrink();
          },
        ),
        Visibility(visible: !loadSuccess, child: Loading()),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar,
      body: body,
    );
  }
}

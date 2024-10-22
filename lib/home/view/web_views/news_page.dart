import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/network/classes_service.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class NewsPage extends StatelessWidget {
  static const URL = "https://news.twt.edu.cn/";
  WebViewController? _controller;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (CommonPreferences.showNewsNetwork.value &&
          !(await ClassesService.check(timeout: Duration(seconds: 1)))) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) => NewNetworkAlertDialog(),
        );
      }
    });

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (await _controller?.canGoBack() ?? false)
          _controller!.goBack();
        else
          Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        appBar: AppBar(
            title: Text("天外天新闻网",
                style: TextUtil.base.bold.sp(16).blue52hz(context)),
            elevation: 0,
            centerTitle: true,
            backgroundColor:
                WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
            leading: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: WButton(
                  child: Icon(Icons.arrow_back,
                      color: WpyTheme.of(context)
                          .get(WpyColorKey.defaultActionColor),
                      size: 32),
                  onPressed: () => Navigator.pop(context)),
            )),
        body: WebView(
            initialUrl: URL,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController controller) {
              this._controller = controller;
            }),
      ),
    );
  }
}

class NewNetworkAlertDialog extends StatelessWidget {
  const NewNetworkAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final _roundShape = MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // 设置边框圆角为20
      ),
    );
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 25, right: 25, top: 20, bottom: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "新闻网提示",
                style: TextUtil.base.NotoSansSC.bold.primary(context).sp(20),
              ),
              SizedBox(height: 10.h),
              Text(
                "新闻网目前仅可在校园网环境下访问\n请确保已经连接校园网或使用VPN",
                style: TextUtil.base.NotoSansSC.normal.primary(context).sp(15),
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                      style: ButtonStyle(
                        shape: _roundShape,
                      ),
                      onPressed: () {
                        CommonPreferences.showNewsNetwork.value = false;
                        Navigator.pop(context);
                      },
                      child: Text(
                        "不再提示",
                        style: TextUtil.base.NotoSansSC.bold
                            .primaryAction(context)
                            .sp(12),
                      )),
                  ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all<double>(3),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        WpyTheme.of(context)
                            .get(WpyColorKey.primaryActionColor),
                      ),
                      shape: _roundShape,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("确定",
                        style: TextUtil.base.NotoSansSC.bold
                            .sp(14)
                            .bright(context)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

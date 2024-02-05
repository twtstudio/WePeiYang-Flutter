import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:simple_url_preview_v2/simple_url_preview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:we_pei_yang_flutter/auth/view/message/message_router.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/widgets/w_button.dart';
import '../../network/message_service.dart';

class UserMailboxPage extends StatefulWidget {
  @override
  _UserMailboxPageState createState() => _UserMailboxPageState();
}

class _UserMailboxPageState extends State<UserMailboxPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtil.whiteF8Color,
      appBar: AppBar(
          title: Text(S.current.message,
              style: TextUtil.base.bold.sp(16).blue52hz),
          elevation: 0,
          centerTitle: true,
          backgroundColor:
              WpyTheme.of(context).get(WpyThemeKeys.primaryBackgroundColor),
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: WButton(
                child: Icon(Icons.arrow_back,
                    color: WpyTheme.of(context).get(WpyThemeKeys.oldActionColor), size: 32),
                onPressed: () => Navigator.pop(context)),
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark),
      body: UserMailList(),
    );
  }
}

class UserMailList extends StatefulWidget {
  @override
  _UserMailListState createState() => _UserMailListState();
}

class _UserMailListState extends State<UserMailList> {
  UserMessages? _messages;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _messages = await getUserMails(0);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_messages == null) {
      return Center(child: Text("waiting"));
    }
    return ListView.builder(
      itemCount: _messages!.mails.length,
      itemBuilder: (_, i) {
        return MailItem(data: _messages!.mails[i]);
      },
    );
  }
}

class MailItem extends StatefulWidget {
  final UserMail data;

  const MailItem({Key? key, required this.data}) : super(key: key);

  @override
  _MailItemState createState() => _MailItemState();
}

class _MailItemState extends State<MailItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: GestureDetector(
        onTapUp: (_) {
          Navigator.pushNamed(
            context,
            MessageRouter.mailPage,
            arguments: widget.data,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  blurRadius: 5,
                  color: ColorUtil.greyShadow64,
                  offset: Offset.zero,
                  spreadRadius: 3),
            ],
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10),
            color:
                WpyTheme.of(context).get(WpyThemeKeys.primaryBackgroundColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.data.title,
                style: TextUtil.base.bold.oldActionColor(context).sp(15),
              ),
              SizedBox(height: 10),
              Text(
                widget.data.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextUtil.base.oldActionColor(context).sp(13),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Image.asset(
                    'assets/images/account/cloud.png',
                    width: 17,
                    color: ColorUtil.black00Color,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "twt",
                    style: TextUtil.base.grey4146.sp(11),
                  ),
                  Spacer(),
                  Text(
                    widget.data.time.replaceRange(10, 11, ' ').substring(0, 19),
                    style: TextUtil.base.whiteb1b2.sp(11),
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

class MailPage extends StatelessWidget {
  final UserMail data;

  const MailPage({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtil.whiteF8Color,
      appBar: AppBar(
        title: Text('通知', style: TextUtil.base.regular.sp(16).blue52hz),
        elevation: 0,
        centerTitle: true,
        backgroundColor:
            WpyTheme.of(context).get(WpyThemeKeys.primaryBackgroundColor),
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: WButton(
              child: Icon(Icons.arrow_back,
                  color: WpyTheme.of(context).get(WpyThemeKeys.oldActionColor), size: 32),
              onPressed: () => Navigator.pop(context)),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: _TextMailContent(data: data),
    );
  }
}

// class _HtmlMailContent extends StatefulWidget {
//   final UserMail data;
//
//   const _HtmlMailContent({Key key, this.data}) : super(key: key);
//
//   @override
//   _HtmlMailContentState createState() => _HtmlMailContentState();
// }
//
// class _HtmlMailContentState extends State<_HtmlMailContent> {
//   double opacity = 0.0;
//   bool loadSuccess = true;
//   bool showLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Widget result;
//     if (loadSuccess) {
//       result = Stack(
//         alignment: Alignment.center,
//         children: [
//           Visibility(visible: showLoading, child: Loading()),
//           Opacity(
//             opacity: opacity,
//             child: WebView(
//               initialUrl: widget.data.url,
//               javascriptMode: JavascriptMode.unrestricted,
//               onPageFinished: (_) {
//                 setState(() {
//                   showLoading = false;
//                   opacity = 1.0;
//                 });
//               },
//               onProgress: (_) {
//                 setState(() {
//                   showLoading = true;
//                 });
//               },
//               onWebResourceError: (WebResourceError error) {
//                 ToastProvider.error('加载遇到了错误');
//                 setState(() {
//                   showLoading = false;
//                   loadSuccess = false;
//                 });
//               },
//             ),
//           ),
//         ],
//       );
//     } else {
//       result = _TextMailContent(data: widget.data);
//     }
//     return result;
//   }
// }

class _TextMailContent extends StatelessWidget {
  final UserMail data;

  const _TextMailContent({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final time = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          DateFormat('yyyy-MM-dd HH:mm:ss')
              .format(DateTime.parse(data.time).toLocal()),
          style: TextUtil.base.grey6267.sp(12),
        )
      ],
    );

    final content = Row(
      children: [
        Expanded(
          child: Markdown(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            data: data.content,
          ),
        ),
      ],
    );

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      blurRadius: 5,
                      color: ColorUtil.greyShadow64,
                      offset: Offset.zero,
                      spreadRadius: 3),
                ],
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
                color: WpyTheme.of(context)
                    .get(WpyThemeKeys.primaryBackgroundColor),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        data.title,
                        style: TextUtil.base.bold.sp(16),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  content,
                  SizedBox(height: 8),
                  time,
                ],
              ),
            ),
            if (data.url != '')
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '更多信息请点击链接查看喵~',
                      style: TextUtil.base.label(context).w500.NotoSansSC.sp(14),
                    ),
                    WButton(
                      child: Text(
                        '阅读原文',
                        style: TextUtil.base.textButtonPrimary(context).w400.NotoSansSC
                            .sp(14),
                      ),
                      onPressed: () async {
                        var url = data.url.startsWith('http')
                            ? data.url
                            : 'https://${data.url}';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return LakeDialogWidget(
                                    title: '同学你好：',
                                    titleTextStyle: TextUtil
                                        .base.normal.label(context).NotoSansSC
                                        .sp(26)
                                        .w600,
                                    content: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(' 你即将离开微北洋，去往：'),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 6),
                                          child: Text(url,
                                              style: url.startsWith(
                                                          'https://b23.tv/') ||
                                                      url.startsWith(
                                                          'https://www.bilibili.com/')
                                                  ? TextUtil.base.biliPink.w600
                                                      .h(1.6)
                                                  : TextUtil.base.label(context).w600
                                                      .h(1.6)),
                                        ),
                                        SimpleUrlPreview(
                                          url: url,
                                          bgColor: WpyTheme.of(context).get(
                                              WpyThemeKeys
                                                  .primaryBackgroundColor),
                                          titleLines: 2,
                                          imageLoaderColor:
                                              ColorUtil.iconAnimationStartColor,
                                          previewHeight: 130,
                                          previewContainerPadding:
                                              EdgeInsets.symmetric(
                                                  vertical: 10),
                                          onTap: () async {
                                            await launchUrl(Uri.parse(url));
                                            Navigator.pop(context);
                                          },
                                          titleStyle: url.startsWith(
                                                      'https://b23.tv/') ||
                                                  url.startsWith(
                                                      'https://www.bilibili.com/')
                                              ? TextUtil.base.biliPink.w600
                                                  .h(1.6)
                                                  .sp(14)
                                              : TextUtil.base.label(context).w600
                                                  .h(1.6)
                                                  .sp(24),
                                          siteNameStyle: TextUtil.base
                                              .sp(12)
                                              .customColor(Theme.of(context)
                                                  .primaryColor),
                                        ),
                                      ],
                                    ),
                                    cancelText: "取消",
                                    confirmTextStyle: TextUtil.base.normal
                                        .reverse(context)
                                        .NotoSansSC
                                        .sp(16)
                                        .w600,
                                    confirmButtonColor:
                                        url.startsWith('https://b23.tv/') ||
                                                url.startsWith(
                                                    'https://www.bilibili.com/')
                                            ? ColorUtil.biliPink
                                            : WpyTheme.of(context).get(WpyThemeKeys.primaryActionColor),
                                    cancelTextStyle: TextUtil.base.normal
                                        .primary(context)
                                        .NotoSansSC
                                        .sp(16)
                                        .w400,
                                    confirmText: "继续",
                                    cancelFun: () {
                                      Navigator.pop(context);
                                    },
                                    confirmFun: () async {
                                      await launchUrl(Uri.parse(url));
                                      Navigator.pop(context);
                                    });
                              });
                        } else {
                          ToastProvider.error('请检查网址是否有误或检查网络状态');
                        }
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:linkfy_text/linkfy_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';

class LinkText extends StatefulWidget {
  final TextStyle style;
  final String text;
  final int maxLine;

  @override
  _LinkTextState createState() => _LinkTextState();

  LinkText({required this.style, required this.text, this.maxLine = 100});
}

class _LinkTextState extends State<LinkText> {
  bool checkBili(String url) {
    return url.contains('b23.tv') || url.contains('bilibili.com');
  }

  @override
  Widget build(BuildContext context) {
    return LinkifyText(
      widget.text,
      maxLines: widget.maxLine,
      linkTypes: [LinkType.url, LinkType.hashTag],
      overflow: TextOverflow.ellipsis,
      textStyle: widget.style.NotoSansSC.w400.sp(16),
      linkStyle: widget.style.link(context).w500.sp(16),
      onTap: (link) async {
        // 粗暴地解决了，但是肯定不是个长久之计
        if (link.value!.startsWith('#MP') &&
            RegExp(r'^-?[0-9]+').hasMatch(link.value!.substring(3))) {
          checkPostId(link.value!.substring(3));
          //TODO:新换的依赖会把链接判断成phone，但是国际格式手机号暂时用不到先这么糊上去罢
        } else if (link.type == LinkType.url||link.type==LinkType.phone) {
          var url = link.value!.startsWith('http')
              ? link.value!
              : 'https://${link.value}';
          checkUrl(url);
        } else {
          ToastProvider.error('无效的帖子编号！');
        }
      },
    );
  }

  checkPostId(String id) {
    FeedbackService.getPostById(
      id: int.parse(id),
      onResult: (post) {
        Navigator.pushNamed(
          context,
          FeedbackRouter.detail,
          arguments: post,
        );
      },
      onFailure: (e) {
        ToastProvider.error('无法找到对应帖子，报错信息：${e.error}');
        return;
      },
    );
  }

  checkUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return LakeDialogWidget(
                title: '天外天工作室提示您',
                titleTextStyle: TextUtil.base.normal
                    .infoText(context)
                    .NotoSansSC
                    .sp(22)
                    .w600,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ' 你即将离开微北洋，去往：',
                      style: TextStyle(
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.basicTextColor)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6, bottom: 6),
                      child: Text(url,
                          style: checkBili(url)
                              ? TextUtil.base.NotoSansSC
                                  .biliPink(context)
                                  .w600
                                  .h(1.6)
                              : TextUtil.base.NotoSansSC
                                  .link(context)
                                  .w600
                                  .h(1.6)),
                    ),
                    Text(
                      ' 请注意您的账号和财产安全\n',
                      style: TextStyle(
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.basicTextColor)),
                    ),
                  ],
                ),
                cancelText: "取消",
                confirmTextStyle:
                    TextUtil.base.normal.bright(context).NotoSansSC.sp(16).w600,
                confirmButtonColor: checkBili(url)
                    ? WpyTheme.of(context).get(WpyColorKey.biliPink)
                    : WpyTheme.of(context)
                        .get(WpyColorKey.primaryTextButtonColor),
                cancelTextStyle:
                    TextUtil.base.normal.label(context).NotoSansSC.sp(16).w400,
                confirmText: "继续",
                cancelFun: () {
                  Navigator.pop(context);
                },
                confirmFun: () async {
                  await launchUrl(Uri.parse(url),
                      mode: checkBili(url)
                          ? LaunchMode.externalNonBrowserApplication
                          : LaunchMode.externalApplication);
                  Navigator.pop(context);
                });
          });
    } else {
      ToastProvider.error('请检查网址是否有误或检查网络状态');
    }
  }
}

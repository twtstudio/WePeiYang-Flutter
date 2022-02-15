import 'package:flutter/material.dart';
import 'package:linkfy_text/linkfy_text.dart';
import 'package:simple_url_preview/simple_url_preview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';

import '../feedback_router.dart';

class LinkText extends StatefulWidget {
  final TextStyle style;
  final String text;
  final int maxLine;

  @override
  _LinkTextState createState() => _LinkTextState();

  LinkText({this.style, this.text, this.maxLine});
}

class _LinkTextState extends State<LinkText> {
  @override
  Widget build(BuildContext context) {
    return LinkifyText(widget.text ?? '',
        maxLines: widget.maxLine ?? 100,
        linkTypes: [LinkType.url, LinkType.hashTag],
        overflow: TextOverflow.ellipsis,
        textStyle: widget.style,
        linkStyle: widget.style.linkBlue.w500, onTap: (link) async {
      if (link.type == LinkType.hashTag) {
        if (link.value.startsWith('#MP') &&
            RegExp(r'^-?[0-9]+').hasMatch(link.value.substring(3))) {
          FeedbackService.getPostById(
            id: int.parse(link.value.substring(3)),
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
        } else
          ToastProvider.error('无效的帖子编号！');
      } else {
        //粗暴地解决了，但是肯定不是个长久之计
        var url = link.value.startsWith('http')
            ? link.value
            : 'https://${link.value}';
        if (await canLaunch(url)) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return DialogWidget(
                    title: '同学你好：',
                    content: Column(
                      children: [
                        Text('你即将离开微北洋，去往：\n$url'),
                        SimpleUrlPreview(
                          url: url,
                          bgColor: Colors.white,
                          titleLines: 2,
                          imageLoaderColor: Colors.black12,
                          previewHeight: 130,
                          previewContainerPadding: EdgeInsets.all(10),
                          onTap: () async {
                            await launch(url);
                          },
                          titleStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ColorUtil.mainColor,
                          ),
                          siteNameStyle: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Text('请注意您的账号和财产安全'),
                        SizedBox(height: 12)
                      ],
                    ),
                    cancelText: "取消",
                    confirmTextStyle:
                        TextUtil.base.normal.black2A.NotoSansSC.sp(16).w400,
                    cancelTextStyle:
                        TextUtil.base.normal.black2A.NotoSansSC.sp(16).w400,
                    confirmText: "继续",
                    cancelFun: () {
                      Navigator.pop(context);
                    },
                    confirmFun: () async {
                      await launch(url);
                    });
              });
        } else {
          ToastProvider.error('请检查网址是否有误或检查网络状态');
        }
      }
    });
  }
}

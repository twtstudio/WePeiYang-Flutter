import 'package:flutter/material.dart';
import 'package:linkfy_text/linkfy_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';

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
        if (link.value.startsWith('#MP'))
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
              ToastProvider.error(e.error.toString());
              return;
            },
          );
      } else {
        var url = link.value;
        launch(url).onError(
            (error, stackTrace) => ToastProvider.error('请检查网址是否有误或检查网络状态'));
      }
    });
  }
}

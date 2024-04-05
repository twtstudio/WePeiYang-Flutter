import 'package:flutter/material.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/linkify_text.dart';

import '../../../../commons/widgets/w_button.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle style;
  final bool expand;
  final bool buttonIsShown;
  final bool isHTML;
  final String replyTo;

  const ExpandableText(
      {Key? key,
      required this.text,
      required this.maxLines,
      required this.style,
      required this.expand,
      required this.buttonIsShown,
      required this.isHTML,
      this.replyTo = ''})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ExpandableTextState(text, maxLines, style, expand, buttonIsShown);
  }
}

class _ExpandableTextState extends State<ExpandableText> {
  final String text;
  final int maxLines;
  final TextStyle style;
  bool expand;

  /// 显示全文字样
  bool buttonIsShown;

  _ExpandableTextState(
      this.text, this.maxLines, this.style, this.expand, this.buttonIsShown);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, size) {
      final span = TextSpan(text: text, style: style);
      final tp = TextPainter(
          text: span, maxLines: maxLines, textDirection: TextDirection.ltr);
      tp.layout(maxWidth: size.maxWidth);
      if (tp.didExceedMaxLines) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (expand) ...[
              if (widget.isHTML)
                RichText(
                  text: HTML.toTextSpan(
                    context,
                    text,
                    defaultTextStyle: style,
                  ),
                )
              else
                LinkText(style: style, text: text)
            ] else ...[
              if (widget.isHTML)
                RichText(
                  overflow: TextOverflow.clip,
                  maxLines: maxLines,
                  text: HTML.toTextSpan(
                    context,
                    text,
                    defaultTextStyle: style,
                  ),
                )
              else
                LinkText(style: style, text: text, maxLine: maxLines)
            ],
            if (buttonIsShown)
              WButton(
                onPressed: () {
                  setState(() {
                    expand = !expand;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(expand ? '收起' : '全文',
                          style: TextUtil.base
                              .textButtonPrimary(context)
                              .w400
                              .NotoSansSC
                              .sp(16)),
                      SizedBox(width: 6),
                      if (!expand)
                        Text('共${text.length}字',
                            style: TextUtil.base
                                .infoText(context)
                                .w400
                                .NotoSansSC
                                .sp(15))
                    ],
                  ),
                ),
              ),
          ],
        );
      } else {
        return LinkText(style: style, text: text);
      }
    });
  }
}

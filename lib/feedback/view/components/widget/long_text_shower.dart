import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/linkify_text.dart';

class ExpandableText extends StatefulWidget {
  @required
  final String text;
  @required
  final int maxLines;
  @required
  final TextStyle style;
  @required
  final bool expand;
  @required
  final bool buttonIsShown;

  const ExpandableText(
      {Key key,
      this.text,
      this.maxLines,
      this.style,
      this.expand,
      this.buttonIsShown})
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
  bool buttonIsShown;

  _ExpandableTextState(
      this.text, this.maxLines, this.style, this.expand, this.buttonIsShown) {
    if (expand == null) expand = false;
    if (buttonIsShown == null) buttonIsShown = false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, size) {
      final span = TextSpan(text: text ?? '', style: style);
      final tp = TextPainter(
          text: span, maxLines: maxLines, textDirection: TextDirection.ltr);
      tp.layout(maxWidth: size.maxWidth);

      if (tp.didExceedMaxLines) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            expand
                ? LinkText(style: style, text: text ?? '')
                : LinkText(
                    style: style,
                    text: text ?? '',
                    maxLine: maxLines,
                  ),
            if (buttonIsShown)
              InkWell(
                onTap: () {
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
                          style: TextUtil.base.textButtonBlue.w400.NotoSansSC
                              .sp(16)),
                      SizedBox(width: 6),
                      if (!expand)
                        Text('共${text.length}字',
                            style: TextUtil.base.greyA8.w400.NotoSansSC.sp(15))
                    ],
                  ),
                ),
              ),
          ],
        );
      } else {
        return LinkText(style: style, text: text ?? '');
      }
    });
  }
}

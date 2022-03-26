import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:provider/provider.dart';

import '../../../feedback_router.dart';
import '../../search_result_page.dart';

class CommentIdentificationContainer extends StatelessWidget {
  final String text;
  final bool active;

  CommentIdentificationContainer(this.text, this.active);

  @override
  Widget build(BuildContext context) {
    return text == ''
        ? SizedBox()
        : Container(
            margin: EdgeInsets.only(left: 2, top: 1),
            padding: EdgeInsets.fromLTRB(4, 0.5, 4, 1.5),
            child: Text(this.text,
                style: TextUtil.base.NotoSansSC.w700.whiteFD.sp(8)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: active ? ColorUtil.mainColor : ColorUtil.grey97Color,
            ),
          );
  }
}

class MPWidget extends StatelessWidget {
  final String text;

  MPWidget(this.text);

  @override
  Widget build(BuildContext context) {
    return Text('#MP' + this.text,
        style: TextUtil.base.ProductSans.w400.mainColor.sp(12));
  }
}

class SolvedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/svg_pics/lake_butt_icons/solved_tag.svg',
      width: 60,
      fit: BoxFit.fitWidth,
    );
  }
}

class UnSolvedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/svg_pics/lake_butt_icons/solved_not_tag.svg',
      width: 60,
      fit: BoxFit.fitWidth,
    );
  }
}

class TagShowWidget extends StatelessWidget {
  final String tag;
  final double width;

  ///0 湖底 1 校务 2 分区
  final int type;
  final int id;
  final int tar;
  final int lakeType;

  TagShowWidget(this.tag, this.width, this.type, this.id, this.tar, this.lakeType);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        id == -1
            ? Navigator.pushNamed(
                context,
                FeedbackRouter.searchResult,
                arguments: SearchResultPageArgs('$tag', '', '', '模糊搜索#$tag', 2, 0),
              )
            : type == 0
                ? {
                    Navigator.pushNamed(
                      context,
                      FeedbackRouter.searchResult,
                      arguments: SearchResultPageArgs(
                        '',
                        '',
                        '',
                        '$tag 分区详情',
                        tar, 0
                      ),
                    )
                  }
                : type == 1
                    ? Navigator.pushNamed(
                        context,
                        FeedbackRouter.searchResult,
                        arguments:
                            SearchResultPageArgs('', '', '$id', '部门 #$tag', 1, 0),
                      )
                    : Navigator.pushNamed(
                        context,
                        FeedbackRouter.searchResult,
                        arguments:
                            SearchResultPageArgs('', '$id', '', '标签 #$tag', 0, lakeType),
                      );
      },
      child: Container(
        height: 20,
        child: Row(
          children: [
            Container(
              height: 14,
              width: 14,
              alignment: Alignment.center,
              margin: EdgeInsets.fromLTRB(3, 3, 2, 3),
              padding: EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: type == 0
                    ? Color(0xffeaeaea)
                    : type == 1
                        ? ColorUtil.mainColor
                        : Colors.white,
              ),
              child: SvgPicture.asset(
                type == 0
                    ? "assets/svg_pics/lake_butt_icons/districts.svg"
                    : type == 1
                        ? "assets/svg_pics/lake_butt_icons/flag.svg"
                        : "assets/svg_pics/lake_butt_icons/hashtag.svg",
              ),
            ),
            SizedBox(width: type == 0 ? 0 : 2),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: width - 30),
              child: Text(
                tag,
                style: TextUtil.base.NotoSansSC.w400.sp(14).grey6C,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8)
          ],
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1080),
          color: Color(0xffeaeaea),
        ),
      ),
    );
  }
}

class TextPod extends StatelessWidget {
  final String text;

  TextPod(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white54,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black38)),
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
      child: Text(text, style: TextUtil.base.NotoSansSC.w400.sp(12).grey6C),
    );
  }
}

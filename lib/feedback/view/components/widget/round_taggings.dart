import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';

class CommentIdentificationContainer extends StatelessWidget {
  final String text;
  final bool active;

  CommentIdentificationContainer(this.text, this.active);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 2, top: 1),
      padding: EdgeInsets.fromLTRB(4, 0.5, 4, 1.5),
      child:
          Text(this.text, style: TextUtil.base.NotoSansSC.w500.whiteFD.sp(8)),
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Text('#MP' + this.text,
          style: TextUtil.base.NotoSansSC.w700.whiteFD.sp(13)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1080),
        color: ColorUtil.mainColor,
      ),
    );
  }
}

class SolvedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/svg_pics/lake_butt_icons/solved_tag.svg',
    );
  }
}

class UnSolvedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
        'assets/svg_pics/lake_butt_icons/solved_not_tag.svg');
  }
}

class TagShowWidget extends StatelessWidget {
  final String tag;
  final double width;

  TagShowWidget(this.tag, this.width);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      child: Row(
        children: [
          Container(
            height: 16,
            width: 16,
            alignment: Alignment.center,
            margin: EdgeInsets.fromLTRB(2, 2, 4, 2),
            padding: EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: SvgPicture.asset(
              "assets/svg_pics/lake_butt_icons/hashtag.svg",
            ),
          ),
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

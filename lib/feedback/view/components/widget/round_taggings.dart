import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';

class CommentIdentificationContainer extends StatelessWidget {
  final String text;
  final bool active;
  CommentIdentificationContainer(this.text, this.active);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      margin: EdgeInsets.only(left: 3),
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(this.text, style: TextUtil.base.NotoSansSC.w500.whiteFD.sp(8)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
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
      height: 19,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text('#MP' + this.text, style: TextUtil.base.NotoSansSC.w700.whiteFD.sp(13)),
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
    return Container(
      height: 19,
      child: Row(
        children: [
          Container(
            width: 15,
            margin: EdgeInsets.fromLTRB(2, 2, 5, 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1080),
              color: ColorUtil.backgroundColor,
            ),
            child: Center(
                child: Icon(
              Icons.done_outline,
              size: 12,
              color: ColorUtil.mainColor,
            )),
          ),
          Text("已解决", style: TextUtil.base.NotoSansSC.w700.whiteFD.sp(14)),
          SizedBox(width: 6)
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1080),
        color: ColorUtil.mainColor,
      ),
    );
  }
}

class UnSolvedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 19,
      child: Row(
        children: [
          Container(
            width: 15,
            margin: EdgeInsets.fromLTRB(2, 2, 5, 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1080),
              color: ColorUtil.backgroundColor,
            ),
            child: Center(
                child: Text(
              "!",
              style: FontManager.YaHeiRegular.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: ColorUtil.mainColor,
                height: 1.4,
              ),
            )),
          ),
          Text("未解决", style: TextUtil.base.NotoSansSC.w700.whiteFD.sp(14)),
          SizedBox(width: 6)
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1080),
        color: ColorUtil.mainColor,
      ),
    );
  }
}

class TagShowWidget extends StatelessWidget {
  final String tag;

  TagShowWidget(this.tag);

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
            margin: EdgeInsets.fromLTRB(2, 2, 5, 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1080),
              color: Colors.white,
            ),
            child: Text(
              "#",
              style: TextUtil.base.NotoSansSC.w900
                  .customColor(Color(0xFF363C54))
                  .sp(12),
            ),
          ),
          Text(
            tag,
            style: TextUtil.base.NotoSansSC.w400.sp(14).grey6C,
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

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';

class SolvedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      height: 19,
      child: Row(
        children: [
          Container(
            height: 15,
            width: 15,
            margin: EdgeInsets.only(right: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1080),
              color: ColorUtil.backgroundColor,
            ),
            child: Center(
                child: Icon(
              Icons.done_all,
              size: 12,
              color: ColorUtil.mainColor,
            )),
          ),
          Text(
            "已解决",
            style: FontManager.YaHeiRegular.copyWith(
              fontSize: 13,
              color: Colors.white,
              height: 1.4,
            ),
          ),
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
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      height: 19,
      child: Row(
        children: [
          Container(
            height: 15,
            width: 15,
            margin: EdgeInsets.only(right: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1080),
              color: ColorUtil.backgroundColor,
            ),
            child: Center(
                child: Text(
              "!",
              style: FontManager.YaHeiRegular.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ColorUtil.mainColor,
                height: 1.4,
              ),
            )),
          ),
          Text(
            "未解决",
            style: FontManager.YaHeiRegular.copyWith(
              fontSize: 13,
              color: Colors.white,
              height: 1.4,
            ),
          ),
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
      padding: EdgeInsets.fromLTRB(2, 0, 2, 2),
      height: 15,
      child: Row(
        children: [
          Container(
            height: 10,
            width: 10,
            alignment: Alignment.center,
            margin: EdgeInsets.fromLTRB(0, 2, 4, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1080),
              color: Colors.white,
            ),
            child: Text(
              "#",
              style: TextUtil.base.NotoSansSC.regular
              .customColor(Color(0xFF363C54))
              .sp(6.7),
            ),
          ),
          Text(
            tag,
            style: TextUtil.base.NotoSansSC.regular.sp(10).grey6C,
          ),
          SizedBox(width: 4)
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1080),
        color: ColorUtil.searchBarBackgroundColor,
      ),
    );
  }
}

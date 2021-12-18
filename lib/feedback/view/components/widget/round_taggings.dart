import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

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
            S.current.feedback_solved,
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
            S.current.feedback_unsolved,
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
              color: Colors.white,
            ),
            child: Center(
                child: Text(
              "#",
              style: FontManager.YaHeiRegular.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ColorUtil.mainColor,
                height: 1.4,
              ),
            )),
          ),
          Text(
            tag,
            style: FontManager.YaHeiRegular.copyWith(
              fontSize: 13,
              color: ColorUtil.boldTextColor,
              height: 1.4,
            ),
          ),
          SizedBox(width: 6)
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1080),
        color: ColorUtil.searchBarBackgroundColor,
      ),
    );
  }
}

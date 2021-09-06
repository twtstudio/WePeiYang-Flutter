import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/feedback/model/comment.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/official_logo.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:simple_html_css/simple_html_css.dart';

import 'blank_space.dart';

// ignore: must_be_immutable
class CommentCard extends StatefulWidget {
  Comment comment;
  bool official;
  bool detail;
  String title;
  void Function() onContentPressed = () {};
  void Function() onLikePressed = () {};

  @override
  _CommentCardState createState() => _CommentCardState(
      comment, official, detail, onContentPressed, title, onLikePressed);

  CommentCard(comment,
      {void Function() onContentPressed, void Function() onLikePressed}) {
    this.comment = comment;
    this.official = false;
    this.detail = false;
    this.onContentPressed = onContentPressed;
    this.onLikePressed = onLikePressed;
  }

  CommentCard.official(comment,
      {void Function() onContentPressed, void Function() onLikePressed}) {
    this.comment = comment;
    this.official = true;
    this.detail = false;
    this.onContentPressed = onContentPressed;
    this.onLikePressed = onLikePressed;
  }

  CommentCard.detail(comment,
      {@required title,
        void Function() onContentPressed,
        void Function() onLikePressed}) {
    this.comment = comment;
    this.official = true;
    this.detail = true;
    this.title = title;
    this.onContentPressed = onContentPressed;
    this.onLikePressed = onLikePressed;
  }
}

class _CommentCardState extends State<CommentCard> {
  final Comment comment;
  final bool official;
  final bool detail;
  final String title;
  final void Function() onContentPressed;
  final void Function() onLikePressed;

  _CommentCardState(this.comment, this.official, this.detail,
      this.onContentPressed, this.title, this.onLikePressed);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: FontManager.YaHeiRegular,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlankSpace.height(8),
            if (detail)
              Text(
                title,
                style: FontManager.YaHeiRegular.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: ColorUtil.boldTextColor,
                ),
              ),
            if (detail) BlankSpace.height(8),
            if (detail)
              Divider(
                height: 0.6,
                color: Color(0xffacaeba),
              ),
            if (detail) BlankSpace.height(8),
            Row(
              children: [
                if (official)
                  OfficialLogo()
                else
                  Icon(Icons.account_circle_rounded,
                      size: 25, color: Color.fromRGBO(98, 103, 124, 1.0)),
                if (!official) BlankSpace.width(5),
                if (!official)
                  Expanded(
                    child: Text(
                      comment.userName ?? S.current.feedback_anonymous,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: FontManager.YaHeiRegular.copyWith(
                          fontSize: 14, color: ColorUtil.lightTextColor),
                    ),
                  ),
                Spacer(),
                Text(
                  comment.createTime.substring(0, 10) +
                      '  ' +
                      (comment.createTime
                          .substring(11)
                          .split('.')[0]
                          .startsWith('0')
                          ? comment.createTime
                          .substring(12)
                          .split('.')[0]
                          .substring(0, 4)
                          : comment.createTime
                          .substring(11)
                          .split('.')[0]
                          .substring(0, 5)),
                  style: FontManager.YaHeiRegular.copyWith(
                    fontSize: 12,
                    color: ColorUtil.lightTextColor,
                  ),
                ),
              ],
            ),
            BlankSpace.height(16),
            if (official && !detail)
              GestureDetector(
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  text: HTML.toTextSpan(context, comment.content,
                      defaultTextStyle: FontManager.YaHeiRegular.copyWith(
                        color: ColorUtil.boldTextColor,
                      )),
                ),
                onTap: onContentPressed,
              )
            else if (official && detail)
              Html(
                data: comment.content,
              )
            else
              Text(
                comment.content,
                style: FontManager.YaHeiRegular.copyWith(
                  color: ColorUtil.boldTextColor,
                ),
              ),
            Row(
              children: [
                if (official && comment.rating == -1)
                  Text(
                    S.current.feedback_no_rating,
                    style: FontManager.YaHeiRegular.copyWith(
                      fontSize: 12,
                      color: ColorUtil.lightTextColor,
                    ),
                  ),
                if (official && comment.rating != -1)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        S.current.feedback_rating,
                        style: FontManager.YaHeiRegular.copyWith(
                          fontSize: 12,
                          color: ColorUtil.lightTextColor,
                        ),
                      ),
                      RatingBar.builder(
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: ColorUtil.mainColor,
                        ),
                        allowHalfRating: true,
                        glow: false,
                        initialRating: (comment.rating.toDouble() / 2),
                        itemCount: 5,
                        itemSize: 16,
                        ignoreGestures: true,
                        unratedColor: ColorUtil.lightTextColor,
                        onRatingUpdate: (_) {},
                      ),
                    ],
                  ),
                Spacer(),
                // Like count.
                // TODO: Replace this with [GestureDetector]
                ButtonTheme(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 6.0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minWidth: 0,
                  child: GestureDetector(
                    onTap: onLikePressed,
                    child: Row(
                      children: [
                        Icon(
                          !comment.isLiked
                              ? Icons.thumb_up_outlined
                              : Icons.thumb_up,
                          size: 16,
                          color: !comment.isLiked
                              ? ColorUtil.lightTextColor
                              : Colors.red,
                        ),
                        Container(width: 5),
                        Text(
                          comment.likeCount.toString(),
                          style: FontManager.YaHeiRegular.copyWith(
                              fontSize: 14, color: ColorUtil.lightTextColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                blurRadius: 5,
                color: Color.fromARGB(64, 236, 237, 239),
                offset: Offset(0, 0),
                spreadRadius: 3),
          ],
        ),
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      ),
    );
  }
}


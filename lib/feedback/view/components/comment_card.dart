import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:like_button/like_button.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/feedback/model/comment.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/official_logo.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

// ignore: must_be_immutable
class CommentCard extends StatefulWidget {
  Comment comment;
  bool official;
  bool detail;
  int commentFloor;
  String title;
  void Function() onContentPressed = () {};
  void Function() onLikePressed = () {};

  @override
  _CommentCardState createState() => _CommentCardState(
      comment, official, detail, onContentPressed, title, onLikePressed);

  CommentCard(this.comment, this.commentFloor,
      {void Function() onContentPressed, void Function() onLikePressed}) {
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
      child: GestureDetector(
        onLongPress: () {
          ClipboardData data = new ClipboardData(text: comment.content);
          Clipboard.setData(data);
          ToastProvider.success('复制评论成功');
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 8, 2, 8),
          margin: EdgeInsets.symmetric(vertical: 9, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              if (detail)
                Text(
                  title,
                  style: FontManager.YaHeiRegular.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: ColorUtil.boldTextColor,
                  ),
                ),
              if (detail) SizedBox(height: 8),
              if (detail)
                Divider(
                  height: 0.6,
                  color: Color(0xffacaeba),
                ),
              if (detail) SizedBox(height: 8),
              Row(
                children: [
                  if (official)
                    OfficialLogo()
                  else
                    Icon(Icons.account_circle_rounded,
                        size: 20, color: Color.fromRGBO(98, 103, 124, 1.0)),
                  if (!official) SizedBox(height: 8),
                  if (!official)
                    Expanded(
                      child: Text(
                        comment.userName ?? S.current.feedback_anonymous,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: FontManager.YaHeiRegular.copyWith(
                            fontSize: 12, color: ColorUtil.lightTextColor),
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
                  SizedBox(width: 18)
                ],
              ),
              SizedBox(height: 16),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...bottomLeadingWidget,
                  Spacer(),
                  SizedBox(
                    height: 40,
                    child: LikeButton(
                      likeBuilder: (bool isLiked) {
                        if (comment.isLiked) {
                          return Icon(
                            Icons.thumb_up,
                            size: 16,
                            color: Colors.redAccent,
                          );
                        } else {
                          return Icon(
                            Icons.thumb_up_outlined,
                            size: 16,
                            color: ColorUtil.lightTextColor,
                          );
                        }
                      },
                      onTap: (value) async {
                        Future.delayed(Duration(seconds: 4));
                        onLikePressed();
                        return !value;
                      },
                      circleColor: CircleColor(
                          start: Colors.black12, end: Colors.redAccent),
                      bubblesColor: BubblesColor(
                        dotPrimaryColor: Colors.redAccent,
                        dotSecondaryColor: Colors.pinkAccent,
                      ),
                      animationDuration: Duration(milliseconds: 600),
                      padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    width: 30,
                    child: Text(
                      comment.likeCount.toString(),
                      style: FontManager.YaHeiRegular.copyWith(
                          fontSize: 14, color: ColorUtil.lightTextColor),
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
        ),
      ),
    );
  }

  List<Widget> get bottomLeadingWidget {
    if (official && comment.rating == -1)
      return [
        Text(
          S.current.feedback_no_rating,
          style: FontManager.YaHeiRegular.copyWith(
            fontSize: 12,
            color: ColorUtil.lightTextColor,
          ),
        )
      ];
    else if (official && comment.rating != -1)
      return [
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
      ];
    else
      return [
        Text(
          '${widget.commentFloor}' + '楼 ',
          style: FontManager.YaHeiRegular.copyWith(
            fontSize: 12,
            color: ColorUtil.lightTextColor,
          ),
        )
      ];
  }
}

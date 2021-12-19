import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/comment.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/clip_copy.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/like_widget.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

typedef LikeCallback = void Function(bool, int);

class NCommentCard extends StatefulWidget {
  final Comment comment;
  final int commentFloor;
  final LikeCallback likeSuccessCallback;

  @override
  _NCommentCardState createState() => _NCommentCardState();

  NCommentCard({this.comment, this.commentFloor, this.likeSuccessCallback});
}

class _NCommentCardState extends State<NCommentCard> {
  @override
  Widget build(BuildContext context) {
    var box = SizedBox(height: 8);

    var topWidget = Row(
      children: [
        Icon(Icons.account_circle_rounded,
            size: 34, color: Color.fromRGBO(98, 103, 124, 1.0)),
        SizedBox(height: 8),
       Expanded(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.comment.userName ?? S.current.feedback_anonymous,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: FontManager.YaHeiRegular.copyWith(
                  fontSize: 14, color: ColorUtil.lightTextColor),
            ),
            Text(
              widget.comment.createTime.time,
              style: FontManager.YaHeiRegular.copyWith(
                fontSize: 10,
                color: ColorUtil.lightTextColor,
              ),
            ),
          ],
        ),),
        IconButton(
          icon: Icon(Icons.more_horiz),
          iconSize: 16,
          onPressed: () {},
          constraints: BoxConstraints(),
          padding: EdgeInsets.fromLTRB(0, 0, 12, 0),
        )
      ],
    );

    var commentContent = Text(
      widget.comment.content,
      style: FontManager.YaHeiRegular.copyWith(
        color: ColorUtil.boldTextColor,
      ),
    );

    var floor = IconButton(
      icon: Icon(Icons.chat),
      iconSize: 16,
      constraints: BoxConstraints(),
      onPressed: (){},
      padding: EdgeInsets.fromLTRB(0, 0, 12, 0),
      color: ColorUtil.boldLakeTextColor,
    );

    var likeWidget = LikeWidget(
      count: widget.comment.likeCount,
      onLikePressed: (isLiked, count, success, failure) async {
        await FeedbackService.commentHitLike(
          id: widget.comment.id,
          isLiked: widget.comment.isLiked,
          onSuccess: () {
            widget.likeSuccessCallback?.call(!isLiked, count);
            success.call();
          },
          onFailure: (e) {
            ToastProvider.error(e.error.toString());
            failure.call();
          },
        );
      },
      isLiked: widget.comment.isLiked
    );

    var bottomWidget = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [likeWidget, floor],
    );

    var body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        box,
        topWidget,
        box,
        box,
        commentContent,
        bottomWidget,
      ],
    );

    return DefaultTextStyle(
      style: FontManager.YaHeiRegular,
      child: ClipCopy(
        copy: widget.comment.content,
        toast: '复制评论成功',
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 8, 15, 8),
          margin: EdgeInsets.symmetric(vertical: 9, horizontal: 20),
          child: body,
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
}

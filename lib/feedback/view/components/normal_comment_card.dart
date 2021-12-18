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
            size: 20, color: Color.fromRGBO(98, 103, 124, 1.0)),
        SizedBox(height: 8),
        Expanded(
          child: Text(
            widget.comment.userName ?? S.current.feedback_anonymous,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: FontManager.YaHeiRegular.copyWith(
                fontSize: 12, color: ColorUtil.lightTextColor),
          ),
        ),
        Spacer(),
        Text(
          widget.comment.createTime.time,
          style: FontManager.YaHeiRegular.copyWith(
            fontSize: 12,
            color: ColorUtil.lightTextColor,
          ),
        ),
      ],
    );

    var commentContent = Text(
      widget.comment.content,
      style: FontManager.YaHeiRegular.copyWith(
        color: ColorUtil.boldTextColor,
      ),
    );

    var floor = Text(
      '${widget.commentFloor}' + '楼 ',
      style: FontManager.YaHeiRegular.copyWith(
        fontSize: 12,
        color: ColorUtil.lightTextColor,
      ),
    );

    var likeWidget = LikeWidget(
      count: widget.comment.likeCount,
      onLikePressed: (isLiked, count,success,failure) async {
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
      children: [floor, likeWidget],
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

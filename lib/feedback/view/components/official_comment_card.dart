import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/comment.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/clip_copy.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/like_widget.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/official_logo.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

enum Official { detail, reply }

typedef LikeCallback = void Function(bool, int);
typedef ContentPressedCallback = void Function(void Function(Comment));

class OfficialReplyCard extends StatefulWidget {
  final Comment comment;
  final String title;
  final Official type;
  final ContentPressedCallback onContentPressed;
  final LikeCallback onLikePressed;

  OfficialReplyCard.detail({
    this.comment,
    this.title,
    this.onLikePressed,
  })  : type = Official.detail,
        onContentPressed = null;

  OfficialReplyCard.reply({
    this.comment,
    this.title,
    this.onContentPressed,
    this.onLikePressed,
  }) : type = Official.reply;

  @override
  _OfficialReplyCardState createState() => _OfficialReplyCardState();
}

class _OfficialReplyCardState extends State<OfficialReplyCard> {
  @override
  Widget build(BuildContext context) {
    List<Widget> column = [];

    var box = SizedBox(height: 8);

    var createTime = Row(
      children: [
        OfficialLogo(),
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

    var likeWidget = LikeWidget(
      count: widget.comment.likeCount,
      onLikePressed: (isLiked, count, success, failure) async {
        await FeedbackService.officialCommentHitLike(
          id: widget.comment.id,
          isLiked: widget.comment.isLiked,
          onSuccess: () {
            widget.onLikePressed?.call(!isLiked, count);
            success.call();
          },
          onFailure: (e) {
            ToastProvider.error(e.error.toString());
            failure.call();
          },
        );
        return true;
      },
      isLiked: widget.comment.isLiked,
    );

    Widget starWidget;
    if (widget.comment.rating == -1) {
      starWidget = Text(
        S.current.feedback_no_rating,
        style: FontManager.YaHeiRegular.copyWith(
          fontSize: 12,
          color: ColorUtil.lightTextColor,
        ),
      );
    } else {
      starWidget = Row(children: [
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
          initialRating: (widget.comment.rating.toDouble() / 2),
          itemCount: 5,
          itemSize: 16,
          ignoreGestures: true,
          unratedColor: ColorUtil.lightTextColor,
          onRatingUpdate: (_) {},
        ),
      ]);
    }

    var bottomWidget = Row(
      children: [starWidget, Spacer(), likeWidget],
    );

    switch (widget.type) {
      case Official.detail:
        var title = Text(
          widget.title,
          style: FontManager.YaHeiRegular.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: ColorUtil.boldTextColor,
          ),
        );
        var divider = Divider(
          height: 0.6,
          color: Color(0xffacaeba),
        );

        var comment = Html(
          data: widget.comment.content,
        );

        column.addAll([
          box,
          title,
          box,
          divider,
          box,
          createTime,
          box,
          box,
          comment,
          bottomWidget
        ]);

        break;
      case Official.reply:
        var comment = RichText(
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
          text: HTML.toTextSpan(
            context,
            widget.comment.content,
            defaultTextStyle: FontManager.YaHeiRegular.copyWith(
              color: ColorUtil.boldTextColor,
            ),
          ),
        );

        column.addAll([
          box,
          createTime,
          box,
          box,
          comment,
          bottomWidget,
        ]);

        break;
    }

    Widget list = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: column,
    );

    list = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: list,
    );

    var decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
            blurRadius: 5,
            color: Color.fromARGB(64, 236, 237, 239),
            offset: Offset(0, 0),
            spreadRadius: 3),
      ],
    );

    return DefaultTextStyle(
      style: FontManager.YaHeiRegular,
      child: InkWell(
        onTap: () {
          widget.onContentPressed?.call((comment) {
            setState(() {
              widget.comment.isLiked = comment.isLiked;
              widget.comment.likeCount = comment.likeCount;
              widget.comment.rating = comment.rating;
            });
          });
        },
        child: ClipCopy(
          copy: widget.comment.content,
          toast: '复制评论成功',
          child: Container(
            padding: EdgeInsets.fromLTRB(2, 8, 2, 8),
            margin: EdgeInsets.symmetric(vertical: 9, horizontal: 20),
            child: list,
            decoration: decoration,
          ),
        ),
      ),
    );
  }
}

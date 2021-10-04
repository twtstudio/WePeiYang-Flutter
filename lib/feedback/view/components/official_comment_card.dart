import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/comment.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/clip_copy.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/like_widget.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/official_logo.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

enum Official { detail, reply }

class OfficialReplyCard extends StatefulWidget {
  final Comment comment;
  final String title;
  final Official type;
  final VoidCallback onContentPressed;
  final VoidCallback onLikePressed;

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
        SizedBox(width: 18)
      ],
    );


    var likeWidget = LikeWidget(
      count: widget.comment.likeCount,
      onLikePressed: (boolNotifier) async {
        widget.onLikePressed?.call();
        FeedbackService.officialCommentHitLike(
          id: widget.comment.id,
          isLiked: widget.comment.isLiked,
          onSuccess: null,
          onFailure: (e) {
            boolNotifier.value = boolNotifier.value;
            ToastProvider.error(e.error.toString());
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
      children: [starWidget, likeWidget],
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
        var comment = GestureDetector(
          child: RichText(
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
            text: HTML.toTextSpan(context, widget.comment.content,
                defaultTextStyle: FontManager.YaHeiRegular.copyWith(
                  color: ColorUtil.boldTextColor,
                )),
          ),
          onTap: widget.onContentPressed,
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

    Column list = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: column,
    );

    return DefaultTextStyle(
      style: FontManager.YaHeiRegular,
      child: ClipCopy(
        copy: widget.comment.content,
        toast: '复制评论成功',
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 8, 2, 8),
          margin: EdgeInsets.symmetric(vertical: 9, horizontal: 20),
          child: list,
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

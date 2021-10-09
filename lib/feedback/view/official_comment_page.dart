import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/comment.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/official_comment_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/rating_card.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class OfficialCommentPageArgs {
  final Comment comment;
  final String title;
  final bool isOwner;

  OfficialCommentPageArgs({this.comment, this.title, this.isOwner});
}

class OfficialCommentPage extends StatefulWidget {
  final Comment comment;
  final String title;
  final bool isOwner;

  OfficialCommentPage(OfficialCommentPageArgs args)
      : comment = args.comment,
        title = args.title,
        isOwner = args.isOwner;

  @override
  _OfficialCommentPageState createState() => _OfficialCommentPageState();
}

class _OfficialCommentPageState extends State<OfficialCommentPage> {

  @override
  Widget build(BuildContext context) {
    var appbar = AppBar(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: ColorUtil.mainColor),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        S.current.feedback_comment_detail,
        style: FontManager.YaHeiRegular.copyWith(
            fontWeight: FontWeight.bold, color: ColorUtil.boldTextColor),
      ),
      centerTitle: true,
      elevation: 0,
    );

    List<Widget> list = [];

    list.add(
      OfficialReplyCard.detail(
        comment: widget.comment,
        title: widget.title,
        onLikePressed: (isLike, likeCount) {
          widget.comment.isLiked = isLike;
          widget.comment.likeCount = likeCount;
        },
      ),
    );

    if (widget.isOwner){
      var ratingCard = RatingCard(
        initialRating:
        widget.comment.rating == -1 ? 5 : widget.comment.rating,
        onRatingChanged: (rating) {
          FeedbackService.rate(
            id: widget.comment.id,
            rating: rating * 2,
            onSuccess: () {
              ToastProvider.success(S.current.feedback_rating_success);
              setState(() {
                widget.comment.rating = (rating * 2).toInt();
              });
            },
            onFailure: (e) => ToastProvider.error(e.error.toString()),
          );
        },
      );

      list.add(ratingCard);
    }

    var body = ListView(
      children: list,
    );

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop<Comment>(context, widget.comment);
        return false;
      },
      child: Scaffold(
        appBar: appbar,
        body: body,
      ),
    );
  }
}

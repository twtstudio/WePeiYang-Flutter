import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/comment.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/comment_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/rating_card.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class OfficialCommentPageArgs {
  // TODO: Actually it is not necessary to pass the param 'comment', cuz the comment can be accessed using 'index' and notifier.(ﾟ∀。 )
  final Comment comment;
  final String title;
  final int index;
  final bool isOwner;

  OfficialCommentPageArgs(this.comment, this.title, this.index, this.isOwner);
}

class OfficialCommentPage extends StatefulWidget {
  final Comment comment;
  final String title;
  final int index;
  final bool isOwner;

  OfficialCommentPage(OfficialCommentPageArgs args)
      : comment = args.comment,
        title = args.title,
        index = args.index,
        isOwner = args.isOwner;

  @override
  _OfficialCommentPageState createState() => _OfficialCommentPageState();
}

class _OfficialCommentPageState extends State<OfficialCommentPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop<Comment>(context, widget.comment);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
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
        ),
        body: ListView(
          children: [
            CommentCard.detail(
              widget.comment,
              title: widget.title,
              onLikePressed: () {
                FeedbackService.officialCommentHitLike(
                  id: widget.comment.id,
                  isLiked: widget.comment.isLiked,
                  onSuccess: () {
                    setState(() => widget.comment.changeLikeStatus());
                  },
                  onFailure: (e) => ToastProvider.error(e.error.toString()),
                );
              },
            ),
            if (widget.isOwner)
              RatingCard(
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
              ),
          ],
        ),
      ),
    );
  }
}

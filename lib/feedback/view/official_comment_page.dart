import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/comment.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/http_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/comment_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/rating_card.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class OfficialCommentPage extends StatefulWidget {
  final OfficialCommentPageArgs args;

  const OfficialCommentPage(this.args);

  @override
  _OfficialCommentPageState createState() => _OfficialCommentPageState(
      args.comment, args.title, args.index, args.isOwner);
}

class OfficialCommentPageArgs {
  // TODO: Actually it is not necessary to pass the param 'comment', cuz the comment can be accessed using 'index' and notifier.(ﾟ∀。 )
  final Comment comment;
  final String title;
  final int index;
  final bool isOwner;

  OfficialCommentPageArgs(this.comment, this.title, this.index, this.isOwner);
}

class _OfficialCommentPageState extends State<OfficialCommentPage> {
  final Comment comment;
  final String title;
  final int index;
  final bool isOwner;

  _OfficialCommentPageState(this.comment, this.title, this.index, this.isOwner);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FeedbackNotifier>(
        builder: (context, notifier, widget) {
          return DefaultTextStyle(
            style: FontManager.YaHeiRegular,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Color.fromARGB(255, 255, 255, 255),
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: ColorUtil.mainColor,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  title: Text(
                    S.current.feedback_comment_detail,
                    style: FontManager.YaHeiRegular.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ColorUtil.boldTextColor,
                    ),
                  ),
                  centerTitle: true,
                  floating: true,
                  elevation: 0,
                ),
                SliverToBoxAdapter(
                  child: CommentCard.detail(
                    comment,
                    title: title,
                    onLikePressed: () {
                      officialCommentHitLike(
                        id: notifier.officialCommentList[index].id,
                        isLiked: notifier.officialCommentList[index].isLiked,
                        onSuccess: () {
                          notifier.changeOfficialCommentLikeState(index);
                        },
                        onFailure: () {
                          ToastProvider.error(S.current.feedback_like_error);
                        },
                      );
                    },
                  ),
                ),
                if (isOwner)
                  SliverToBoxAdapter(
                    child: RatingCard(
                      initialRating: comment.rating == -1 ? 5 : comment.rating,
                      onRatingChanged: (rating) {
                        rate(
                          id: comment.id,
                          rating: rating * 2,
                          onSuccess: () {
                            notifier.updateRating(rating, index);
                            ToastProvider.success(
                                S.current.feedback_rating_success);
                          },
                          onFailure: () {
                            ToastProvider.error(
                                S.current.feedback_rating_error);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

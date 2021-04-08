import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/feedback/model/comment.dart';
import 'package:wei_pei_yang_demo/feedback/model/feedback_notifier.dart';
import 'package:wei_pei_yang_demo/feedback/util/color_util.dart';
import 'package:wei_pei_yang_demo/feedback/util/http_util.dart';
import 'package:wei_pei_yang_demo/feedback/view/components/comment_card.dart';
import 'package:wei_pei_yang_demo/feedback/view/components/rating_card.dart';

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
          return CustomScrollView(
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
                  '回复详情',
                  style: TextStyle(
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
                        ToastProvider.error('校务专区点赞失败，请重试');
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
                          ToastProvider.success('评价成功');
                          },
                        onFailure: () {
                          ToastProvider.error('评价失败，请重试');
                        },
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

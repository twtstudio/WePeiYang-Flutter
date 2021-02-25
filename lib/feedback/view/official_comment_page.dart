import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/feedback/model/comment.dart';
import 'package:wei_pei_yang_demo/feedback/model/feedback_notifier.dart';
import 'package:wei_pei_yang_demo/feedback/util/color_util.dart';
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

  bool _ratingLock = false;

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
                    notifier.officialCommentHitLike(
                        index, comment.id, notifier.myUserId);
                  },
                ),
              ),
              if (isOwner)
                SliverToBoxAdapter(
                  child: RatingCard(
                    onRatingChanged: (rating) async {
                      if (!_ratingLock) {
                        _ratingLock = true;
                        await notifier
                            .rate(rating * 2, comment.id, notifier.myUserId,
                                index)
                            .then((value) {
                          notifier.updateRating(rating * 2, index);
                        }).whenComplete(() {
                          _ratingLock = false;
                        });
                      }
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

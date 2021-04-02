import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/feedback/model/feedback_notifier.dart';
import 'package:wei_pei_yang_demo/feedback/model/post.dart';
import 'package:wei_pei_yang_demo/feedback/util/color_util.dart';
import 'package:wei_pei_yang_demo/feedback/util/feedback_router.dart';
import 'package:wei_pei_yang_demo/feedback/view/components/comment_card.dart';
import 'package:wei_pei_yang_demo/feedback/view/official_comment_page.dart';
import 'package:wei_pei_yang_demo/lounge/ui/widget/loading.dart';

import 'components/post_card.dart';

class DetailPage extends StatefulWidget {
  final DetailPageArgs args;

  DetailPage(this.args);

  @override
  _DetailPageState createState() =>
      _DetailPageState(this.args.post, this.args.index, this.args.origin);
}

enum DetailPageStatus {
  loading,
  idle,
  error,
}

enum PostOrigin { home, profile, favorite, mailbox }

class DetailPageArgs {
  final Post post;
  final int index;
  final PostOrigin origin;

  DetailPageArgs(this.post, this.index, this.origin);
}

class _DetailPageState extends State<DetailPage> {
  Post post;
  final int index;
  final PostOrigin origin;

  bool _sendCommentLock = false;
  String _commentLengthIndicator;
  DetailPageStatus status;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  TextEditingController _textEditingController = TextEditingController();

  _DetailPageState(this.post, this.index, this.origin);

  _onRefresh() async {
    var model = Provider.of<FeedbackNotifier>(context, listen: false);
    model.clearCommentList();
    post = await model.getPostById(post.id);
    await model.getAllComments(
      post.id,
      () {
        status = DetailPageStatus.idle;
        setState(() {});
      },
    );
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    status = DetailPageStatus.loading;
    _commentLengthIndicator = '0/200';
    Provider.of<FeedbackNotifier>(context, listen: false).clearCommentList();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<FeedbackNotifier>(context, listen: false).initDetailPage(
        post.id,
        () {
          status = DetailPageStatus.idle;
          setState(() {});
        },
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, post.isFavorite);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: ColorUtil.mainColor,
            ),
            onPressed: () {
              Navigator.pop(context, post.isFavorite);
            },
          ),
          title: Text(
            '问题详情',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ColorUtil.boldTextColor,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          primary: true,
        ),
        body: Column(
          children: [
            if (status == DetailPageStatus.loading)
              Expanded(
                child: Center(
                  child: Loading(),
                ),
              ),
            if (status == DetailPageStatus.idle)
              Expanded(
                child: Consumer<FeedbackNotifier>(
                  builder: (context, notifier, widget) {
                    return SmartRefresher(
                      physics: BouncingScrollPhysics(),
                      controller: _refreshController,
                      header: ClassicHeader(),
                      enablePullDown: true,
                      onRefresh: _onRefresh,
                      enablePullUp: false,
                      child: CustomScrollView(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        slivers: [
                          SliverToBoxAdapter(
                            child: PostCard.detail(
                              post,
                              onLikePressed: () async {
                                if (origin == PostOrigin.home) {
                                  notifier.homePostHitLike(
                                      index, notifier.homePostList[index].id);
                                } else if (origin == PostOrigin.mailbox) {
                                  await notifier
                                      .messagePostHitLike(post.isLiked, post.id)
                                      .then((_) {
                                    if (post.isLiked) {
                                      post.likeCount--;
                                    } else {
                                      post.likeCount++;
                                    }
                                    post.isLiked = !post.isLiked;
                                    setState(() {});
                                  });
                                } else {
                                  notifier.profilePostHitLike(index,
                                      notifier.profilePostList[index].id);
                                }
                              },
                              onFavoritePressed: () {
                                if (origin == PostOrigin.home) {
                                  notifier.homePostHitFavorite(index);
                                } else if (origin == PostOrigin.mailbox) {
                                  notifier
                                      .messagePostHitFavorite(
                                          post.isFavorite, post.id)
                                      .then((_) {
                                    post.isFavorite = !post.isFavorite;
                                    setState(() {});
                                  });
                                } else {
                                  notifier.profilePostHitFavorite(index);
                                }
                              },
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                print('bbb');
                                return index <
                                        notifier.officialCommentList.length
                                    ? CommentCard.official(
                                        notifier.officialCommentList[index],
                                        onContentPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            FeedbackRouter.officialComment,
                                            arguments: OfficialCommentPageArgs(
                                              notifier
                                                  .officialCommentList[index],
                                              post.title,
                                              index,
                                              post.isOwner,
                                            ),
                                          );
                                        },
                                        onLikePressed: () {
                                          notifier.officialCommentHitLike(
                                            index,
                                            notifier
                                                .officialCommentList[index].id,
                                          );
                                        },
                                      )
                                    : CommentCard(
                                        notifier.commentList[index -
                                            notifier
                                                .officialCommentList.length],
                                        onLikePressed: () {
                                          notifier.commentHitLike(
                                            index -
                                                notifier
                                                    .officialCommentList.length,
                                            notifier
                                                .commentList[index -
                                                    notifier.officialCommentList
                                                        .length]
                                                .id,
                                          );
                                        },
                                      );
                              },
                              childCount: notifier.officialCommentList.length +
                                  notifier.commentList.length,
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 0),
                      child: TextField(
                        controller: _textEditingController,
                        maxLength: 200,
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '写评论…',
                          suffix: Text(
                            _commentLengthIndicator,
                            style: TextStyle(
                              fontSize: 14,
                              color: ColorUtil.lightTextColor,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(
                                AppBar().preferredSize.height / 2 - 4),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          fillColor: ColorUtil.searchBarBackgroundColor,
                          filled: true,
                          isDense: true,
                        ),
                        onChanged: (text) {
                          // TODO: This leads to repainting of whole detail page.
                          _commentLengthIndicator =
                              '${text.characters.length}/200';
                          setState(() {});
                        },
                        enabled: true,
                        minLines: 1,
                        maxLines: 3,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () async {
                      if (!_sendCommentLock) {
                        _sendCommentLock = true;
                        if (_textEditingController.text.isNotEmpty) {
                          Provider.of<FeedbackNotifier>(context, listen: false)
                              .sendComment(
                            _textEditingController.text,
                            post.id,
                            () {
                              _textEditingController.text = '';
                              post.commentCount++;
                              _onRefresh();
                              _sendCommentLock = false;
                            },
                          );
                        } else {
                          ToastProvider.error('评论不能为空');
                          _sendCommentLock = false;
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/model/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/util/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/comment_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/official_comment_page.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/home/home_router.dart';
import 'package:we_pei_yang_flutter/lounge/ui/widget/loading.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/message/message_provider.dart';
import 'components/post_card.dart';

enum DetailPageStatus {
  loading,
  idle,
  error,
}

enum PostOrigin { home, profile, favorite, mailbox }

class DetailPage extends StatefulWidget {
  final DetailPageArgs args;

  DetailPage([this.args]);

  @override
  _DetailPageState createState() =>
      _DetailPageState(this.args?.post, this.args?.index, this.args?.origin);
}

class DetailPageArgs {
  final Post post;
  final int index;
  final PostOrigin origin;

  DetailPageArgs(this.post, this.index, this.origin);
}

class _DetailPageState extends State<DetailPage> {
  Post post;
  final int commentIndex;
  PostOrigin origin;

  String _commentLengthIndicator;
  DetailPageStatus status;

  var _refreshController = RefreshController(initialRefresh: false);
  var _textEditingController = TextEditingController();

  _DetailPageState(this.post, this.commentIndex, this.origin);

  _onRefresh() {
    Provider.of<FeedbackNotifier>(context, listen: false).clearCommentList();
    FeedbackService.getComments(
      id: post.id,
      onSuccess: (officialCommentList, commentList) {
        Provider.of<FeedbackNotifier>(context, listen: false)
            .addComments(officialCommentList, commentList);
        setState(() => status = DetailPageStatus.idle);
      },
      onFailure: (e) => ToastProvider.error(e.error.toString()),
    );
    _refreshController.refreshCompleted();
  }

  _onPressLike() {
    FeedbackService.postHitLike(
      id: post.id,
      isLiked: post.isLiked,
      onSuccess: () {
        if (origin == PostOrigin.home) {
          notifier.changeHomePostLikeState(commentIndex);
        } else if (origin == PostOrigin.mailbox) {
          setState(() {
            post.isLiked ? post.likeCount-- : post.likeCount++;
            post.isLiked = !post.isLiked;
          });
        } else {
          notifier.changeProfilePostLikeState(commentIndex);
        }
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
      },
    );
  }

  _onPressFavorite() {
    FeedbackService.postHitFavorite(
      id: post.id,
      isFavorite: post.isFavorite,
      onSuccess: () {
        if (origin == PostOrigin.home) {
          notifier.changeHomePostFavoriteState(commentIndex);
        } else if (origin == PostOrigin.mailbox) {
          setState(() => post.isFavorite = !post.isFavorite);
        } else {
          notifier.changeProfilePostFavoriteState(commentIndex);
        }
      },
      onFailure: (e) => ToastProvider.error(e.error.toString()),
    );
  }

  @override
  void initState() {
    super.initState();
    status = DetailPageStatus.loading;
    _commentLengthIndicator = '0/200';
    Provider.of<FeedbackNotifier>(context, listen: false).clearCommentList();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      /// 如果是从通知栏点进来的
      if (post == null) {
        origin = PostOrigin.mailbox;
        var id = await messageChannel.invokeMethod<int>("getPostId");
        await FeedbackService.getPostById(
          id: id,
          onResult: (Post p) {
            post = p;
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
              await Provider.of<MessageProvider>(context, listen: false)
                  .setFeedbackQuestionRead(p.id);
            });
          },
          onFailure: (e) {
            ToastProvider.error(e.error.toString());
            setState(() => status = DetailPageStatus.error);
            return;
          },
        );
      }
      await FeedbackService.getComments(
        id: post.id,
        onSuccess: (officialCommentList, commentList) {
          Provider.of<FeedbackNotifier>(context, listen: false) // ??
              .addComments(officialCommentList, commentList);
          setState(() => status = DetailPageStatus.idle);
        },
        onFailure: (e) => ToastProvider.error(e.error.toString()),
      );
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (status == DetailPageStatus.loading) {
      body = Center(
        child: Loading(),
      );
    } else if (status == DetailPageStatus.idle) {
      body = Column(
        children: [
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
                    child: ListView.builder(
                        itemCount: notifier.officialCommentList.length +
                            notifier.commentList.length +
                            1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return PostCard.detail(
                              post,
                              onLikePressed: _onPressLike,
                              onFavoritePressed: _onPressFavorite,
                            );
                          }
                          index--;
                          if (index < notifier.officialCommentList.length) {
                            return CommentCard.official(
                              notifier.officialCommentList[index],
                              onContentPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  FeedbackRouter.officialComment,
                                  arguments: OfficialCommentPageArgs(
                                    notifier.officialCommentList[index],
                                    post.title,
                                    index,
                                    post.isOwner,
                                  ),
                                );
                              },
                              onLikePressed: () {
                                FeedbackService.officialCommentHitLike(
                                  id: notifier.officialCommentList[index].id,
                                  isLiked: notifier
                                      .officialCommentList[index].isLiked,
                                  onSuccess: () {
                                    notifier
                                        .changeOfficialCommentLikeState(index);
                                  },
                                  onFailure: (e) {
                                    ToastProvider.error(e.error.toString());
                                  },
                                );
                              },
                            );
                          } else {
                            return CommentCard(
                              notifier.commentList[
                                  index - notifier.officialCommentList.length],
                              index - notifier.officialCommentList.length + 1,
                              onLikePressed: () {
                                FeedbackService.commentHitLike(
                                  id: notifier
                                      .commentList[index -
                                          notifier.officialCommentList.length]
                                      .id,
                                  isLiked: notifier
                                      .commentList[index -
                                          notifier.officialCommentList.length]
                                      .isLiked,
                                  onSuccess: () {
                                    notifier.changeCommentLikeState(index -
                                        notifier.officialCommentList.length);
                                  },
                                  onFailure: (e) {
                                    ToastProvider.error(e.error.toString());
                                  },
                                );
                              },
                            );
                          }
                        }));
              },
            ),
          ),
          Row(
            children: [
              SizedBox(width: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextField(
                    controller: _textEditingController,
                    maxLength: 200,
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: S.current.feedback_write_comment,
                      suffix: Text(
                        _commentLengthIndicator,
                        style: FontManager.YaHeiRegular.copyWith(
                          fontSize: 14,
                          color: ColorUtil.lightTextColor,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(kToolbarHeight / 2),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      fillColor: ColorUtil.searchBarBackgroundColor,
                      filled: true,
                      isDense: true,
                    ),
                    onChanged: (text) {
                      // TODO: This leads to repainting of whole detail page.
                      _commentLengthIndicator = '${text.characters.length}/200';
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
                  if (_textEditingController.text.isNotEmpty) {
                    FeedbackService.sendComment(
                        id: post.id,
                        content: _textEditingController.text,
                        onSuccess: () {
                          _textEditingController.text = '';
                          post.commentCount++;

                          /// 刷新输入框字数
                          setState(() => _commentLengthIndicator = '0/200');
                          _onRefresh();
                        },
                        onFailure: (e) =>
                            ToastProvider.error(e.error.toString()));
                  } else {
                    ToastProvider.error(S.current.feedback_empty_comment_error);
                  }
                },
              ),
              SizedBox(width: 20),
            ],
          ),
        ],
      );
    } else {
      body = Center(child: Text("error!", style: FontManager.YaHeiRegular));
    }

    return WillPopScope(
      onWillPop: () async {
        if (ModalRoute.of(context).canPop) {
          return true;
        } else {
          Navigator.of(context).pushReplacementNamed(HomeRouter.home);
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: ColorUtil.mainColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            S.current.feedback_detail,
            style: FontManager.YaHeiRegular.copyWith(
              fontWeight: FontWeight.bold,
              color: ColorUtil.boldTextColor,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          brightness: Brightness.light,
        ),
        body: body,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/comment.dart';
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

class DetailPageArgs {
  final Post post;
  final int index;
  final PostOrigin origin;

  DetailPageArgs(this.post, this.index, this.origin);
}

class DetailPage extends StatefulWidget {
  final DetailPageArgs args;

  DetailPage([this.args]);

  @override
  _DetailPageState createState() =>
      _DetailPageState(this.args?.post, this.args?.index, this.args?.origin);
}

class _DetailPageState extends State<DetailPage> {
  final int commentIndex;
  Post post;
  PostOrigin origin;
  DetailPageStatus status;
  String _commentLengthIndicator;
  List<Comment> _officialCommentList, _commentList;

  var _refreshController = RefreshController(initialRefresh: false);
  var _textEditingController = TextEditingController();

  _DetailPageState(this.post, this.commentIndex, this.origin);

  _onRefresh() {
    ToastProvider.running("刷新评论中");
    setState(() {
      _officialCommentList.clear();
      _commentList.clear();
    });
    FeedbackService.getComments(
      id: post.id,
      onSuccess: (officialComments, comments) {
        _officialCommentList = officialComments;
        _commentList = comments;
        setState(() => status = DetailPageStatus.idle);
      },
      onFailure: (e) => ToastProvider.error(e.error.toString()),
    );
    _refreshController.refreshCompleted();
  }

  _onPostLike() {
    FeedbackService.postHitLike(
      id: post.id,
      isLiked: post.isLiked,
      onSuccess: () {
        if (origin == PostOrigin.home) {
          notifier.changeHomePostLikeState(commentIndex);
        } else if (origin == PostOrigin.mailbox) {
          post.isLiked ? post.likeCount-- : post.likeCount++;
          post.isLiked = !post.isLiked;
        } else {
          notifier.changeProfilePostLikeState(commentIndex);
        }
        setState(() {});
      },
      onFailure: (e) => ToastProvider.error(e.error.toString()),
    );
  }

  _onPostFavorite() {
    FeedbackService.postHitFavorite(
      id: post.id,
      isFavorite: post.isFavorite,
      onSuccess: () {
        if (origin == PostOrigin.home) {
          notifier.changeHomePostFavoriteState(commentIndex);
        } else if (origin == PostOrigin.mailbox) {
          post.isFavorite = !post.isFavorite;
        } else {
          notifier.changeProfilePostFavoriteState(commentIndex);
        }
        setState(() {});
      },
      onFailure: (e) => ToastProvider.error(e.error.toString()),
    );
  }

  _onOfficialCommentPressed(int index) {
    Navigator.pushNamed(
      context,
      FeedbackRouter.officialComment,
      arguments: OfficialCommentPageArgs(
        _officialCommentList[index],
        post.title,
        index,
        post.isOwner,
      ),
    ).then((officialComment) {
      setState(() => _officialCommentList[index] = officialComment);
    });
  }

  _onOfficialCommentLiked(int index) {
    FeedbackService.officialCommentHitLike(
      id: _officialCommentList[index].id,
      isLiked: _officialCommentList[index].isLiked,
      onSuccess: () {
        setState(() => _officialCommentList[index].changeLikeStatus());
      },
      onFailure: (e) => ToastProvider.error(e.error.toString()),
    );
  }

  _onCommentLiked(int index) {
    FeedbackService.commentHitLike(
      id: _commentList[index - _officialCommentList.length].id,
      isLiked: _commentList[index - _officialCommentList.length].isLiked,
      onSuccess: () {
        setState(() {
          _commentList[index - _officialCommentList.length].changeLikeStatus();
        });
      },
      onFailure: (e) => ToastProvider.error(e.error.toString()),
    );
  }

  @override
  void initState() {
    super.initState();
    status = DetailPageStatus.loading;
    _commentLengthIndicator = '0/200';
    _officialCommentList = List();
    _commentList = List();
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
        onSuccess: (officialComments, comments) {
          _officialCommentList = officialComments;
          _commentList = comments;
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
            child: SmartRefresher(
              physics: BouncingScrollPhysics(),
              controller: _refreshController,
              header: ClassicHeader(),
              enablePullDown: true,
              onRefresh: _onRefresh,
              enablePullUp: false,
              child: ListView.builder(
                itemCount:
                    _officialCommentList.length + _commentList.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return PostCard.detail(
                      post,
                      onLikePressed: _onPostLike,
                      onFavoritePressed: _onPostFavorite,
                    );
                  }
                  index--;
                  if (index < _officialCommentList.length) {
                    return CommentCard.official(
                      _officialCommentList[index],
                      onContentPressed: () {
                        _onOfficialCommentPressed(index);
                      },
                      onLikePressed: () {
                        _onOfficialCommentLiked(index);
                      },
                    );
                  } else {
                    return CommentCard(
                      _commentList[index - _officialCommentList.length],
                      index - _officialCommentList.length + 1,
                      onLikePressed: () {
                        _onCommentLiked(index);
                      },
                    );
                  }
                },
              ),
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
          actions: [
            IconButton(
              icon: Icon(
                Icons.share_outlined,
                color: Color(0xff62677b),
              ),
              onPressed: () {
                shareChannel.invokeMethod("shareToQQ", {
                  "summary": "校务专区问题详情",
                  "title": post.title,
                  "id": post.id
                });
              },
            )
          ],
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

var shareChannel = MethodChannel("com.twt.service/share");

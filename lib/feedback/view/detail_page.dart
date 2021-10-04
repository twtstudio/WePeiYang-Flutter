import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/comment.dart';
import 'package:we_pei_yang_flutter/feedback/model/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/normal_comment_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/official_comment_card.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/lounge/ui/widget/loading.dart';
import 'package:we_pei_yang_flutter/message/message_provider.dart';

import 'components/post_card.dart';

enum DetailPageStatus {
  loading,
  idle,
  error,
}

enum PostOrigin { home, profile, favorite, mailbox }

class DetailPage extends StatefulWidget {
  final Post post;

  DetailPage(this.post);

  @override
  _DetailPageState createState() => _DetailPageState(this.post);
}

class _DetailPageState extends State<DetailPage> {
  Post post;
  DetailPageStatus status;
  List<Comment> _officialCommentList, _commentList;
  int currentPage = 1, _totalPage = 1;

  var _refreshController = RefreshController(initialRefresh: false);

  _DetailPageState(this.post);

  _onRefresh() {
    ToastProvider.running("刷新评论中");
    _initPostAndComments(
      onSuccess: (comments) {
        _commentList = comments;
        _refreshController.refreshCompleted();
      },
      onFail: () {
        _refreshController.refreshFailed();
      },
    );
  }

  _onLoading() {
    if (currentPage != _totalPage) {
      currentPage++;
      _getComments(onSuccess: (comments) {
        _commentList.addAll(comments);
        _refreshController.loadComplete();
      }, onFail: () {
        _refreshController.loadFailed();
      });
    } else {
      _refreshController.loadNoData();
    }
  }

  @override
  void initState() {
    super.initState();
    status = DetailPageStatus.loading;
    _officialCommentList = List();
    _commentList = List();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      /// 如果是从通知栏点进来的
      if (post.title == null) {
        _initPostAndComments(onSuccess: (comments) {
          _commentList.addAll(comments);
          status = DetailPageStatus.idle;
        }, onFail: () {
          status = DetailPageStatus.error;
        });
      } else {
        _getComments(onSuccess: (comments) {
          _commentList.addAll(comments);
          status = DetailPageStatus.idle;
        }, onFail: () {
          status = DetailPageStatus.idle;
        });
      }
    });
  }

  // 逻辑有点问题
  _initPostAndComments({Function(List<Comment>) onSuccess, Function onFail}) {
    _initPost(onFail).then((success) {
      if (success) {
        _getOfficialComment(onFail: onFail);
        _getComments(
          onSuccess: onSuccess,
          onFail: onFail,
          current: 1,
        );
      }
    });
  }

  Future<bool> _initPost([Function onFail]) async {
    bool success = false;
    await FeedbackService.getPostById(
      id: post.id,
      onResult: (Post p) {
        post = p;
        Provider.of<MessageProvider>(context, listen: false)
            .setFeedbackQuestionRead(p.id);
        success = true;
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
        success = false;
        onFail?.call();
        setState(() => status = DetailPageStatus.error);
        return;
      },
    );
    return success;
  }

  _getOfficialComment({Function onSuccess, Function onFail}) {
    FeedbackService.getOfficialComment(
      id: post.id,
      onSuccess: (comments) {
        _officialCommentList = comments;
        onSuccess?.call();
        setState(() {});
      },
      onFailure: (e) {
        onFail?.call();
        ToastProvider.error(e.error.toString());
      },
    );
  }

  _getComments(
      {Function(List<Comment>) onSuccess, Function onFail, int current}) {
    FeedbackService.getComments(
      id: post.id,
      page: current ?? currentPage,
      onSuccess: (comments, totalPage) {
        _totalPage = totalPage;
        onSuccess?.call(comments);
        setState(() {});
      },
      onFailure: (e) {
        onFail?.call();
        ToastProvider.error(e.error.toString());
      },
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
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
      Widget mainList = ListView.builder(
        itemCount: _officialCommentList.length + _commentList.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return PostCard.detail(post);
          }
          index--;
          if (index == 0) {
            print(_commentList[0].toJson());
          }
          if (index < _officialCommentList.length) {
            return OfficialReplyCard.reply(
                comment: _officialCommentList[index]);
          } else {
            return NCommentCard(
              comment: _commentList[index - _officialCommentList.length],
              commentFloor: index - _officialCommentList.length + 1,
            );
          }
        },
      );

      mainList = Expanded(
        child: SmartRefresher(
          physics: BouncingScrollPhysics(),
          controller: _refreshController,
          header: ClassicHeader(),
          footer: ClassicFooter(),
          enablePullDown: true,
          onRefresh: _onRefresh,
          enablePullUp: true,
          onLoading: _onLoading,
          child: mainList,
        ),
      );

      var inputField = CommentInputField();

      body = Column(
        children: [mainList, inputField],
      );
    } else {
      body = Center(child: Text("error!", style: FontManager.YaHeiRegular));
    }

    var shareButton = IconButton(
      icon: Icon(
        Icons.share_outlined,
        color: Color(0xff62677b),
      ),
      onPressed: () {
        shareChannel.invokeMethod("shareToQQ",
            {"summary": "校务专区问题详情", "title": post.title, "id": post.id});
      },
    );

    var appBar = AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: ColorUtil.mainColor),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [shareButton],
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
    );

    return Scaffold(
      appBar: appBar,
      body: body,
    );
  }
}

var shareChannel = MethodChannel("com.twt.service/share");

class CommentInputField extends StatefulWidget {
  final int postId;

  const CommentInputField({Key key, this.postId}) : super(key: key);

  @override
  _CommentInputFieldState createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<CommentInputField> {
  var _textEditingController = TextEditingController();
  String _commentLengthIndicator = '0/200';

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget inputField = TextField(
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
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        fillColor: ColorUtil.searchBarBackgroundColor,
        filled: true,
        isDense: true,
      ),
      onChanged: (text) {
        _commentLengthIndicator = '${text.characters.length}/200';
        setState(() {});
      },
      enabled: true,
      minLines: 1,
      maxLines: 3,
    );

    inputField = Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: inputField,
      ),
    );

    Widget commitButton = IconButton(
      icon: Icon(Icons.send),
      onPressed: () async {
        if (_textEditingController.text.isNotEmpty) {
          _sendComment();
        } else {
          ToastProvider.error(S.current.feedback_empty_comment_error);
        }
      },
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [inputField, commitButton],
      ),
    );
  }

  _sendComment() {
    FeedbackService.sendComment(
      id: widget.postId,
      content: _textEditingController.text,
      onSuccess: () {
        _textEditingController.text = '';
        // post.commentCount++;
        /// 刷新输入框字数
        setState(() => _commentLengthIndicator = '0/200');
        context.findAncestorStateOfType<_DetailPageState>()._onRefresh();
      },
      onFailure: (e) => ToastProvider.error(
        e.error.toString(),
      ),
    );
  }
}

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/clip_copy.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/icon_widget.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/round_taggings.dart';
import 'package:we_pei_yang_flutter/feedback/view/report_question_page.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/lounge/ui/widget/loading.dart';

typedef LikeCallback = void Function(bool, int);
typedef DislikeCallback = void Function(bool);

class NCommentCard extends StatefulWidget {
  final String ancestorName;
  final int ancestorId;
  final Floor comment;
  final int commentFloor;
  final LikeCallback likeSuccessCallback;
  final DislikeCallback dislikeSuccessCallback;
  final bool isSubFloor;
  final bool isFullView;

  @override
  _NCommentCardState createState() => _NCommentCardState();

  NCommentCard(
      {this.ancestorName,
      this.ancestorId,
      this.comment,
      this.commentFloor,
      this.likeSuccessCallback,
      this.dislikeSuccessCallback,
      this.isSubFloor,
      this.isFullView});
}

class _NCommentCardState extends State<NCommentCard> {
  final String baseUrl = 'https://www.zrzz.site:7013/';
  bool _picFullView = false;
  static WidgetBuilder defaultPlaceholderBuilder =
      (BuildContext ctx) => Loading();

  Future<bool> _showDeleteConfirmDialog() {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('提示'),
            content: Text('您确定要删除这条评论吗?'),
            actions: <Widget>[
              TextButton(
                child: Text('确定'),
                onPressed: () {
                  //关闭对话框并返回true
                  Navigator.of(context).pop(true);
                },
              ),
              TextButton(
                child: Text('取消'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var topWidget = Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          child: SvgPicture.network(
            'http://www.zrzz.site:7014/beam/20/${widget.comment.postId}+${widget.comment.nickname}',
            width: 30,
            height: 30,
            fit: BoxFit.cover,
            placeholderBuilder: defaultPlaceholderBuilder,
          ),
        ),
        SizedBox(width: 4),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    widget.comment.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextUtil.base.black2A.w400.NotoSansSC.sp(14),
                  ),
                  if (widget.comment.isOwner)
                    CommentIdentificationContainer('我的评论', true),
                  if (widget.comment.nickname == 'Owner')
                    CommentIdentificationContainer('楼主', true),
                  if (widget.isSubFloor &&
                      widget.comment.nickname == widget.ancestorName)
                    CommentIdentificationContainer('层主', true),
                  //后面有东西时出现
                  if (widget.comment.replyToName != '' &&
                      widget.comment.replyTo != widget.ancestorId)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(Icons.play_arrow, size: 8),
                    ),
                  //回复的不是层主那条时出现
                  if (widget.comment.replyToName != '' &&
                      widget.comment.replyTo != widget.ancestorId)
                    Text(
                      widget.comment.replyToName,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: TextUtil.base.grey97.w400.NotoSansSC.sp(14),
                    ),
                  //回的是楼主并且楼主不是层主或者楼主是层主的时候回复的不是这条评论
                  if (widget.isSubFloor &&
                      widget.comment.replyToName == 'Owner' &&
                      (widget.ancestorName != 'Owner' ||
                          (widget.ancestorName == 'Owner' &&
                              widget.comment.replyTo != widget.ancestorId)))
                    CommentIdentificationContainer('楼主', false),
                  //回的是层主但回复的不是这条评论
                  if (widget.isSubFloor &&
                      widget.comment.replyToName == widget.ancestorName &&
                      widget.comment.replyTo != widget.ancestorId)
                    CommentIdentificationContainer('层主', false),
                  if (widget.isSubFloor &&
                      widget.comment.replyTo != widget.ancestorId)
                    CommentIdentificationContainer(
                        '回复：' + widget.comment.replyTo.toString(), false),
                ],
              ),
              Text(
                DateTime.now()
                    .difference(widget.comment.createAt)
                    .dayHourMinuteSecondFormatted(),
                style: TextUtil.base.ProductSans.grey97.regular.sp(10),
              ),
            ],
          ),
        ),
        SizedBox(width: 4),
        IconButton(
          icon: SvgPicture.asset(
              'assets/svg_pics/lake_butt_icons/more_horizontal.svg'),
          iconSize: 16,
          onPressed: () {
            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(1000, kToolbarHeight, 0, 0),
              //TODO:需要处理
              items: <PopupMenuItem<String>>[
                PopupMenuItem<String>(
                  value: '分享',
                  child: new Text(
                    '分享',
                    style: TextUtil.base.black2A.regular.NotoSansSC.sp(12),
                  ),
                ),
                widget.comment.isOwner
                    ? PopupMenuItem<String>(
                        value: '删除',
                        child: new Text(
                          '删除',
                          style:
                              TextUtil.base.black2A.regular.NotoSansSC.sp(12),
                        ),
                      )
                    : PopupMenuItem<String>(
                        value: '举报',
                        child: new Text(
                          '举报',
                          style:
                              TextUtil.base.black2A.regular.NotoSansSC.sp(12),
                        ),
                      ),
              ],
            ).then((value) async {
              if (value == '举报') {
                //TODO:举报
                Navigator.pushNamed(context, FeedbackRouter.report,
                    arguments: ReportPageArgs(widget.comment.id, false));
              } else if (value == '删除') {
                bool confirm = await _showDeleteConfirmDialog();
                if (confirm) {
                  FeedbackService.deleteFloor(
                    id: widget.comment.id,
                    onSuccess: () {
                      ToastProvider.success(S.current.feedback_delete_success);
                      setState(() {});
                    },
                    onFailure: (e) {
                      ToastProvider.error(e.error.toString());
                    },
                  );
                }
              }
            });
          },
          constraints: BoxConstraints(),
          padding: EdgeInsets.zero,
        )
      ],
    );

    var commentContent = Text(
      widget.comment.content,
      style: TextUtil.base.w400.NotoSansSC.black2A.h(1.2).sp(16),
    );

    var commentImage = Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: InkWell(
          onTap: () {
            setState(() {
              _picFullView = true;
            });
          },
          child: _picFullView
              ? InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, FeedbackRouter.imageView,
                        arguments: {
                          "urlList": [widget.comment.imageUrl],
                          "urlListLength": 1,
                          "indexNow": 0
                        });
                  },
                  child: Image.network(
                    baseUrl + widget.comment.imageUrl,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace stackTrace) {
                      return Text(
                        '💔[图片加载失败]',
                        style: TextUtil.base.grey6C.w400.sp(12),
                      );
                    },
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  child: Image.network(
                    baseUrl + widget.comment.imageUrl,
                    width: 70.w,
                    height: 64.h,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 40.h,
                        width: 40.h,
                        padding: EdgeInsets.all(4),
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace stackTrace) {
                      return Text(
                        '💔[图片加载失败]',
                        style: TextUtil.base.grey6C.w400.sp(12),
                      );
                    },
                  ),
                ),
        ));

    var replyButton = IconButton(
      icon: SvgPicture.asset('assets/svg_pics/lake_butt_icons/reply.svg'),
      iconSize: 16,
      constraints: BoxConstraints(),
      onPressed: () {
        Provider.of<NewFloorProvider>(context, listen: false)
            .inputFieldOpenAndReplyTo(widget.comment.id);
        context.read<NewFloorProvider>().focusNode.requestFocus();
      },
      padding: EdgeInsets.zero,
      color: ColorUtil.boldLakeTextColor,
    );

    var subFloor;
    if (widget.comment.subFloors != null && !widget.isSubFloor) {
      subFloor = ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.isFullView
            ? widget.comment.subFloorCnt
            : widget.comment.subFloorCnt > 2
                ? 2
                : min(widget.comment.subFloorCnt,
                    widget.comment.subFloors.length),
        itemBuilder: (context, index) {
          return Column(
            children: [
              NCommentCard(
                ancestorName: widget.comment.nickname,
                ancestorId: widget.comment.id,
                comment: widget.comment.subFloors[index],
                commentFloor: index + 1,
                isSubFloor: true,
                isFullView: widget.isFullView,
              ),
              if (widget.isFullView &&
                  index !=
                      min(widget.comment.subFloorCnt,
                              widget.comment.subFloors.length) -
                          1)
                Container(
                  color: ColorUtil.greyEAColor,
                  height: 1.5,
                  margin: EdgeInsets.symmetric(horizontal: 32),
                )
            ],
          );
        },
      );
    }

    var likeWidget = IconWidget(IconType.like, count: widget.comment.likeCount,
        onLikePressed: (isLiked, count, success, failure) async {
      await FeedbackService.commentHitLike(
        id: widget.comment.id,
        isLike: widget.comment.isLike,
        onSuccess: () {
          widget.likeSuccessCallback?.call(!isLiked, count);
          success.call();
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
          failure.call();
        },
      );
    }, isLike: widget.comment.isLike);

    var dislikeWidget = DislikeWidget(
      size: 15.w,
      isDislike: widget.comment.isDis,
      onDislikePressed: (dislikeNotifier) async {
        await FeedbackService.commentHitDislike(
          id: widget.comment.id,
          isDis: widget.comment.isDis,
          onSuccess: () {
            widget.dislikeSuccessCallback?.call(dislikeNotifier);
            widget.comment.isDis = !widget.comment.isDis;
            if (widget.comment.isDis && widget.comment.isLike) {
              widget.comment.isLike = !widget.comment.isLike;
              widget.comment.likeCount--;
            }
          },
          onFailure: (e) {
            ToastProvider.error(e.error.toString());
          },
        );
      },
    );

    var likeAndDislikeWidget = [likeWidget, dislikeWidget];

    var bottomWidget = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ...likeAndDislikeWidget,
        Spacer(),
        Padding(
          padding: const EdgeInsets.only(right: 4.0, bottom: 1.0),
          child: Text('ID: ' + widget.comment.id.toString(),
              style: TextUtil.base.NotoSansSC.w500.grey6C.sp(9)),
        ),
        replyButton,
      ],
    );

    var mainBody = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 6),
        topWidget,
        SizedBox(height: 10),
        commentContent,
        if (widget.comment.imageUrl != '') commentImage,
        _picFullView == true
            ? Row(
                children: [
                  Spacer(),
                  TextButton(
                      style: ButtonStyle(
                          alignment: Alignment.topRight,
                          padding: MaterialStateProperty.all(EdgeInsets.zero)),
                      onPressed: () {
                        setState(() {
                          _picFullView = false;
                        });
                      },
                      child: Text('收起',
                          style: TextUtil.base.greyA8.w800.NotoSansSC.sp(12))),
                ],
              )
            : SizedBox(height: 8),
        bottomWidget,
        SizedBox(height: 4)
      ],
    );

    return Column(
      children: [
        ClipCopy(
          copy: widget.comment.content,
          toast: '复制评论成功',
          // 这个padding其实起到的是margin的效果，因为Ink没有margin属性
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            // 这个Ink是为了确保body -> bottomWidget -> reportWidget的波纹效果正常显示
            child: Ink(
              padding: EdgeInsets.fromLTRB(16.w, 8, 16.w, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: widget.isFullView && widget.isSubFloor
                    ? Colors.transparent
                    : Colors.white,
                boxShadow: [
                  widget.isFullView && widget.isSubFloor
                      ? BoxShadow(color: Colors.transparent)
                      : BoxShadow(
                          blurRadius: 5,
                          color: Color.fromARGB(64, 236, 237, 239),
                          offset: Offset(0, 0),
                          spreadRadius: 3),
                ],
              ),
              child: mainBody,
            ),
          ),
        ),
        if (!widget.isSubFloor && subFloor != null)
          Padding(
              padding: widget.isFullView
                  ? EdgeInsets.zero
                  : EdgeInsets.only(left: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  subFloor,
                  if (widget.comment.subFloorCnt > 0 && !widget.isFullView)
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          FeedbackRouter.commentDetail,
                          arguments: widget.comment,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Chip(
                          padding: const EdgeInsets.all(0),
                          labelPadding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                          backgroundColor: Color(0xffebebeb),
                          label: Text(
                              widget.comment.subFloorCnt > 2
                                  ? '查看全部 ' +
                                      widget.comment.subFloorCnt.toString() +
                                      ' 条回复 >'
                                  : '查看回复详情 >',
                              style:
                                  TextUtil.base.ProductSans.w400.sp(14).grey6C),
                        ),
                      ),
                    )
                ],
              )),
      ],
    );
  }
}

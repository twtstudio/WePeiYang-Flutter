import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/clip_copy.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/icon_widget.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/long_text_shower.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/round_taggings.dart';
import 'package:we_pei_yang_flutter/feedback/view/report_question_page.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/lounge/ui/widget/loading.dart';

typedef LikeCallback = void Function(bool, int);
typedef DislikeCallback = void Function(bool);

class NCommentCard extends StatefulWidget {
  final int placeAppeared;
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
      {this.placeAppeared,
      this.ancestorName,
      this.ancestorId,
      this.comment,
      this.commentFloor,
      this.likeSuccessCallback,
      this.dislikeSuccessCallback,
      this.isSubFloor,
      this.isFullView});
}

class _NCommentCardState extends State<NCommentCard>
    with SingleTickerProviderStateMixin {
  final String picBaseUrl = 'https://www.zrzz.site:7015/download/';
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
                  CommentIdentificationContainer(
                      widget.comment.isOwner
                          ? '我的评论'
                          : widget.comment.nickname == 'Owner'
                              ? widget.isSubFloor &&
                                      widget.comment.nickname ==
                                          widget.ancestorName
                                  ? '楼主 层主'
                                  : '楼主'
                              : widget.isSubFloor &&
                                      widget.comment.nickname ==
                                          widget.ancestorName
                                  ? '层主'
                                  : '',
                      true),
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
                      widget.comment.replyToName +
                          (widget.comment.isOwner &&
                                  widget.comment.replyToName ==
                                      widget.comment.nickname
                              ? '(我)'
                              : ''),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: TextUtil.base.grey97.w400.NotoSansSC.sp(14),
                    ),
                  //回的是楼主并且楼主不是层主或者楼主是层主的时候回复的不是这条评论
                  //回的是层主但回复的不是这条评论
                  if (!widget.comment.isOwner &&
                      widget.comment.replyToName != widget.comment.nickname)
                    CommentIdentificationContainer(
                        widget.isSubFloor
                            ? widget.comment.replyToName == 'Owner' &&
                                    (widget.ancestorName != 'Owner' ||
                                        (widget.ancestorName == 'Owner' &&
                                            widget.comment.replyTo !=
                                                widget.ancestorId))
                                ? widget.comment.replyToName ==
                                            widget.ancestorName &&
                                        widget.comment.replyTo !=
                                            widget.ancestorId
                                    ? '楼主 层主'
                                    : '楼主'
                                : widget.comment.replyToName ==
                                            widget.ancestorName &&
                                        widget.comment.replyTo !=
                                            widget.ancestorId
                                    ? '层主'
                                    : ''
                            : '',
                        false),
                  if (widget.isSubFloor &&
                      widget.comment.replyTo != widget.ancestorId)
                    CommentIdentificationContainer(
                        '回复-> ID：' + widget.comment.replyTo.toString(), false),
                ],
              ),
              Text(
                DateTime.now().difference(widget.comment.createAt).inDays >= 1
                    ? widget.comment.createAt
                        .toLocal()
                        .toIso8601String()
                        .replaceRange(10, 11, ' ')
                        .substring(0, 19)
                    : DateTime.now()
                        .difference(widget.comment.createAt)
                        .dayHourMinuteSecondFormatted(),
                style: TextUtil.base.ProductSans.grey97.regular.sp(10),
              ),
            ],
          ),
        ),
        SizedBox(width: 4),
        PopupMenuButton(
          padding: EdgeInsets.zero,
          shape: RacTangle(),
          offset: Offset(0, 0),
          child: SvgPicture.asset(
            'assets/svg_pics/lake_butt_icons/more_horizontal.svg',
            width: 16,
          ),
          onSelected: (value) async {
            if (value == '分享') {
              String weCo =
                  '我在微北洋发现了个有趣的问题，你也来看看吧~\n将本条微口令复制到微北洋校务专区打开问题 wpy://school_project/${widget.ancestorId}\n【${widget.comment.nickname}】';
              ClipboardData data = ClipboardData(text: weCo);
              Clipboard.setData(data);
              CommonPreferences().feedbackLastWeCo.value =
                  widget.ancestorId.toString();
              ToastProvider.success('微口令复制成功，快去给小伙伴分享吧！');
            }
            if (value == '举报') {
              Navigator.pushNamed(context, FeedbackRouter.report,
                  arguments: ReportPageArgs(widget.ancestorId, false,
                      floorId: widget.comment.id));
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
          },
          itemBuilder: (context) {
            return <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: '分享',
                child: Center(
                  child: Text(
                    '分享',
                    style: TextUtil.base.black2A.regular.NotoSansSC.sp(12),
                  ),
                ),
              ),
              widget.comment.isOwner
                  ? PopupMenuItem<String>(
                      value: '删除',
                      child: Center(
                        child: Text(
                          '删除',
                          style:
                              TextUtil.base.black2A.regular.NotoSansSC.sp(12),
                        ),
                      ),
                    )
                  : PopupMenuItem<String>(
                      value: '举报',
                      child: Center(
                        child: Text(
                          '举报',
                          style:
                              TextUtil.base.black2A.regular.NotoSansSC.sp(12),
                        ),
                      ),
                    ),
            ];
          },
        ),
      ],
    );

    var commentContent = ExpandableText(
      text: widget.comment.content,
      maxLines: !widget.isFullView && widget.isSubFloor ? 3 : 8,
      style: TextUtil.base.w400.NotoSansSC.black2A.h(1.2).sp(16),
      expand: false,
      buttonIsShown: true,
    );

    var commentImage = Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: AnimatedSize(
          vsync: this,
          duration: Duration(milliseconds: 150),
          curve: Curves.decelerate,
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
                        picBaseUrl + 'origin/' + widget.comment.imageUrl,
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
                            '💔[图片加载失败]' +
                                widget.comment.imageUrl.replaceRange(10,
                                    widget.comment.imageUrl.length - 6, '...'),
                            style: TextUtil.base.grey6C.w400.sp(12),
                          );
                        },
                      ),
                    )
                  : Row(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            child: Image.network(
                                picBaseUrl + 'thumb/' + widget.comment.imageUrl,
                                width: 70,
                                height: 64,
                                fit: BoxFit.cover, loadingBuilder:
                                    (BuildContext context, Widget child,
                                        ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 40,
                                width: 40,
                                padding: EdgeInsets.all(4),
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes
                                      : null,
                                ),
                              );
                            }, errorBuilder: (BuildContext context,
                                    Object exception, StackTrace stackTrace) {
                              return Text(
                                '💔[加载失败，可尝试点击继续加载原图]\n    ' +
                                    widget.comment.imageUrl.replaceRange(
                                        10,
                                        widget.comment.imageUrl.length - 6,
                                        '...'),
                                style: TextUtil.base.grey6C.w400.sp(12),
                              );
                            })),
                        Spacer()
                      ],
                    )),
        ));

    var replyButton = IconButton(
      icon: SvgPicture.asset('assets/svg_pics/lake_butt_icons/reply.svg'),
      iconSize: 16,
      constraints: BoxConstraints(),
      onPressed: () {
        context.read<NewFloorProvider>().locate = widget.placeAppeared ?? 0;
        Provider.of<NewFloorProvider>(context, listen: false)
            .inputFieldOpenAndReplyTo(widget.comment.id);
        FocusScope.of(context).requestFocus(
            Provider.of<NewFloorProvider>(context, listen: false).focusNode);
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
          return NCommentCard(
            placeAppeared: widget.placeAppeared,
            ancestorName: widget.comment.nickname,
            ancestorId: widget.comment.id,
            comment: widget.comment.subFloors[index],
            commentFloor: index + 1,
            isSubFloor: true,
            isFullView: widget.isFullView,
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
          widget.comment.isLike = !widget.comment.isLike;
          widget.comment.likeCount ++;
          if(widget.comment.isLike && widget.comment.isDis) {
            widget.comment.isDis = !widget.comment.isDis;
            setState(() {});
          }
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
              setState(() {});
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
            ? TextButton(
                style: ButtonStyle(
                    alignment: Alignment.topRight,
                    padding: MaterialStateProperty.all(EdgeInsets.zero)),
                onPressed: () {
                  setState(() {
                    _picFullView = false;
                  });
                },
                child: Row(
                  children: [
                    Spacer(),
                    Text('收起',
                        style: TextUtil.base.greyA8.w800.NotoSansSC.sp(12)),
                  ],
                ))
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
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
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
        if (!widget.isSubFloor && !widget.isFullView && subFloor != null)
          Padding(
              padding: EdgeInsets.only(left: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  subFloor,
                  if (widget.comment.subFloorCnt > 0)
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

class RacTangle extends ShapeBorder {
  ///todo popMenu调不了宽度，现阶段采用的是我强行用裁剪剪出理想形状，回头我重写一个
  @override
  // ignore: missing_return
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return null;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    var path = Path();
    Rect rects = Rect.fromLTWH(27.5.w, 0, 87.6.w, rect.height);
    path.addRRect(RRect.fromRectAndRadius(rects, Radius.circular(20)));
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {
    var w = rect.width;
    var tang = Paint()
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.square
      ..color = Colors.white
      ..strokeWidth = 5;
    //var h = rect.height;

    canvas.drawLine(Offset(w - 20.w, 5), Offset(w - 15.w, -5), tang);
    canvas.drawLine(Offset(w - 15.w, -5), Offset(w - 10.w, 5), tang);
  }

  @override
  ShapeBorder scale(double t) {
    return null;
  }

  @override
  EdgeInsetsGeometry get dimensions => null;
}

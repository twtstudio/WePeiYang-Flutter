import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:we_pei_yang_flutter/commons/common_widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/clip_copy.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/icon_widget.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/long_text_shower.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/round_taggings.dart';
import 'package:we_pei_yang_flutter/feedback/view/reply_detail_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/report_question_page.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/main.dart';

typedef LikeCallback = void Function(bool, int);
typedef DislikeCallback = void Function(bool);

class NCommentCard extends StatefulWidget {
  final String ancestorName;
  final int ancestorUId;
  final Floor comment;
  final int uid;
  final int commentFloor;
  final int type;
  final LikeCallback likeSuccessCallback;
  final DislikeCallback dislikeSuccessCallback;
  final bool isSubFloor;
  final bool isFullView;

  @override
  _NCommentCardState createState() => _NCommentCardState();

  NCommentCard(
      {this.ancestorName,
      this.ancestorUId,
      this.comment,
      this.uid,
      this.commentFloor,
      this.likeSuccessCallback,
      this.dislikeSuccessCallback,
      this.isSubFloor,
      this.isFullView,
      this.type});
}

class _NCommentCardState extends State<NCommentCard>
    with SingleTickerProviderStateMixin {
  ScrollController _sc;

  //final String picBaseUrl = 'https://qnhdpic.twt.edu.cn/download/';
  final String picBaseUrl = '${EnvConfig.QNHDPIC}download/';
  bool _picFullView = false, _isDeleted = false;

  Future<bool> _showDeleteConfirmDialog(String quote) {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return LakeDialogWidget(
              title: '$quote评论',
              content: Text('您确定要$quote这条评论吗？'),
              cancelText: "取消",
              confirmTextStyle:
                  TextUtil.base.normal.black2A.NotoSansSC.sp(16).w400,
              cancelTextStyle:
                  TextUtil.base.normal.black2A.NotoSansSC.sp(16).w600,
              confirmText: quote == '摧毁' ? 'BOOM' : "确认",
              cancelFun: () {
                Navigator.of(context).pop();
              },
              confirmFun: () {
                Navigator.of(context).pop(true);
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    var commentMenuButton = GestureDetector(
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.w, 8.w, 8.w, 12.w),
          child: SvgPicture.asset(
            'assets/svg_pics/lake_butt_icons/more_horizontal.svg',
            width: 18.w,
            color: Colors.black,
          ),
        ),
        onTap: () {
          showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoActionSheet(
                actions: <Widget>[
                  // 分享按钮
                  CupertinoActionSheetAction(
                    onPressed: () {
                      String weCo =
                          '我在微北洋发现了个有趣的问题评论，你也来看看吧~\n将本条微口令复制到微北洋求实论坛打开问题 wpy://school_project/${widget.comment.postId}\n【${widget.comment.content}】';
                      ClipboardData data = ClipboardData(text: weCo);
                      Clipboard.setData(data);
                      CommonPreferences.feedbackLastWeCo.value =
                          widget.ancestorUId.toString();
                      ToastProvider.success('微口令复制成功，快去给小伙伴分享吧！');
                    },
                    child: Text(
                      '分享',
                      style:
                          TextUtil.base.normal.w400.NotoSansSC.black00.sp(16),
                    ),
                  ),

                  CupertinoActionSheetAction(
                    onPressed: () {
                      ClipboardData data =
                          ClipboardData(text: widget.comment.content);
                      Clipboard.setData(data);
                      ToastProvider.success('复制成功');
                      Navigator.pop(context);
                    },
                    child: Text(
                      '复制',
                      style:
                          TextUtil.base.normal.w400.NotoSansSC.black00.sp(16),
                    ),
                  ),
                  widget.comment.isOwner
                      ? CupertinoActionSheetAction(
                          onPressed: () async {
                            bool confirm = await _showDeleteConfirmDialog('删除');
                            if (confirm) {
                              FeedbackService.deleteFloor(
                                id: widget.comment.id,
                                onSuccess: () {
                                  ToastProvider.success(
                                      S.current.feedback_delete_success);
                                  setState(() {
                                    _isDeleted = true;
                                  });
                                },
                                onFailure: (e) {
                                  ToastProvider.error(e.error.toString());
                                },
                              );
                            }
                            Navigator.pop(context);
                          },
                          child: Text(
                            '删除',
                            style: TextUtil.base.normal.w400.NotoSansSC.black00
                                .sp(16),
                          ),
                        )
                      : CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pushNamed(context, FeedbackRouter.report,
                                arguments: ReportPageArgs(
                                    widget.ancestorUId, false,
                                    floorId: widget.comment.id));
                          },
                          child: Text(
                            '举报',
                            style: TextUtil.base.normal.w400.NotoSansSC.black00
                                .sp(16),
                          ),
                        ),
                  if ((CommonPreferences.isSuper.value ||
                          CommonPreferences.isStuAdmin.value) ??
                      false)
                    CupertinoActionSheetAction(
                      onPressed: () async {
                        bool confirm = await _showDeleteConfirmDialog('摧毁');
                        if (confirm) {
                          FeedbackService.adminDeleteReply(
                            floorId: widget.comment.id,
                            onSuccess: () {
                              ToastProvider.success(
                                  S.current.feedback_delete_success);
                              setState(() {
                                _isDeleted = true;
                              });
                            },
                            onFailure: (e) {
                              ToastProvider.error(e.error.toString());
                            },
                          );
                        }
                      },
                      child: Text(
                        '删评',
                        style:
                            TextUtil.base.normal.w400.NotoSansSC.black00.sp(16),
                      ),
                    ),
                ],
                cancelButton: CupertinoActionSheetAction(
                  // 取消按钮
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '取消',
                    style: TextUtil.base.normal.w400.NotoSansSC.black00.sp(16),
                  ),
                ),
              );
            },
          );
        });

    var topWidget = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    widget.comment.nickname ?? "匿名用户",
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextUtil.base.w400.bold.NotoSansSC.sp(14).black2A,
                  ),
                  if (widget.comment.isOwner != null)
                    CommentIdentificationContainer(
                        widget.comment.isOwner
                            ? '我的评论'
                            : widget.comment.uid == widget.uid
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
                  //回复自己那条时出现
                  if (widget.comment.replyToName != '' &&
                      widget.comment.replyTo != widget.ancestorUId)
                    widget.comment.isOwner &&
                            widget.comment.replyToName ==
                                widget.comment.nickname
                        ? CommentIdentificationContainer('回复我', true)
                        : SizedBox(),
                  //后面有东西时出现
                  if (widget.comment.replyToName != '' &&
                      widget.comment.replyTo != widget.ancestorUId)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 2),
                        Icon(Icons.play_arrow, size: 8),
                        SizedBox(width: 2),
                        Text(
                          widget.comment.replyToName ?? "",
                          style: TextUtil.base.w700.NotoSansSC.sp(14).black2A,
                        ),
                        SizedBox(width: 2)
                      ],
                    ),
                  //回的是楼主并且楼主不是层主或者楼主是层主的时候回复的不是这条评论
                  //回的是层主但回复的不是这条评论
                  if (widget.comment.isOwner != null &&
                      !widget.comment.isOwner &&
                      widget.comment.replyToName != widget.comment.nickname)
                    CommentIdentificationContainer(
                        widget.isSubFloor
                            ? widget.comment.replyToName == 'Owner' &&
                                    (widget.ancestorName != 'Owner' ||
                                        (widget.ancestorName == 'Owner' &&
                                            widget.comment.replyTo !=
                                                widget.ancestorUId))
                                ? widget.comment.replyToName ==
                                            widget.ancestorName &&
                                        widget.comment.replyTo !=
                                            widget.ancestorUId
                                    ? '楼主 层主'
                                    : '楼主'
                                : widget.comment.replyToName ==
                                            widget.ancestorName &&
                                        widget.comment.replyTo !=
                                            widget.ancestorUId
                                    ? '层主'
                                    : ''
                            : '',
                        false),
                  // if (widget.isSubFloor &&
                  //     widget.comment.replyTo != widget.ancestorUId)
                  //   CommentIdentificationContainer(
                  //       '回复ID：' + widget.comment.replyTo.toString(), false),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 22.w),

        /*
        PopupMenuButton(
          padding: EdgeInsets.zero,
          shape: RacTangle(),
          offset: Offset(0, 0),
          child: SvgPicture.asset(
            'assets/svg_pics/lake_butt_icons/more_horizontal.svg',
            width: 18,
            color: Colors.black,
          ),
          onSelected: (value) async {
            if (value == '分享') {
              String weCo =
                  '我在微北洋发现了个有趣的问题评论，你也来看看吧~\n将本条微口令复制到微北洋求实论坛打开问题 wpy://school_project/${widget.comment.postId}\n【${widget.comment.content}】';
              ClipboardData data = ClipboardData(text: weCo);
              Clipboard.setData(data);
              CommonPreferences.feedbackLastWeCo.value =
                  widget.ancestorUId.toString();
              ToastProvider.success('微口令复制成功，快去给小伙伴分享吧！');
            }
            if (value == '举报') {
              Navigator.pushNamed(context, FeedbackRouter.report,
                  arguments: ReportPageArgs(widget.ancestorUId, false,
                      floorId: widget.comment.id));
            } else if (value == '删除') {
              bool confirm = await _showDeleteConfirmDialog('删除');
              if (confirm) {
                FeedbackService.deleteFloor(
                  id: widget.comment.id,
                  onSuccess: () {
                    ToastProvider.success(S.current.feedback_delete_success);
                    setState(() {
                      _isDeleted = true;
                    });
                  },
                  onFailure: (e) {
                    ToastProvider.error(e.error.toString());
                  },
                );
              }
            } else if (value == '删评') {
              bool confirm = await _showDeleteConfirmDialog('摧毁');
              if (confirm) {
                FeedbackService.adminDeleteReply(
                  floorId: widget.comment.id,
                  onSuccess: () {
                    ToastProvider.success(S.current.feedback_delete_success);
                    setState(() {
                      _isDeleted = true;
                    });
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
              if ((CommonPreferences.isSuper.value ||
                      CommonPreferences.isStuAdmin.value) ??
                  false)
                PopupMenuItem<String>(
                  value: '删评',
                  child: Center(
                    child: Text(
                      '删评',
                      style:
                          TextUtil.base.dangerousRed.regular.NotoSansSC.sp(12),
                    ),
                  ),
                ),
            ];
          },
        ),*/
      ],
    );

    var commentContent = widget.comment.content == ''
        ? SizedBox()
        : ClipCopy(
            id: widget.comment.id,
            copy: widget.comment.content,
            toast: '复制评论成功',
            child: ExpandableText(
              text: widget.comment.content,
              maxLines: !widget.isFullView && widget.isSubFloor ? 3 : 8,
              style: TextUtil.base.w400.NotoSansSC.black2A.h(1.2).sp(16),
              expand: false,
              buttonIsShown: true,
              isHTML: false,
            ),
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
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: WePeiYangApp.screenWidth * 2),
                        child: WpyPic(
                          picBaseUrl + 'origin/' + widget.comment.imageUrl,
                          withHolder: true,
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            child: WpyPic(
                              picBaseUrl + 'thumb/' + widget.comment.imageUrl,
                              width: 70,
                              height: 64,
                              fit: BoxFit.cover,
                              withHolder: true,
                            )),
                        Spacer()
                      ],
                    )),
        ));

    var subFloor;
    if (widget.comment.subFloors != null && !widget.isSubFloor) {
      subFloor = ListView.custom(
        key: Key('nCommentCardView'),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        controller: _sc,
        childrenDelegate: SliverChildBuilderDelegate(
          (context, index) {
            return NCommentCard(
              uid: widget.uid,
              ancestorName: widget.comment.nickname,
              ancestorUId: widget.comment.id,
              comment: widget.comment.subFloors[index],
              commentFloor: index + 1,
              isSubFloor: true,
              isFullView: widget.isFullView,
            );
          },
          childCount: widget.isFullView
              ? widget.comment.subFloorCnt
              : widget.comment.subFloorCnt > 4
                  ? 4
                  : min(widget.comment.subFloorCnt,
                      widget.comment.subFloors.length),
          findChildIndexCallback: (key) {
            final ValueKey<String> valueKey = key;
            return widget.comment.subFloors
                .indexWhere((m) => 'ncm-${m.id}' == valueKey.value);
          },
        ),
      );
    }

    var likeWidget = IconWidget(IconType.like, count: widget.comment.likeCount,
        onLikePressed: (isLiked, count, success, failure) async {
      await FeedbackService.commentHitLike(
        id: widget.comment.id,
        isLike: widget.comment.isLike,
        onSuccess: () {
          widget.comment.isLike = !widget.comment.isLike;
          widget.comment.likeCount = count;
          if (widget.comment.isLike && widget.comment.isDis) {
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
    }, isLike: widget.comment.isLike ?? false);

    var dislikeWidget = DislikeWidget(
      size: 15.w,
      isDislike: widget.comment.isDis ?? false,
      onDislikePressed: (dislikeNotifier) async {
        await FeedbackService.commentHitDislike(
          id: widget.comment.id,
          isDis: widget.comment.isDis,
          onSuccess: () {
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
          child: Text(
            DateTime.now().difference(widget.comment.createAt).inHours >= 11
                ? widget.comment.createAt
                    .toLocal()
                    .toIso8601String()
                    .replaceRange(10, 11, ' ')
                    .substring(0, 19)
                : DateTime.now()
                    .difference(widget.comment.createAt)
                    .dayHourMinuteSecondFormatted(),
            style: TextUtil.base.ProductSans.grey97.regular.sp(12),
          ),
        ),
      ],
    );

    var mainBody = Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: DateTime.now().month == 4 && DateTime.now().day == 1 ? 18 : 34,
        height: DateTime.now().month == 4 && DateTime.now().day == 1 ? 18 : 34,
        child: ProfileImageWithDetailedPopup(
            widget.type, widget.comment.nickname, widget.comment.uid),
      ),
      SizedBox(width: 10.w),
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            topWidget,
            SizedBox(height: 6),
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
            SizedBox(height: 2),
            bottomWidget,
            SizedBox(height: 4)
          ],
        ),
      )
    ]);

    return _isDeleted
        ? SizedBox(height: 1)
        : Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    // 这个Ink是为了确保body -> bottomWidget -> reportWidget的波纹效果正常显示
                    child: Container(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 14.w, 8.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: CommonPreferences.isSkinUsed.value
                            ? Color(CommonPreferences.skinColorE.value)
                            : widget.isFullView && widget.isSubFloor
                                ? Colors.transparent
                                : Colors.white,
                      ),
                      child: mainBody,
                    ),
                  ),
                  if (!widget.isSubFloor &&
                      !widget.isFullView &&
                      subFloor != null)
                    Padding(
                        padding: EdgeInsets.only(left: 40),
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
                                    arguments: ReplyDetailPageArgs(
                                        widget.comment, widget.uid),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(58.w, 0, 0, 0),
                                      // 这里的 padding 是用于让查看全部几条回复的部分与点赞图标对齐
                                      child: Text(
                                          widget.comment.subFloorCnt > 2
                                              ? '查看全部 ' +
                                                  widget.comment.subFloorCnt
                                                      .toString() +
                                                  ' 条回复 >'
                                              : '查看回复详情 >',
                                          style: TextUtil.base.NotoSansSC.w400
                                              .sp(14)
                                              .blue2C),
                                    ),
                                    Spacer()
                                  ],
                                ),
                              )
                          ],
                        )),
                ],
              ),
              Positioned(top: 8.w, right: 4.w, child: commentMenuButton)
            ],
          );
  }
}

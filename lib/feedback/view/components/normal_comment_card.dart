import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/level_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/splitscreen_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/clip_copy.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/icon_widget.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/long_text_shower.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/round_taggings.dart';
import 'package:we_pei_yang_flutter/feedback/view/image_view/image_view_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/reply_detail_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/report_question_page.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/main.dart';

import '../../../commons/themes/template/wpy_theme_data.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/widgets/w_button.dart';

typedef LikeCallback = void Function(bool, int);
typedef DislikeCallback = void Function(bool);

class NCommentCard extends StatefulWidget {
  final String ancestorName;
  final int ancestorUId;
  final Floor comment;
  final int uid;
  final int commentFloor;
  final int? type;
  final LikeCallback? likeSuccessCallback;
  final DislikeCallback? dislikeSuccessCallback;
  final bool isSubFloor;
  final bool isFullView;
  final bool showBlockButton;
  final bool expandAll;

  @override
  _NCommentCardState createState() => _NCommentCardState();

  NCommentCard({
    required this.ancestorName,
    required this.ancestorUId,
    required this.comment,
    required this.uid,
    required this.commentFloor,
    this.likeSuccessCallback,
    this.dislikeSuccessCallback,
    required this.isSubFloor,
    required this.isFullView,
    this.type,
    this.showBlockButton = false,
    this.expandAll = false,
  });
}

class _NCommentCardState extends State<NCommentCard>
    with SingleTickerProviderStateMixin {
  //final String picBaseUrl = 'https://qnhdpic.twt.edu.cn/download/';
  final String picBaseUrl = '${EnvConfig.QNHDPIC}download/';
  bool _picFullView = false, _isDeleted = false;

  Future<bool?> _showDeleteConfirmDialog(String quote) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return LakeDialogWidget(
          title: '$quote评论',
          content: Text('您确定要$quote这条评论吗？'),
          cancelText: "取消",
          confirmTextStyle:
              TextUtil.base.normal.label(context).NotoSansSC.sp(16).w400,
          cancelTextStyle:
              TextUtil.base.normal.label(context).NotoSansSC.sp(16).w600,
          confirmText: quote == '摧毁' ? 'BOOM' : "确认",
          cancelFun: () {
            Navigator.of(context).pop();
          },
          confirmFun: () {
            Navigator.of(context).pop(true);
          },
        );
      },
    );
  }

  ///弹出评论置顶窗口
  Future<bool?> _showFloorUpDialog(String id) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return Stack(
          children: [
            AdminPopUp(floorId: id),
          ],
        );
      },
    );
  }

  ///评论置顶重置
  cleanTopFloor(String id) async {
    await FeedbackService.adminFloorTopPost(
      id: id,
      hotIndex: 0,
      onSuccess: () {
        ToastProvider.success('重置成功');
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
      },
    );
  }

  ///判断管理员权限
  bool get hasAdmin =>
      CommonPreferences.isSchAdmin.value ||
      CommonPreferences.isStuAdmin.value ||
      CommonPreferences.isSuper.value;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("==> change dependencies");
  }

  @override
  Widget build(BuildContext context) {
    _picFullView = widget.expandAll || _picFullView;
    var commentMenuButton = WButton(
        child: Padding(
          padding: EdgeInsets.fromLTRB(SplitUtil.w * 12, 0, 0, 0),
          child: SvgPicture.asset(
            'assets/svg_pics/lake_butt_icons/more_horizontal.svg',
            width: 18.r,
            colorFilter: ColorFilter.mode(
                WpyTheme.of(context).get(WpyColorKey.basicTextColor),
                BlendMode.srcIn),
          ),
        ),
        onPressed: () {
          showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: WpyTheme.of(context).brightness,
                ),
                child: CupertinoActionSheet(
                  actions: <Widget>[
                    if (hasAdmin)
                      CupertinoActionSheetAction(
                        onPressed: () {
                          cleanTopFloor(widget.comment.id.toString())
                              .then((_) => Navigator.pop(context));
                        },
                        child: Text(
                          "恢复原评论状态（取消置顶）",
                          style: TextUtil.base.normal.w400.NotoSansSC
                              .primary(context)
                              .sp(16),
                        ),
                      ),

                    if (hasAdmin)
                      CupertinoActionSheetAction(
                        onPressed: () {
                          _showFloorUpDialog(widget.comment.id.toString())
                              .then((value) => Navigator.pop(context));
                        },
                        child: Text(
                          "评论置顶",
                          style: TextUtil.base.normal.w400.NotoSansSC
                              .primary(context)
                              .sp(16),
                        ),
                      ),

                    // 拉黑按钮
                    if (Platform.isIOS && widget.showBlockButton)
                      // 分享按钮
                      CupertinoActionSheetAction(
                        onPressed: () {
                          ToastProvider.success('拉黑用户成功');
                          Navigator.pop(context);
                        },
                        child: Text(
                          '拉黑',
                          style: TextUtil.base.normal.w400.NotoSansSC
                              .primary(context)
                              .sp(16),
                        ),
                      ),
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
                        FeedbackService.postShare(
                            id: widget.ancestorUId.toString(),
                            type: 0,
                            onSuccess: () {},
                            onFailure: () {});
                      },
                      child: Text(
                        '分享',
                        style: TextUtil.base.normal.w400.NotoSansSC
                            .primary(context)
                            .sp(16),
                      ),
                    ),
                    CupertinoActionSheetAction(
                      onPressed: () {
                        Navigator.pop(context);
                        if (Provider.of<NewFloorProvider>(context,
                                listen: false)
                            .inputFieldEnabled) {
                          context.read<NewFloorProvider>().clearAndClose();
                        } else {
                          Provider.of<NewFloorProvider>(context, listen: false)
                              .inputFieldOpenAndReplyTo(widget.comment.id);
                          //TODO:自动弹出键盘会无法获取焦点（？
                          // FocusScope.of(context).requestFocus(
                          //     Provider.of<NewFloorProvider>(context, listen: false)
                          //         .focusNode);
                        }
                      },
                      child: Text(
                        '回复',
                        style: TextUtil.base.normal.w400.NotoSansSC
                            .primary(context)
                            .sp(16),
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
                        style: TextUtil.base.normal.w400.NotoSansSC
                            .primary(context)
                            .sp(16),
                      ),
                    ),
                    widget.comment.isOwner
                        ? CupertinoActionSheetAction(
                            onPressed: () async {
                              bool? confirm =
                                  await _showDeleteConfirmDialog('删除');
                              if (confirm ?? false) {
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
                              style: TextUtil.base.normal.w400.NotoSansSC
                                  .primary(context)
                                  .sp(16),
                            ),
                          )
                        : CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, FeedbackRouter.report,
                                  arguments: ReportPageArgs(
                                      widget.ancestorUId, false,
                                      floorId: widget.comment.id));
                            },
                            child: Text(
                              '举报',
                              style: TextUtil.base.normal.w400.NotoSansSC
                                  .primary(context)
                                  .sp(16),
                            ),
                          ),
                    if (CommonPreferences.isSuper.value ||
                        CommonPreferences.isStuAdmin.value)
                      CupertinoActionSheetAction(
                        onPressed: () async {
                          bool? confirm = await _showDeleteConfirmDialog('摧毁');
                          if (confirm ?? false) {
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
                          style: TextUtil.base.normal.w400.NotoSansSC
                              .primary(context)
                              .sp(16),
                        ),
                      ),
                  ],
                  cancelButton: CupertinoActionSheetAction(
                    // 取消按钮
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '取消',
                      style: TextUtil.base.normal.w400.NotoSansSC
                          .primary(context)
                          .sp(16),
                    ),
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
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: (SplitUtil.sw - SplitUtil.toolbarWidth) * 0.37),
                child: Text(
                  widget.comment.nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextUtil.base.w400.bold.NotoSansSC.sp(16).label(context),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: SplitUtil.w * 4),
                child: LevelUtil(
                  style: TextUtil.base.bright(context).bold.sp(7),
                  level: widget.comment.level.toString(),
                ),
              ),
              CommentIdentificationContainer(
                  widget.comment.isOwner
                      ? '我的评论'
                      : widget.comment.uid == widget.uid
                          ? widget.isSubFloor &&
                                  widget.comment.nickname == widget.ancestorName
                              ? '楼主 层主'
                              : '楼主'
                          : widget.isSubFloor &&
                                  widget.comment.nickname == widget.ancestorName
                              ? '层主'
                              : '',
                  true),
              // 回复自己那条时出现
              if (widget.comment.replyToName != '' &&
                  widget.comment.replyTo != widget.ancestorUId)
                widget.comment.isOwner &&
                        widget.comment.replyToName == widget.comment.nickname
                    ? CommentIdentificationContainer('回复我', true)
                    : SizedBox(),
              // 后面有东西时出现
              if (widget.comment.replyToName != '' &&
                  widget.comment.replyTo != widget.ancestorUId)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: SplitUtil.w * 2),
                    Icon(Icons.play_arrow, size: SplitUtil.w * 6),
                    SizedBox(width: SplitUtil.w * 2),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth:
                              (SplitUtil.sw - SplitUtil.toolbarWidth) * 0.37),
                      child: Text(
                        widget.comment.replyToName.isEmpty
                            ? ""
                            : widget.comment.replyToName.length > 8
                                ? "${widget.comment.replyToName.substring(0, 7)}..."
                                : widget.comment.replyToName,
                        style:
                            TextUtil.base.w700.NotoSansSC.sp(16).label(context),
                      ),
                    ),
                    SizedBox(width: 2)
                  ],
                ),
              // 回的是楼主并且楼主不是层主或者楼主是层主的时候回复的不是这条评论
              // 回的是层主但回复的不是这条评论
              if (!widget.comment.isOwner &&
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
                                    widget.comment.replyTo != widget.ancestorUId
                                ? '楼主 层主'
                                : '楼主'
                            : widget.comment.replyToName ==
                                        widget.ancestorName &&
                                    widget.comment.replyTo != widget.ancestorUId
                                ? '层主'
                                : ''
                        : '',
                    false),
              // if (widget.isSubFloor &&
              //     widget.comment.replyTo != widget.ancestorUId)
              //   CommentIdentificationContainer(
              //       '回复ID：' + widget.comment.replyTo.toString(), false),
              if (widget.comment.value != 0)
                Text(
                  "  置顶评论",
                  style: TextUtil.base.w500.NotoSansSC
                      .sp(10)
                      .primaryAction(context),
                ),
            ],
          ),
        ),
        commentMenuButton
      ],
    );

    Widget commentContent;
    WpyTheme.of(context);
    if (widget.comment.content == '') {
      commentContent = SizedBox();
    } else {
      // Row + Expanded 来把这里扩展开 不知道有没有更好的办法
      commentContent = Row(children: [
        Expanded(
          child: CommentCardGestureDetector(
            isOfficial: false,
            id: widget.comment.id,
            copy: widget.comment.content,
            toast: '复制评论成功',
            child: Builder(builder: (context) {
              return ExpandableText(
                text: widget.comment.content,
                maxLines: !widget.isFullView && widget.isSubFloor ? 3 : 8,
                style:
                    TextUtil.base.w400.NotoSansSC.label(context).h(1.8).sp(14),
                expand: false || widget.expandAll,
                buttonIsShown: true,
                isHTML: false,
                replyTo: widget.comment.replyToName,
              );
            }),
          ),
        ),
      ]);
    }

    var commentImage = Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: AnimatedSize(
          duration: Duration(milliseconds: 150),
          curve: Curves.decelerate,
          child: widget.comment.content != ''
              ? WButton(
                  onPressed: () {
                    setState(() {
                      _picFullView = true;
                    });
                  },
                  child: _picFullView
                      ? WButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              FeedbackRouter.imageView,
                              arguments: ImageViewPageArgs(
                                  [widget.comment.imageUrl], 1, 0, false),
                            );
                          },
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxHeight: WePeiYangApp.screenWidth * 2),
                            child: WpyPic(
                              picBaseUrl + 'origin/' + widget.comment.imageUrl,
                              withHolder: true,
                              holderHeight: SplitUtil.w * 64,
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                                child: WpyPic(
                                  '${picBaseUrl}thumb/${widget.comment.imageUrl}',
                                  width: SplitUtil.w * 68,
                                  height: SplitUtil.w * 68,
                                  fit: BoxFit.cover,
                                  withHolder: true,
                                )),
                            Spacer()
                          ],
                        ))
              : _picFullView
                  ? WButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          FeedbackRouter.imageView,
                          arguments: ImageViewPageArgs(
                              [widget.comment.imageUrl], 1, 0, false),
                        );
                      },
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxHeight: SplitUtil.sh * 2),
                        child: WpyPic(
                          '${picBaseUrl}origin/${widget.comment.imageUrl}',
                          withHolder: true,
                          holderHeight: SplitUtil.w * 64,
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        WButton(
                          onPressed: () {
                            setState(() {
                              _picFullView = true;
                            });
                          },
                          child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              child: WpyPic(
                                '${picBaseUrl}thumb/${widget.comment.imageUrl}',
                                width: SplitUtil.w * 68,
                                height: SplitUtil.w * 68,
                                fit: BoxFit.cover,
                                withHolder: true,
                              )),
                        ),
                        Expanded(
                            child: WButton(
                                onPressed: () {
                                  if (Provider.of<NewFloorProvider>(context,
                                          listen: false)
                                      .inputFieldEnabled) {
                                    Provider.of<NewFloorProvider>(context,
                                            listen: false)
                                        .clearAndClose();
                                  } else {
                                    Provider.of<NewFloorProvider>(context,
                                            listen: false)
                                        .inputFieldOpenAndReplyTo(
                                            widget.comment.id);
                                    FocusScope.of(context).requestFocus(
                                        Provider.of<NewFloorProvider>(context,
                                                listen: false)
                                            .focusNode);
                                  }
                                },
                                child: Container(
                                    height: SplitUtil.w * 68,
                                    color: Colors.transparent)))
                      ],
                    ),
        ));

    var subFloor;
    if (!widget.isSubFloor) {
      subFloor = ListView.custom(
        key: Key('nCommentCardView'),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
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
              expandAll: widget.expandAll,
            );
          },
          childCount: widget.isFullView
              ? widget.comment.subFloorCnt
              : widget.comment.subFloorCnt > 4
                  ? 4
                  : min(widget.comment.subFloorCnt,
                      widget.comment.subFloors.length),
          findChildIndexCallback: (key) {
            return widget.comment.subFloors.indexWhere(
                (m) => 'ncm-${m.id}' == (key as ValueKey<String>).value);
          },
        ),
      );
    }

    var likeWidget = IconWidget(IconType.like,
        count: widget.comment.likeCount,
        size: 15.r, onLikePressed: (isLiked, count, success, failure) async {
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
    }, isLike: widget.comment.isLike);

    var dislikeWidget = DislikeWidget(
      size: 15.r,
      isDislike: widget.comment.isDis,
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
        Text(
          DateTime.now().difference(widget.comment.createAt!).inHours >= 11
              ? widget.comment.createAt!
                  .toLocal()
                  .toIso8601String()
                  .replaceRange(10, 11, ' ')
                  .replaceAllMapped('-', (_) => '/')
                  .substring(2, 19)
              : DateTime.now()
                  .difference(widget.comment.createAt!)
                  .dayHourMinuteSecondFormatted(),
          style: TextUtil.base.ProductSans
              .secondaryInfo(context)
              .regular
              .sp(12)
              .space(letterSpacing: 0.6),
        ),
      ],
    );

    var mainBody = Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ProfileImageWithDetailedPopup(
          widget.comment.id,
          false,
          widget.type ?? 0,
          widget.comment.avatar,
          widget.comment.uid,
          widget.comment.nickname,
          widget.comment.level.toString(),
          widget.comment.id.toString(),
          widget.comment.avatarBox.toString()),
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: SplitUtil.h * 9),
            topWidget,
            SizedBox(height: SplitUtil.h * 4),
            commentContent,
            if (widget.comment.imageUrl != '') commentImage,
            if (_picFullView == true && widget.comment.imageUrl != '')
              TextButton(
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
                          style: TextUtil.base
                              .infoText(context)
                              .w800
                              .NotoSansSC
                              .sp(12)),
                    ],
                  ))
            else
              SizedBox(height: SplitUtil.h * 8),
            bottomWidget,
            SizedBox(height: SplitUtil.h * 4)
          ],
        ),
      ),
      SizedBox(width: SplitUtil.w * 16)
    ]);

    return _isDeleted
        ? SizedBox(height: 1)
        : Stack(
            children: [
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, SplitUtil.h * 6),
                    color: Colors.transparent,
                    child: mainBody,
                  ),
                  if (!widget.isSubFloor &&
                      !widget.isFullView &&
                      subFloor != null)
                    Padding(
                        padding: EdgeInsets.only(left: 44.w),
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
                                    SizedBox(width: 58.w),
                                    // 这里的 padding 是用于让查看全部几条回复的部分与点赞图标对齐
                                    Text(
                                        widget.comment.subFloorCnt > 2
                                            ? '查看全部 ' +
                                                widget.comment.subFloorCnt
                                                    .toString() +
                                                ' 条回复 >'
                                            : '查看回复详情 >',
                                        style: TextUtil.base.NotoSansSC.w400
                                            .sp(12)
                                            .primaryAction(context)),
                                    Spacer()
                                  ],
                                ),
                              ),
                            SizedBox(height: SplitUtil.h * 12)
                          ],
                        )),
                ],
              ),
              // Positioned(right: 8.w, child: commentMenuButton)
            ],
          );
  }
}

class AdminPopUp extends StatefulWidget {
  final String floorId;

  const AdminPopUp({Key? key, required this.floorId}) : super(key: key);

  State<StatefulWidget> createState() => AdminPopUpState();
}

class AdminPopUpState extends State<AdminPopUp> {
  TextEditingController tc = TextEditingController();

  adminTopFloor(String id, String index) async {
    await FeedbackService.adminFloorTopPost(
      id: id,
      hotIndex: index,
      onSuccess: () {
        ToastProvider.success('置顶成功');
        Navigator.pop(context);
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Container(
      padding: EdgeInsets.symmetric(
          horizontal: SplitUtil.w * 8, vertical: SplitUtil.h * 8),
      margin: EdgeInsets.all(SplitUtil.sw * 0.1),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(height: SplitUtil.h * 4),
            Center(
                child: Text("评论置顶",
                    style:
                        TextUtil.base.NotoSansSC.w500.sp(16).label(context))),
            SizedBox(
              height: SplitUtil.h * 20,
            ),
            TextField(
              controller: tc,
              decoration: InputDecoration(
                  hintMaxLines: 2,
                  hintText: "评论置顶值，0-3000，0为取消置顶",
                  hintStyle: TextUtil.base.label(context).bold.w500.sp(14),
                  filled: true,
                  fillColor:
                      WpyTheme.of(context).get(WpyColorKey.oldSwitchBarColor),
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.fromLTRB(15, 18, 0, 18),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide.none)),
            ),
            SizedBox(
              height: SplitUtil.h * 20,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  adminTopFloor(widget.floorId, tc.text);
                },
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(2),
                  backgroundColor: MaterialStateProperty.all(
                      WpyTheme.of(context)
                          .get(WpyColorKey.secondaryBackgroundColor)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                child: Text("确认",
                    style: TextUtil.base.NotoSansSC.w500.sp(14).label(context)),
              ),
            )
          ]),
    ));
  }
}

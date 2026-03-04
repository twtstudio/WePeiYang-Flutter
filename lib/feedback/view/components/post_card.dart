import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/util/level_util.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/splitscreen_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/icon_widget.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/long_text_shower.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/round_taggings.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/view/post_pic/post_detail_pic.dart';
import 'package:we_pei_yang_flutter/feedback/view/post_pic/post_preview_pic.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';

class PostCardNormal extends StatefulWidget {
  /// 标准 PostCard
  ///
  /// 包括论坛首页展示的 (outer = true / null) 和 详情页展示的 (outer = false)
  ///
  /// 考古,需要分解其中图片的逻辑

  PostCardNormal(this.post,
      {this.outer = true,
      this.screenshotController,
      this.expandAll = false,
      this.avatarClickable = true});

  final bool expandAll;
  final Post post;
  final bool avatarClickable;

  final ScreenshotController? screenshotController;

  /// 以下默认 outer
  final bool outer;

  @override
  State<StatefulWidget> createState() => _PostCardNormalState(this.post);
}

class _PostCardNormalState extends State<PostCardNormal> {
  Post post;

  final String picBaseUrl = '${EnvConfig.QNHDPIC}download/';

  _PostCardNormalState(this.post);

  /// 通过分区编号获取分区名称 by pushInl
  String getTypeName(int type) {
    Map<int, String> typeName = {};
    LakeUtil.tabList.forEach((e) {
      typeName.addAll({e.id: e.shortname});
    });
    return typeName[type] ?? '';
  }

  Widget _buildMainContent() {
    if (widget.post.variant == PostVariant.Vote)
      return VoteWidget(post: widget.post, interactive: !widget.outer);

    if (widget.outer) {
      return Text(post.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextUtil.base.NotoSansSC.w400.sp(14).primary(context).h(1.4));
    }
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: post.content));
        ToastProvider.success('复制评论成功');
      },
      child: Padding(
        padding: EdgeInsets.only(top: 15.h),
        child: ExpandableText(
          text: post.content,
          maxLines: 8,
          style: TextUtil.base.NotoSansSC.w400.sp(15).primary(context).h(1.7).copyWith(
              letterSpacing: 0.7,
            wordSpacing: 2.0
          ),
          expand: widget.expandAll,
          buttonIsShown: true,
          isHTML: false,
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    /// 头像昵称时间MP已解决
    var avatarAndSolve = SizedBox(
        height: SplitUtil.w * 32 > SplitUtil.h * 56
            ? SplitUtil.w * 32
            : SplitUtil.h * 56,
        child: Row(children: [
          IgnorePointer(
            ignoring: !widget.avatarClickable,
            child: Builder(builder: (context) {
              return ProfileImageWithDetailedPopup(
                  post.id,
                  true,
                  post.type,
                  post.avatar,
                  post.uid,
                  post.nickname,
                  post.level.toString(),
                  post.id.toString(),
                  post.avatarBox.toString());
            }),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
                color: Colors.transparent, // 没他就没有点击域
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: (SplitUtil.sw - SplitUtil.w * 24) / 2 -
                                  SplitUtil.w * 16,
                            ),
                            child: Text(
                              post.nickname == '' ? '没名字的微友' : post.nickname,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextUtil.base.w400.NotoSansSC
                                  .sp(16)
                                  .primary(context),
                            ),
                          ),
                          SizedBox(width: SplitUtil.w * 4),
                          LevelUtil(
                            style: TextUtil.base.bright(context).bold.sp(7),
                            level: post.level.toString(),
                          ),
                        ],
                      ),
                      SizedBox(height: SplitUtil.h * 4),
                      Text(
                        DateFormat('yyyy-MM-dd HH:mm:ss')
                            .format(post.createAt!.toLocal()),
                        textAlign: TextAlign.left,
                        style: TextUtil.base
                            .secondary(context)
                            .normal
                            .ProductSans
                            .sp(10),
                      )
                    ])),
          ),
          // Spacer(),
          if (post.type == 1)
            SolveOrNotWidget(post.solved)
          else
            GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(
                        text: '#MP' + post.id.toString().padLeft(6, '0')))
                    .whenComplete(
                        () => ToastProvider.success('复制帖子id成功，快去分享吧！'));
              },
              child: Text(
                '#MP' + post.id.toString().padLeft(6, '0'),
                style: TextUtil.base.w400.infoText(context).NotoSansSC.sp(12),
              ),
            ),
        ]));

    /// 标题eTag 指的是 活动 Pined 等等
    var eTagAndTitle = Row(children: [
      if (post.eTag != '')
        Center(child: ETagWidget(entry: widget.post.eTag, full: !widget.outer)),
      Expanded(
        child: Text(
          post.title,
          maxLines: widget.outer ? 1 : 10,
          overflow: TextOverflow.ellipsis,
          style: TextUtil.base.w400.NotoSansSC.sp(20).primary(context).bold,
        ),
      )
    ]);

    /// 帖子内容
    var content = _buildMainContent();

    /// 评论点赞点踩浏览量
    var likeUnlikeVisit = _buildActionFooter();

    /// tag校区浏览量
    var tagCampusVisit = _buildTagFooter();

    // avatarAndSolve、eTagAndTitle、content的统一list
    // （因为 outer 和 inner 的这部分几乎完全相同）
    List<Widget> head = [
      avatarAndSolve,
      if (post.variant != PostVariant.Vote) eTagAndTitle,
      if (post.content.isNotEmpty) content,
      // 行数的区别在内部判断
      SizedBox(height: SplitUtil.h * 10)
    ];

    /////////////////////////////////////////////////////////
    ///           ↓ build's return is here  ↓             ///
    /////////////////////////////////////////////////////////

    return Screenshot(
      controller: widget.screenshotController ?? ScreenshotController(),
      child: Container(
        color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        child: Builder(builder: (context) {
          if (widget.outer) {
            return GestureDetector(
              onTap: () {
                FeedbackService.visitPost(
                    id: widget.post.id, onFailure: (_) {});
                Navigator.pushNamed(
                  context,
                  FeedbackRouter.detail,
                  arguments: post,
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12.h),
                color: WpyTheme.of(context)
                    .get(WpyColorKey.primaryBackgroundColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...head,
                    //此处为图片
                    Center(
                        child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: PostPreviewPic(imgUrls: post.imageUrls),
                    )),
                    SizedBox(height: 2),
                    likeUnlikeVisit
                  ],
                ),
              ),
            );
          } else {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.lightBorderColor),
                          width: 1.h))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...head,
                  PostDetailPic(imgUrls: post.imageUrls),
                  SizedBox(height: 4),
                  tagCampusVisit,
                ],
              ),
            );
          }
        }),
      ),
    );

    /////////////////////////////////////////////////////////
    ///           ↑ build's return is here  ↑             ///
    /////////////////////////////////////////////////////////
  }

  Row _buildTagFooter() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (post.tag != null)
            TagShowWidget(
                post.tag!.name,
                (SplitUtil.sw - SplitUtil.w * 24) / 2 -
                    (post.campus > 0 ? SplitUtil.w * 100 : SplitUtil.w * 60),
                post.type,
                post.tag!.id,
                0,
                post.type),
          if (post.tag != null) SizedBox(width: SplitUtil.w * 8),
          TagShowWidget(getTypeName(post.type), 100, 0, 0, post.type, 0),
          if (post.campus != 0)
            Container(
              height: 14,
              width: 14,
              alignment: Alignment.center,
              margin: EdgeInsets.fromLTRB(3, 3, 2, 3),
              padding: EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: WpyTheme.of(context).get(WpyColorKey.tagLabelColor)),
              child: SvgPicture.asset(
                  "assets/svg_pics/lake_butt_icons/hashtag.svg"),
            ),
          if (post.campus != 0) SizedBox(width: SplitUtil.w * 2),
          if (post.campus != 0)
            ConstrainedBox(
              constraints: BoxConstraints(),
              child: Text(
                const ['', '卫津路', '北洋园'][post.campus],
                style:
                    TextUtil.base.NotoSansSC.w400.sp(14).primaryAction(context),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          SizedBox(width: 8),
          if (post.department != null) ...[
            Container(
              height: 14,
              width: 14,
              alignment: Alignment.center,
              margin: EdgeInsets.fromLTRB(3, 3, 2, 3),
              padding: EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: WpyTheme.of(context).get(WpyColorKey.tagLabelColor),
              ),
              child: SvgPicture.asset(
                "assets/svg_pics/lake_butt_icons/hashtag.svg",
              ),
            ),
            SizedBox(width: SplitUtil.w * 2),
            // Text(
            //   "部门: ",
            //   style:
            //       TextUtil.base.NotoSansSC.w400.sp(14).primaryAction(context),
            // ),
            ConstrainedBox(
              constraints: BoxConstraints(),
              child: Text(
                post.department!.name,
                style: TextUtil.base.NotoSansSC.w400
                    .sp(14)
                    .primaryAction(context)
                    .copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          SizedBox(width: 8),
          Spacer(),
          Text(
            post.visitCount.toString() + "次浏览",
            style: TextUtil.base.ProductSans
                .secondaryInfo(context)
                .normal
                .sp(10)
                .w400,
          )
        ]);
  }

  Row _buildActionFooter() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset("assets/svg_pics/lake_butt_icons/comment.svg",
              colorFilter: ColorFilter.mode(
                  WpyTheme.of(context).get(WpyColorKey.infoTextColor),
                  BlendMode.srcIn),
              width: 11.67.r),
          SizedBox(width: 3.r),
          Text(
            post.commentCount.toString() + '   ',
            style:
                TextUtil.base.ProductSans.primary(context).normal.sp(12).w700,
          ),
          IconWidget(
            IconType.like,
            size: 15.r,
            count: post.likeCount,
            onLikePressed: (isLike, likeCount, success, failure) async {
              await FeedbackService.postHitLike(
                id: post.id,
                isLike: post.isLike,
                onSuccess: () {
                  post.isLike = !post.isLike;
                  post.likeCount = likeCount;
                  if (post.isLike && post.isDis) {
                    post.isDis = !post.isDis;
                    setState(() {});
                  }
                  success.call();
                },
                onFailure: (e) {
                  ToastProvider.error(e.error.toString());
                  failure.call();
                },
              );
            },
            isLike: post.isLike,
          ),
          DislikeWidget(
            size: 15.r,
            isDislike: widget.post.isDis,
            onDislikePressed: (dislikeNotifier) async {
              await FeedbackService.postHitDislike(
                id: post.id,
                isDisliked: post.isDis,
                onSuccess: () {
                  post.isDis = !post.isDis;
                  if (post.isLike && post.isDis) {
                    post.isLike = !post.isLike;
                    post.likeCount--;
                    setState(() {});
                  }
                },
                onFailure: (e) {
                  ToastProvider.error(e.error.toString());
                },
              );
            },
          ),
          Spacer(),
          Text(
            post.visitCount.toString() + "次浏览",
            style: TextUtil.base.ProductSans
                .secondaryInfo(context)
                .normal
                .sp(10)
                .w400,
          )
        ]);
  }
}

class VoteWidget extends StatefulWidget {
  final Post post;

  // 是否可交互
  final bool interactive;

  const VoteWidget({
    super.key,
    required this.post,
    required this.interactive,
  });

  @override
  State<VoteWidget> createState() => _VoteWidgetState();
}

class _VoteWidgetState extends State<VoteWidget> {
  late bool showResult = !widget.interactive ||
      widget.post.voteDetail!.options.any((e) => e.selected);

  late Post displayPost = widget.post;

  _reloadPost() {
    setState(() {
      displayPost.voteDetail!.options.forEach((element) {
        element.count = 0;
      });
    });
    FeedbackService.getPostById(
      id: displayPost.id,
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
      },
      onResult: (Post data) {
        setState(() {
          displayPost = data;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final footerStyle =
        TextUtil.base.w400.NotoSansSC.sp(12).secondaryInfo(context).h(1.6);
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
              border: Border.all(
                  color:
                      WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
                  width: 2),
              color:
                  WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
              borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayPost.title,
                style: TextUtil.base.w400.NotoSansSC.sp(16).primary(context),
              ),
              SizedBox(height: 8),
              if (displayPost.voteDetail != null) ...[
                AnimatedSize(
                  duration: Duration(milliseconds: 200),
                  alignment: Alignment.topCenter,
                  child: showResult
                      ? _buildResult(displayPost.voteDetail!.voteCount)
                      : VoteFormWidget(
                          post: displayPost,
                          voteCallback: () {
                            setState(() {
                              showResult = true;
                            });
                            _reloadPost();
                          }),
                ),
                // Footer
                Row(
                  children: [
                    Text(
                      "共 ${displayPost.voteDetail!.voteCount} 票",
                      style: footerStyle,
                    ),
                    if (widget.interactive) ...[
                      SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          setState(() {
                            showResult = !showResult;
                          });
                        },
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          child: Text(showResult ? "切换投票" : "切换结果",
                              key: ValueKey(showResult), style: footerStyle),
                        ),
                      ),
                    ],
                    Spacer(),
                    InkWell(
                      onTap: _reloadPost,
                      child: Text("Reload", style: footerStyle),
                    ),
                  ],
                ),
              ] else
                Center(
                  child: Text(
                    "该接口版本不支持投票",
                    style: footerStyle,
                  ),
                )
            ],
          ),
        ),
        Positioned(
          left: 24,
          top: 0,
          child: Container(
            height: 20,
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
                borderRadius: BorderRadius.circular(16)),
            child: Center(
              child: Text(
                'POLL',
                style: TextUtil.base.w400.NotoSansSC
                    .sp(10)
                    .bright(context)
                    .bold
                    .h(1.6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Column _buildResult(int totalVoteCount) {
    return Column(
      children: displayPost.voteDetail!.options
          .map((e) => VoteOptionWidget(
              option: e,
              selected: e.selected,
              percent: totalVoteCount == 0 ? 0 : e.count / totalVoteCount))
          .toList(),
    );
  }
}

class VoteFormWidget extends StatefulWidget {
  final Post post;
  final void Function() voteCallback;

  const VoteFormWidget(
      {super.key, required this.post, required this.voteCallback});

  @override
  State<VoteFormWidget> createState() => _VoteFormWidgetState();
}

class _VoteFormWidgetState extends State<VoteFormWidget> {
  late final selectedId = widget.post.voteDetail!.options
      .where((element) => element.selected)
      .map((e) => e.id)
      .toList();

  get enableButton => selectedId.isNotEmpty;

  bool voting = false;

  @override
  Widget build(BuildContext context) {
    final disableButtonStyle = ButtonStyle(
        padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 2)),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        backgroundColor: MaterialStateProperty.all(WpyTheme.of(context)
            .get(WpyColorKey.secondaryInfoTextColor)
            .withOpacity(0.3)));

    var disableButtonText =
        TextUtil.base.w400.NotoSansSC.sp(14).secondaryInfo(context).bold.h(1.6);
    final enableButtonText =
        TextUtil.base.w400.NotoSansSC.sp(14).bright(context).bold.h(1.6);
    final enableButtonStyle = ButtonStyle(
        padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 2)),
        side: MaterialStateProperty.all(BorderSide(
            color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor))),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        backgroundColor: MaterialStateProperty.all(
            WpyTheme.of(context).get(WpyColorKey.primaryActionColor)));

    return Column(children: [
      ...widget.post.voteDetail!.options
          .map((e) => Container(
                margin: EdgeInsets.only(top: 5.w),
                child: Row(
                  children: [
                    Transform.scale(
                      scale: 0.8,
                      child: Checkbox(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: selectedId.contains(e.id),
                        onChanged: (_) {
                          setState(() {
                            if (selectedId.contains(e.id)) {
                              selectedId.remove(e.id);
                            } else {
                              selectedId.add(e.id);
                              if (selectedId.length >
                                  widget.post.voteDetail!.maxSelection) {
                                selectedId.removeAt(0);
                              }
                            }
                          });
                        },
                        activeColor: WpyTheme.of(context)
                            .get(WpyColorKey.primaryActionColor),
                        side: BorderSide(
                            color: WpyTheme.of(context)
                                .get(WpyColorKey.primaryActionColor)),
                      ),
                    ),
                    Container(
                      width: 270.h,
                      child: Wrap(
                        children: [
                          Text(e.content,
                              style: TextUtil.base.w400.NotoSansSC
                                  .sp(14)
                                  .primary(context)
                                  .h(1.6)),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
      AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: enableButton && !voting
            ? ElevatedButton(
                key: ValueKey(1),
                onPressed: () async {
                  setState(() {
                    voting = true;
                  });
                  try {
                    await FeedbackService.updateVote(
                      id: widget.post.voteDetail!.id,
                      options: selectedId,
                    );
                  } catch (e) {
                    if (e is DioException)
                      ToastProvider.error(e.error.toString());
                    else {
                      ToastProvider.error("投票失败, 未知错误");
                      Logger.reportError(e, StackTrace.current);
                    }
                  }
                  setState(() {
                    voting = false;
                  });
                  widget.voteCallback();
                },
                child: Text("投票", style: enableButtonText),
                style: enableButtonStyle,
              )
            : ElevatedButton(
                key: ValueKey(0),
                onPressed: null,
                child: Text("投票", style: disableButtonText),
                style: disableButtonStyle,
              ),
      )
    ]);
  }
}

class VoteOptionWidget extends StatelessWidget {
  final VoteOption option;
  final double percent;
  final bool selected;

  const VoteOptionWidget(
      {super.key,
      required this.option,
      required this.percent,
      required this.selected});

  String formatPercent(double percent) {
    double percentValue = percent * 100;
    // 检查小数部分的第一位
    if (percentValue % 1 == 0) {
      // 如果小数部分为 0，返回整数部分
      return percentValue.toStringAsFixed(0);
    } else {
      // 否则，保留一位小数
      return percentValue.toStringAsFixed(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(top: 5.w),
              width: 230.h,
              child: Wrap(children: [
                Text(
                  option.content + (selected ? " (已选)" : ""),
                  style: TextUtil.base.w400.NotoSansSC
                      .sp(14)
                      .primary(context)
                      .h(1.6),
                ),
              ]),
            ),
            Spacer(),
            Text(
              "${option.count.toString()} 票 (${formatPercent(percent)}%)",
              style:
                  TextUtil.base.w400.NotoSansSC.sp(12).infoText(context).h(1.6),
            ),
          ],
        ),
        SizedBox(width: 8),
        TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: percent),
            duration: Duration(milliseconds: 100),
            builder: (context, value, child) {
              return LinearProgressIndicator(
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
                value: value,
                backgroundColor: WpyTheme.of(context)
                    .get(WpyColorKey.secondaryInfoTextColor)
                    .withOpacity(0.5),
                valueColor: AlwaysStoppedAnimation<Color>(WpyTheme.of(context)
                    .get(selected
                        ? WpyColorKey.successGreen
                        : WpyColorKey.primaryActionColor)),
              );
            }),
        SizedBox(height: 8),
      ],
    );
  }
}

class BottomLikeFavDislike extends StatefulWidget {
  final Post post;

  const BottomLikeFavDislike(this.post);

  @override
  State<BottomLikeFavDislike> createState() => _BottomLikeFavDislikeState();
}

class _BottomLikeFavDislikeState extends State<BottomLikeFavDislike> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: SplitUtil.w * 10),
        IconWidget(
          IconType.bottomLike,
          count: widget.post.likeCount,
          size: 22.r,
          onLikePressed: (isLike, likeCount, success, failure) async {
            await FeedbackService.postHitLike(
              id: widget.post.id,
              isLike: widget.post.isLike,
              onSuccess: () {
                widget.post.isLike = !widget.post.isLike;
                widget.post.likeCount = likeCount;
                if (widget.post.isLike && widget.post.isDis) {
                  widget.post.isDis = !widget.post.isDis;
                  setState(() {});
                }
                success.call();
              },
              onFailure: (e) {
                ToastProvider.error(e.error.toString());
                failure.call();
              },
            );
          },
          isLike: widget.post.isLike,
        ),
        IconWidget(
          IconType.bottomFav,
          count: widget.post.favCount,
          size: 22.r,
          onLikePressed: (isFav, favCount, success, failure) async {
            await FeedbackService.postHitFavorite(
              id: widget.post.id,
              isFavorite: widget.post.isFav,
              onSuccess: () {
                widget.post.isFav = !isFav;
                widget.post.favCount = favCount;
                success.call();
              },
              onFailure: (e) {
                ToastProvider.error(e.error.toString());
                failure.call();
              },
            );
          },
          isLike: widget.post.isFav,
        ),
        DislikeWidget(
          size: 22.r,
          isDislike: widget.post.isDis,
          onDislikePressed: (dislikeNotifier) async {
            await FeedbackService.postHitDislike(
              id: widget.post.id,
              isDisliked: widget.post.isDis,
              onSuccess: () {
                widget.post.isDis = !widget.post.isDis;
                if (widget.post.isLike && widget.post.isDis) {
                  widget.post.isLike = !widget.post.isLike;
                  widget.post.likeCount--;
                  setState(() {});
                }
              },
              onFailure: (e) {
                ToastProvider.error(e.error.toString());
              },
            );
          },
        ),
        SizedBox(width: SplitUtil.w * 10)
      ],
    );
  }
}

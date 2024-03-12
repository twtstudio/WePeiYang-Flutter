import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/util/level_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/splitscreen_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/icon_widget.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/long_text_shower.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/round_taggings.dart';
import 'package:we_pei_yang_flutter/feedback/view/image_view/image_view_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';
import 'package:we_pei_yang_flutter/main.dart';

import '../../../commons/themes/template/wpy_theme_data.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/widgets/w_button.dart';

class PostCardNormal extends StatefulWidget {
  /// 标准 PostCard
  ///
  /// 包括论坛首页展示的 (outer = true / null) 和 详情页展示的 (outer = false)

  PostCardNormal(this.post,
      {this.outer = true, this.screenshotController, this.expandAll = false});

  final bool expandAll;
  final Post post;

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
    context.read<LakeModel>().tabList.forEach((e) {
      typeName.addAll({e.id: e.shortname});
    });
    return typeName[type] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    /// 头像昵称时间MP已解决
    var avatarAndSolve = SizedBox(
        height: SplitUtil.w * 32 > SplitUtil.h * 56
            ? SplitUtil.w * 32
            : SplitUtil.h * 56,
        child: Row(children: [
          SizedBox(width: SplitUtil.w * 2),
          ProfileImageWithDetailedPopup(
              post.id,
              true,
              post.type,
              post.avatar,
              post.uid,
              post.nickname,
              post.level.toString(),
              post.id.toString(),
              post.avatarBox.toString()),
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
          if (post.type == 1) SolveOrNotWidget(post.solved),
          if (post.type != 1)
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
          SizedBox(width: SplitUtil.w * 16)
        ]));

    /// 标题eTag
    var eTagAndTitle = Row(children: [
      if (post.eTag != '')
        Center(child: ETagWidget(entry: widget.post.eTag, full: !widget.outer)),
      Expanded(
        child: Text(
          post.title,
          maxLines: widget.outer ? 1 : 10,
          overflow: TextOverflow.ellipsis,
          style: TextUtil.base.w400.NotoSansSC.sp(18).primary(context).bold,
        ),
      )
    ]);

    /// 帖子内容
    var content = Padding(
        padding: EdgeInsets.only(top: SplitUtil.h * 6),
        child: widget.outer
            ? Text(post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextUtil.base.NotoSansSC.w400
                    .sp(14)
                    .primary(context)
                    .h(1.4))
            : ExpandableText(
                text: post.content,
                maxLines: 8,
                style: TextUtil.base.NotoSansSC.w400
                    .sp(14)
                    .primary(context)
                    .h(1.6),
                expand: widget.expandAll,
                buttonIsShown: true,
                isHTML: false,
              ));

    /// 图片
    var outerImages =
        post.imageUrls.length == 1 ? outerSingleImage : outerMultipleImage;

    var innerImages = post.imageUrls.length == 1
        ? InnerSingleImageWidget(post.imageUrls[0])
        : innerMultipleImage;

    /// 评论点赞点踩浏览量
    var likeUnlikeVisit = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset("assets/svg_pics/lake_butt_icons/comment.svg",
              color: WpyTheme.of(context).get(WpyColorKey.infoTextColor),
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

    /// tag校区浏览量
    var tagCampusVisit = Row(
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

    // avatarAndSolve、eTagAndTitle、content的统一list
    // （因为 outer 和 inner 的这部分几乎完全相同）
    List<Widget> head = [
      avatarAndSolve,
      Padding(
        padding: EdgeInsets.symmetric(horizontal: SplitUtil.w * 16),
        child: eTagAndTitle,
      ),
      if (post.content.isNotEmpty)
        Padding(
            padding: EdgeInsets.symmetric(horizontal: SplitUtil.w * 16),
            child: content),
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
        child: widget.outer
            // outer 框架
            ? GestureDetector(
                onTap: () {
                  if (SplitUtil.needHorizontalView) {
                    context.read<LakeModel>().clearAndSetSplitPost(post);
                  } else {
                    FeedbackService.visitPost(
                        id: widget.post.id, onFailure: (_) {});
                    Navigator.pushNamed(
                      context,
                      FeedbackRouter.detail,
                      arguments: post,
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, SplitUtil.h * 8),
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...head,
                      if (post.imageUrls.isNotEmpty)
                        Padding(
                            padding: EdgeInsets.only(
                                left: SplitUtil.w * 16,
                                right: SplitUtil.w * 16,
                                bottom: SplitUtil.h * 8),
                            child: outerImages),
                      Padding(
                        padding: EdgeInsets.only(left: SplitUtil.w * 10),
                        child: likeUnlikeVisit,
                      )
                    ],
                  ),
                ),
              )

            // inner 框架
            : Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, SplitUtil.h * 8),
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
                    if (post.imageUrls.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(
                            left: SplitUtil.w * 16,
                            right: SplitUtil.w * 16,
                            bottom: SplitUtil.h * 10),
                        child: innerImages,
                      ),
                    Padding(
                      padding: EdgeInsets.only(left: SplitUtil.w * 8),
                      child: tagCampusVisit,
                    ),
                  ],
                ),
              ),
      ),
    );

    /////////////////////////////////////////////////////////
    ///           ↑ build's return is here  ↑             ///
    /////////////////////////////////////////////////////////
  }

  Widget get outerSingleImage {
    return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(8.r)),
        child: Container(
          width: SplitUtil.sw - SplitUtil.w * 20 - SplitUtil.toolbarWidth,
          height: SplitUtil.w * 150,
          color: WpyTheme.of(context).get(WpyColorKey.iconAnimationStartColor),
          child: WpyPic(
            picBaseUrl + 'origin/' + post.imageUrls[0],
            width: 350.w,
            height: 197.w,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ));
  }

  Widget get innerMultipleImage => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          post.imageUrls.length,
          (index) => WButton(
            onPressed: () => Navigator.pushNamed(
              context,
              FeedbackRouter.imageView,
              arguments: ImageViewPageArgs(
                  post.imageUrls, post.imageUrls.length, index, false),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8.r)),
              child: WpyPic(picBaseUrl + 'thumb/' + post.imageUrls[index],
                  fit: BoxFit.cover,
                  width: ((SplitUtil.sw -
                              SplitUtil.w * 20 -
                              SplitUtil.toolbarWidth) -
                          (post.imageUrls.length - 1) * SplitUtil.w * 6) /
                      post.imageUrls.length,
                  height: ((SplitUtil.sw -
                              SplitUtil.w * 20 -
                              SplitUtil.toolbarWidth) -
                          (post.imageUrls.length - 1) * SplitUtil.w * 6) /
                      post.imageUrls.length,
                  withHolder: true),
            ),
          ),
        ),
      );

  Widget get outerMultipleImage => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          post.imageUrls.length,
          (index) => ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8.r)),
            child: WpyPic(picBaseUrl + 'thumb/' + post.imageUrls[index],
                fit: BoxFit.cover,
                width: ((SplitUtil.sw -
                            SplitUtil.w * 20 -
                            SplitUtil.toolbarWidth) -
                        (post.imageUrls.length - 1) * SplitUtil.w * 6) /
                    post.imageUrls.length,
                height: ((SplitUtil.sw -
                            SplitUtil.w * 20 -
                            SplitUtil.toolbarWidth) -
                        (post.imageUrls.length - 1) * SplitUtil.w * 6) /
                    post.imageUrls.length,
                withHolder: true),
          ),
        ),
      );
}

class InnerSingleImageWidget extends StatefulWidget {
  final String imageUrl;

  InnerSingleImageWidget(this.imageUrl);

  @override
  State<InnerSingleImageWidget> createState() => _InnerSingleImageWidgetState();
}

class _InnerSingleImageWidgetState extends State<InnerSingleImageWidget> {
  final String picBaseUrl = '${EnvConfig.QNHDPIC}download/';

  bool _picFullView = false;

  @override
  Widget build(BuildContext context) {
    /// 计算长图
    Completer<ui.Image> completer = Completer<ui.Image>();
    // 这个不能替换成 WpyPic
    Image image = Image.network(
      picBaseUrl + 'origin/' + widget.imageUrl,
      width: double.infinity,
      fit: BoxFit.fitWidth,
      alignment: Alignment.topCenter,
    );
    if (!completer.isCompleted) {
      image.image
          .resolve(ImageConfiguration())
          .addListener(ImageStreamListener((ImageInfo info, bool _) {
        if (!completer.isCompleted) completer.complete(info.image);
      }));
    }

    return FutureBuilder<ui.Image>(
      future: completer.future,
      builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
        return Container(
          child: snapshot.hasData
              ? snapshot.data!.height / snapshot.data!.width > 2.0
                  ? _picFullView
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.r)),
                                child: GestureDetector(
                                    onTap: () => Navigator.pushNamed(
                                          context,
                                          FeedbackRouter.imageView,
                                          arguments: ImageViewPageArgs(
                                              [widget.imageUrl], 1, 0, true),
                                        ),
                                    child: image),
                              ),
                              TextButton(
                                  style: ButtonStyle(
                                      alignment: Alignment.topRight,
                                      padding: MaterialStateProperty.all(
                                          EdgeInsets.zero),
                                      overlayColor: MaterialStateProperty.all(
                                          Colors.transparent)),
                                  onPressed: () {
                                    setState(() {
                                      _picFullView = false;
                                    });
                                  },
                                  child: Text('收起',
                                      style: TextUtil.base
                                          .textButtonPrimary(context)
                                          .w600
                                          .NotoSansSC
                                          .sp(14)))
                            ])
                      : SizedBox(
                          height: WePeiYangApp.screenWidth * 1.2,
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.r)),
                            child: Stack(children: [
                              GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                        context,
                                        FeedbackRouter.imageView,
                                        arguments: ImageViewPageArgs(
                                            [widget.imageUrl], 1, 0, true),
                                      ),
                                  child: image),
                              Positioned(top: 8, left: 8, child: TextPod('长图')),
                              Align(
                                  alignment: Alignment.bottomCenter,
                                  child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _picFullView = true;
                                        });
                                      },
                                      child: Container(
                                          height: 60,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment(0, -0.7),
                                              end: Alignment(0, 1),
                                              colors: [
                                                Colors.transparent,
                                                Colors.black54,
                                              ],
                                            ),
                                          ),
                                          child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                SizedBox(width: 10),
                                                Text(
                                                  '点击展开\n',
                                                  style: TextUtil.base.w600
                                                      .bright(context)
                                                      .sp(14)
                                                      .h(0.6),
                                                ),
                                                Spacer(),
                                                Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.black38,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        16))),
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            12, 4, 10, 6),
                                                    child: Text(
                                                      '长图模式',
                                                      style: TextUtil.base.w300
                                                          .bright(context)
                                                          .sp(12),
                                                    ))
                                              ]))))
                            ]),
                          ))
                  : ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(12.r)),
                      child: GestureDetector(
                          onTap: () => Navigator.pushNamed(
                                context,
                                FeedbackRouter.imageView,
                                arguments: ImageViewPageArgs(
                                    [widget.imageUrl], 1, 0, false),
                              ),
                          child: image),
                    )
              : Icon(
                  Icons.refresh,
                  color: Colors.black54,
                ),
          color: snapshot.hasData ? Colors.transparent : Colors.black12,
        );
      },
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

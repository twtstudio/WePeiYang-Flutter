import 'dart:async';

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/clip_copy.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/icon_widget.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/round_taggings.dart';
import 'package:we_pei_yang_flutter/lounge/ui/widget/loading.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/message/feedback_banner_widget.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/long_text_shower.dart';

enum PostCardType { simple, detail, outSide }

typedef HitLikeCallback = void Function(bool, int);
typedef HitDislikeCallback = void Function(bool);

typedef HitFavoriteCallback = void Function(bool, int);

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onContentPressed;
  final HitLikeCallback onLikePressed;
  final HitDislikeCallback onDislikePressed;
  final HitFavoriteCallback onFavoritePressed;
  final VoidCallback onContentLongPressed;
  final bool showBanner;
  final PostCardType type;

  PostCard.simple(
    this.post, {
    this.onContentPressed,
    this.onLikePressed,
    this.onDislikePressed,
    this.onFavoritePressed,
    this.onContentLongPressed,
    this.showBanner = false,
    Key key,
  })  : type = PostCardType.simple,
        super(key: key);

  /// Card for DetailPage.
  PostCard.detail(
    this.post, {
    this.onContentPressed,
    this.onLikePressed,
    this.onDislikePressed,
    this.onFavoritePressed,
    this.onContentLongPressed,
    this.showBanner = false,
  }) : type = PostCardType.detail;

  PostCard.outSide(
    this.post, {
    this.onContentPressed,
    this.onLikePressed,
    this.onDislikePressed,
    this.onFavoritePressed,
    this.onContentLongPressed,
    this.showBanner = false,
  }) : type = PostCardType.outSide;

  @override
  _PostCardState createState() => _PostCardState(this.post);
}

class _PostCardState extends State<PostCard> {
  bool _picFullView;
  Post post;
  final String baseUrl = 'https://www.zrzz.site:7013/';

  _PostCardState(this.post);

  @override
  Widget build(BuildContext context) {
    var singlePictureLoader;
    var longPicOutsideLook;

    if (post.imageUrls.length == 1) {
      Image image = new Image.network(
        baseUrl + post.imageUrls[0],
        width: double.infinity,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
      );
      Completer<ui.Image> completer = new Completer<ui.Image>();
      image.image
          .resolve(new ImageConfiguration())
          .addListener(ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image);
      }));

      var limitedImage = _picFullView ?? false
          ? Column(
              children: [
                image,
                Row(
                  children: [
                    Spacer(),
                    TextButton(
                        style: ButtonStyle(
                            alignment: Alignment.topRight,
                            padding:
                                MaterialStateProperty.all(EdgeInsets.zero)),
                        onPressed: () {
                          setState(() {
                            _picFullView = false;
                          });
                        },
                        child: Text('收起',
                            style: TextUtil.base.textButtonBlue.w600.NotoSansSC
                                .sp(14))),
                  ],
                ),
              ],
            )
          : SizedBox(
              height: WePeiYangApp.screenWidth * 1.2,
              child: Stack(children: [
                image,
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
                      padding: EdgeInsets.only(left: 12, bottom: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black54,
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Spacer(),
                          Text(
                            '点击查看全部',
                            style: TextUtil.base.w600.white.sp(14),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ]),
            );

      var longImageOuterLook = Stack(
        alignment: Alignment.topLeft,
        children: [image, Positioned(top: 4, left: 4, child: TextPod('长图'))],
      );

      longPicOutsideLook = new FutureBuilder<ui.Image>(
        future: completer.future,
        builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
          return Container(
              width: 97,
              height: 76,
              child: snapshot.hasData
                  ? snapshot.data.height / snapshot.data.width > 2.5
                      ? longImageOuterLook
                      : image
                  : Loading());
        },
      );

      singlePictureLoader = ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        child: new FutureBuilder<ui.Image>(
          future: completer.future,
          builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
            return snapshot.hasData
                ? snapshot.data.height / snapshot.data.width > 2.5
                    ? limitedImage
                    : image
                : Text('Loading...');
          },
        ),
      );
    }

    var title = Expanded(
      child: Text(
        post.title,
        maxLines: widget.type == PostCardType.detail ? 3 : 1,
        overflow: TextOverflow.ellipsis,
        style: TextUtil.base.w500.NotoSansSC.sp(18).black2A,
      ),
    );

    var tag = post.type == 0
        ? post.tag != null
            ? '${post.tag.name}'
            : '无标签'
        : post.department != null
            ? '${post.department.name}'
            : '无部门';

    var campus = post.campus > 0
        ? Container(
            decoration: BoxDecoration(
                color: ColorUtil.backgroundColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: ColorUtil.mainColor)),
            padding: const EdgeInsets.fromLTRB(2, 2, 2, 1),
            child: Text(const ['', '卫津路', '北洋园'][post.campus],
                style: FontManager.YaHeiRegular.copyWith(
                    fontSize: 10, color: ColorUtil.mainColor)),
          )
        : SizedBox();

    var content = ExpandableText(
      text: post.content,
      maxLines: widget.type == PostCardType.detail ? 8 : 2,
      style: TextUtil.base.NotoSansSC.w400
          .sp(16)
          .black2A
          .h(widget.type == PostCardType.detail ? 1.2 : 1.4),
      expand: false,
      buttonIsShown: widget.type == PostCardType.detail,
    );

    List<Widget> rowList = [];

    rowList.add(Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(children: [TagShowWidget(tag), SizedBox(width: 8), campus]),
          SizedBox(height: 6),
          if (widget.type == PostCardType.detail)
            Row(
              children: [title],
            ),
          if (widget.type == PostCardType.detail) SizedBox(height: 8),
          content,
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    ));

    if (widget.type == PostCardType.simple &&
        (post.imageUrls?.isNotEmpty ?? false)) {
      rowList.addAll([
        SizedBox(width: 10),
        ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: post.imageUrls.length == 1
                ? longPicOutsideLook
                : Image.network(
                    baseUrl + post.imageUrls[0],
                    width: 97,
                    height: 76,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                          width: 97,
                          height: 76,
                          padding: EdgeInsets.all(20),
                          child: Loading());
                    },
                  )),
      ]);
    }
    var createTime = Text(
      DateFormat('yyyy-MM-dd HH:mm:ss').format(post.createAt.toLocal()),
      textAlign: TextAlign.right,
      style: TextUtil.base.black2A.bold.ProductSans.sp(12),
    );
    var createTimeDetail = Text(
      DateFormat('yyyy-MM-dd HH:mm:ss').format(post.createAt.toLocal()),
      textAlign: TextAlign.right,
      style: TextUtil.base.grey6C.normal.ProductSans.sp(14),
    );
    var middleWidget =
        Row(children: rowList, crossAxisAlignment: CrossAxisAlignment.start);

    var mainWidget = (tap) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (widget.type == PostCardType.detail)
                    Expanded(
                        child: Text(
                      '#MP' + post.id.toString().padLeft(6, '0'),
                      style:
                          TextUtil.base.w400.normal.grey6C.ProductSans.sp(14),
                    )),
                  if (widget.type == PostCardType.simple) title,
                  SizedBox(width: 10),
                  if (post.type == 0 && widget.type == PostCardType.simple)
                    MPWidget(post.id.toString().padLeft(6, '0')),
                  if (post.solved == 1 &&
                      post.type == 1 &&
                      widget.type == PostCardType.simple)
                    SolvedWidget(),
                  if (post.solved == 0 &&
                      post.type == 1 &&
                      widget.type == PostCardType.simple)
                    UnSolvedWidget(),
                  if (widget.type == PostCardType.detail) createTimeDetail,
                ],
              ),
              SizedBox(height: 8),
              middleWidget,
            ],
          ),
          onTap: () async {
            if (widget.type == PostCardType.simple) {
              widget.onContentPressed?.call();
              await tap?.call();
              Navigator.pushNamed(
                context,
                FeedbackRouter.detail,
                arguments: post,
              ).then((p) {
                setState(() {
                  post = p;
                });
              });
            }
          },
          onLongPress: widget.onContentLongPressed,
        );

    var favoriteWidget = (widget.type == PostCardType.outSide)
        ? IconWidget(
            IconType.bottomFav,
            count: post.favCount,
            onLikePressed: (boolNotifier, favCount, success, failure) async {
              await FeedbackService.postHitFavorite(
                id: post.id,
                isFavorite: post.isFav,
                onSuccess: () {
                  widget.onFavoritePressed?.call(!boolNotifier, favCount);
                  success.call();
                },
                onFailure: (e) {
                  ToastProvider.error(e.error.toString());
                  failure.call();
                },
              );
            },
            isLike: post.isFav,
          )
        : IconWidget(
            IconType.fav,
            count: post.favCount,
            onLikePressed: (boolNotifier, favCount, success, failure) async {
              await FeedbackService.postHitFavorite(
                id: post.id,
                isFavorite: post.isFav,
                onSuccess: () {
                  widget.onFavoritePressed?.call(!boolNotifier, favCount);
                  success.call();
                },
                onFailure: (e) {
                  ToastProvider.error(e.error.toString());
                  failure.call();
                },
              );
            },
            isLike: post.isFav,
          );

    var commentWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SvgPicture.asset("assets/svg_pics/lake_butt_icons/comment.svg",
            width: 11.67.w),
        SizedBox(
          width: 5.17.w,
        ),
        SizedBox(
          width: 20.w,
          child: Text(
            post.commentCount.toString(),
            style: TextUtil.base.ProductSans.black2A.normal.sp(12).w700,
          ),
        ),
        SizedBox(
          width: 5.17.w,
        ),
      ],
    );
    var likeWidget = (widget.type == PostCardType.outSide)
        ? IconWidget(
            IconType.bottomLike,
            count: post.likeCount,
            onLikePressed: (isLike, likeCount, success, failure) async {
              await FeedbackService.postHitLike(
                id: post.id,
                isLike: post.isLike,
                onSuccess: () {
                  widget.onLikePressed?.call(!isLike, likeCount);
                  post.isLike = !isLike;
                  post.likeCount = likeCount;
                  success.call();
                },
                onFailure: (e) {
                  ToastProvider.error(e.error.toString());
                  failure.call();
                },
              );
            },
            isLike: post.isLike,
          )
        : IconWidget(
            IconType.like,
            count: post.likeCount,
            onLikePressed: (isLike, likeCount, success, failure) async {
              await FeedbackService.postHitLike(
                id: post.id,
                isLike: post.isLike,
                onSuccess: () {
                  widget.onLikePressed?.call(!isLike, likeCount);
                  post.isLike = !isLike;
                  post.likeCount = likeCount;
                  success.call();
                },
                onFailure: (e) {
                  ToastProvider.error(e.error.toString());
                  failure.call();
                },
              );
            },
            isLike: post.isLike,
          );

    var dislikeWidget = (widget.type == PostCardType.outSide)
        ? DislikeWidget(
            size: 22.w,
            isDislike: widget.post.isDis,
            onDislikePressed: (dislikeNotifier) async {
              await FeedbackService.postHitDislike(
                id: post.id,
                isDisliked: post.isDis,
                onSuccess: () {
                  widget.onDislikePressed?.call(dislikeNotifier);
                  post.isDis = !post.isDis;
                },
                onFailure: (e) {
                  ToastProvider.error(e.error.toString());
                },
              );
            },
          )
        : DislikeWidget(
            size: 15.w,
            isDislike: widget.post.isDis,
            onDislikePressed: (dislikeNotifier) async {
              await FeedbackService.postHitDislike(
                id: post.id,
                isDisliked: post.isDis,
                onSuccess: () {
                  widget.onDislikePressed?.call(dislikeNotifier);
                  post.isDis = !post.isDis;
                },
                onFailure: (e) {
                  ToastProvider.error(e.error.toString());
                },
              );
            },
          );

    var commentAndLike = [
      if (widget.type == PostCardType.simple) commentWidget,
      likeWidget,
      if (widget.type == PostCardType.outSide) favoriteWidget,
      dislikeWidget,
      SizedBox(width: 10)
    ];

    List<Widget> bottomList = [];
    List<Widget> imagesWidget = [];

    switch (widget.type) {
      case PostCardType.simple:
        bottomList.addAll([
          ...commentAndLike,
          Spacer(),
          createTime,
        ]);
        imagesWidget = [];
        break;
      case PostCardType.detail:
        bottomList.addAll([
          createTime,
          Spacer(),
          ...commentAndLike,
          favoriteWidget,
        ]);

        if (post.imageUrls.length > 1) {
          var imageList = Row(
            children: List.generate(
              post.imageUrls.length,
              (index) => _image(index, context),
            ),
          );
          imagesWidget.addAll([
            SizedBox(height: 10),
            imageList,
          ]);
        } else if (post.imageUrls.length == 1) {
          imagesWidget.add(InkWell(
              onTap: () {
                Navigator.pushNamed(context, FeedbackRouter.imageView,
                    arguments: {
                      "urlList": post.imageUrls,
                      "urlListLength": post.imageUrls.length,
                      "indexNow": 0
                    });
              },
              child: singlePictureLoader));
        }

        imagesWidget.add(
          SizedBox(height: 10),
        );
        break;
      case PostCardType.outSide:
        bottomList.addAll([
          ...commentAndLike,
        ]);
        break;
    }

    var bottomWidget = Row(children: bottomList);

    var decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
            blurRadius: 5,
            color: ColorUtil.greyF7F8Color,
            offset: Offset(0, 0),
            spreadRadius: 3),
      ],
    );

    var body = FeedbackBannerWidget(
      showBanner: widget.showBanner,
      questionId: post.id,
      builder: (tap) => Container(
        padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            mainWidget(tap),
            SizedBox(height: 8),
            ...imagesWidget,
            if (widget.type != PostCardType.detail) bottomWidget,
          ],
        ),
        decoration: decoration,
      ),
    );
    return widget.type != PostCardType.outSide
        ? DefaultTextStyle(
            style: FontManager.YaHeiRegular,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: ClipCopy(
                toast: '复制提问成功',
                copy: post.content,
                child: body,
              ),
            ),
          )
        : Row(
            children: [
              SizedBox(
                width: 10,
              ),
              ...commentAndLike,
            ],
          );
  }

  _image(index, context) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, FeedbackRouter.imageView, arguments: {
            "urlList": post.imageUrls,
            "urlListLength": post.imageUrls.length,
            "indexNow": index
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(6)),
            child: FadeInImage.memoryNetwork(
                fit: BoxFit.cover,
                height:
                    (ScreenUtil.defaultSize.width - 80) / post.imageUrls.length,
                placeholder: kTransparentImage,
                image: baseUrl + post.imageUrls[index]),
          ),
        ),
      ),
    );
  }
}

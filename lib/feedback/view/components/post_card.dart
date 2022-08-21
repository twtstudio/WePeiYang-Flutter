import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/icon_widget.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/long_text_shower.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/round_taggings.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/message/feedback_banner_widget.dart';

enum PostCardType { simple, detail, outSide }

typedef HitLikeCallback = void Function(bool, int);
typedef HitDislikeCallback = void Function(bool);

typedef HitFavoriteCallback = void Function(bool, int);

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onContentPressed;
  final VoidCallback onContentLongPressed;
  final bool showBanner;
  final PostCardType type;

  PostCard.simple(
    this.post, {
    this.onContentPressed,
    this.onContentLongPressed,
    this.showBanner = false,
    Key key,
  })  : type = PostCardType.simple,
        super(key: key);

  /// Card for DetailPage.
  PostCard.detail(
    this.post, {
    this.onContentPressed,
    this.onContentLongPressed,
    this.showBanner = false,
  }) : type = PostCardType.detail;

  PostCard.outSide(
    this.post, {
    this.onContentPressed,
    this.onContentLongPressed,
    this.showBanner = false,
  }) : type = PostCardType.outSide;

  @override
  _PostCardState createState() => _PostCardState(this.post);
}

class _PostCardState extends State<PostCard> {
  bool _picFullView;
  Post post;

  final String picBaseUrl = '${EnvConfig.QNHDPIC}download/';

  _PostCardState(this.post);

  @override
  Widget build(BuildContext context) {
    var singlePictureLoader;
    var longPicOutsideLook;
    if (post.imageUrls.isNotEmpty) if (post.imageUrls != null &&
        post.imageUrls.length == 1) {
      Image image = new Image.network(
        widget.type == PostCardType.detail
            ? picBaseUrl + 'origin/' + post.imageUrls[0]
            : picBaseUrl + 'thumb/' + post.imageUrls[0],
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                image,
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
                        style: TextUtil.base.textButtonBlue.w600.NotoSansSC
                            .sp(14))),
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
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(width: 10),
                          Text(
                            '点击展开\n',
                            style: TextUtil.base.w600.greyEB.sp(14).h(0.6),
                          ),
                          Spacer(),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16))),
                            padding: EdgeInsets.fromLTRB(12, 4, 10, 6),
                            child: Text(
                              '长图模式',
                              style: TextUtil.base.w300.white.sp(12),
                            ),
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
        //initialData: ,
        future: completer.future,
        builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
          return Container(
            width: 97,
            height: 76,
            child: snapshot.hasData
                ? snapshot.data.height / snapshot.data.width > 2.0
                    ? longImageOuterLook
                    : image
                : Icon(
                    Icons.refresh,
                    color: Colors.black54,
                  ),
            color: snapshot.hasData ? Colors.transparent : Colors.black12,
          );
        },
      );

      singlePictureLoader = ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        child: new FutureBuilder<ui.Image>(
          future: completer.future,
          builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
            return snapshot.connectionState == ConnectionState.done
                ? snapshot.data.height / snapshot.data.width > 2.0
                    ? InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, FeedbackRouter.imageView,
                              arguments: {
                                "urlList": post.imageUrls,
                                "urlListLength": post.imageUrls.length,
                                "indexNow": 0,
                                "isLongPic": true
                              });
                        },
                        child: limitedImage)
                    : InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, FeedbackRouter.imageView,
                              arguments: {
                                "urlList": post.imageUrls,
                                "urlListLength": post.imageUrls.length,
                                "indexNow": 0,
                                "isLongPic": false
                              });
                        },
                        child: image)
                : Loading();
          },
        ),
      );
    }

    var title = Text(
      post.title,
      maxLines: widget.type == PostCardType.detail ? 3 : 1,
      overflow: TextOverflow.ellipsis,
      style: TextUtil.base.w400.NotoSansSC.sp(16).black00.bold,
    );

    var tag = post.type != 1
        ? post.tag != null
            ? '${post.tag.name}'
            : ''
        : post.department != null
            ? '${post.department.name}'
            : '';

    var id = post.type != 1
        ? post.tag != null && post.tag.id != null
            ? post.tag.id
            : -1
        : post.department != null
            ? post.department.id
            : -1;

    var campus = post.campus > 0
        ? Container(
            decoration: BoxDecoration(
                color: ColorUtil.backgroundColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: ColorUtil.mainColor)),
            padding: widget.type == PostCardType.simple
                ? const EdgeInsets.fromLTRB(2, 2, 2, 1)
                : const EdgeInsets.fromLTRB(4, 2, 4, 1),
            child: Text(
                widget.type == PostCardType.simple
                    ? const ['', '卫津路', '北洋园'][post.campus]
                    : const ['', '卫', '北'][post.campus],
                style: TextUtil.base.regular.mainColor.sp(10)),
          )
        : SizedBox();

    var content = InkWell(
        onLongPress: () {
          Clipboard.setData(
              ClipboardData(text: '【' + post.title + '】 ' + post.content));
          ToastProvider.success('复制冒泡内容成功');
        },
        onTap: () async {
          if (widget.type == PostCardType.simple) {
            ///不然点击事件的回调根本用不到啊啊啊啊
            if (widget.onContentPressed == null) {
              await FeedbackService.visitPost(
                id: post.id,
                onFailure: (e) {
                  ToastProvider.error(e.error.toString());
                },
              );
              Navigator.pushNamed(
                context,
                FeedbackRouter.detail,
                arguments: post,
              ).then((p) {
                setState(() {
                  post = p;
                });
              });
            } else {
              ///上面判过空，所以就不做空安全了XD
              widget.onContentPressed.call();
            }
          }
        },
        child: SizedBox(
          width: double.infinity,
          child: ExpandableText(
            text: post.content,
            maxLines: widget.type == PostCardType.detail ? 8 : 2,
            style: TextUtil.base.NotoSansSC.w400
                .sp(14)
                .black2A
                .h(widget.type == PostCardType.detail ? 1.6 : 1.4),
            expand: false,
            buttonIsShown: widget.type == PostCardType.detail,
            isHTML: false,
          ),
        ));
    var createTime = Text(
      DateFormat('yyyy-MM-dd HH:mm:ss').format(post.createAt.toLocal()),
      textAlign: TextAlign.left,
      style: TextUtil.base.black2A.bold.ProductSans.sp(8),
    );
    var createTimeDetail = Text(
      DateFormat('yyyy-MM-dd HH:mm:ss').format(post.createAt.toLocal()),
      textAlign: TextAlign.left,
      style: TextUtil.base.grey6C.normal.ProductSans.sp(8),
    );
    List<Widget> rowList = [];

    rowList.add(
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //if (widget.type == PostCardType.detail) SizedBox(height: 8.w),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProfileImageWithDetailedPopup(
                    post.type, post.nickname, post.uid),
                Container(
                  margin: EdgeInsets.only(left: 8.w),
                  width: (WePeiYangApp.screenWidth - 24.w) / 2 - 70.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            post.nickname == '' ? '没名字的微友' : post.nickname,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextUtil.base.w500.NotoSansSC.sp(14).black2A,
                          ),
                        ],
                      ),
                      createTimeDetail,
                    ],
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onLongPress: () {
                    return Clipboard.setData(ClipboardData(
                            text: '#MP' + post.id.toString().padLeft(6, '0')))
                        .whenComplete(
                            () => ToastProvider.success('复制帖子id成功，快去分享吧！'));
                  },
                  child: Text(
                    '#MP' + post.id.toString().padLeft(6, '0'),
                    style: TextUtil.base.w400.grey6C.NotoSansSC.sp(12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.w),
            Row(
              children: [
                if (post.eTag != '' && post.eTag != null)
                  Center(
                      child: ETagWidget(entry: widget.post.eTag, full: true)),
                Expanded(
                  child: InkWell(
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(
                          text: '【' + post.title + '】 ' + post.content));
                      ToastProvider.success('复制提问成功');
                    },
                    onTap: () async {
                      if (widget.type == PostCardType.simple) {
                        await FeedbackService.visitPost(
                          id: post.id,
                          onFailure: (e) {
                            ToastProvider.error(e.error.toString());
                          },
                        );
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
                    child: title,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.w),
            content, SizedBox(height: 2.w),
          ],
        ),
      ),
    );

    if (widget.type == PostCardType.simple &&
        (post.imageUrls?.isNotEmpty ?? false)) {
      rowList.addAll([
        SizedBox(width: 10),
        ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: post.imageUrls.length == 1
                ? longPicOutsideLook
                : Image.network(
                    picBaseUrl + 'thumb/' + post.imageUrls[0],
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
    var view = Text(
      post.visitCount == null ? '0次浏览' : post.visitCount.toString() + "次浏览",
      style: TextUtil.base.ProductSans.grey97.normal.sp(10).w400,
    );
    var mainWidget = (tap) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
                children: rowList,
                crossAxisAlignment: CrossAxisAlignment.start),
          ],
        );

    var favoriteWidget = (widget.type == PostCardType.outSide)
        ? IconWidget(
            IconType.bottomFav,
            count: post.favCount,
            onLikePressed: (isFav, favCount, success, failure) async {
              await FeedbackService.postHitFavorite(
                id: post.id,
                isFavorite: post.isFav,
                onSuccess: () {
                  post.isFav = !isFav;
                  post.favCount = favCount;
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
            onLikePressed: (isFav, favCount, success, failure) async {
              await FeedbackService.postHitFavorite(
                id: post.id,
                isFavorite: post.isFav,
                onSuccess: () {
                  post.isFav = !isFav;
                  post.favCount = favCount;
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

    var visitWidget = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //这里的各种detail和simple的区分只是为了方便在调试帖子详情页面的时候让外面的页面不崩溃

        if (tag != '' && widget.type == PostCardType.detail)
          TagShowWidget(
              tag,
              widget.type == PostCardType.simple
                  ? WePeiYangApp.screenWidth -
                      (post.campus > 0 ? 50.w : 0) -
                      (widget.post.imageUrls.isEmpty ? 140.w : 240.w)
                  : (WePeiYangApp.screenWidth - 24.w) / 2 -
                      (post.campus > 0 ? 100.w : 60.w),
              post.type,
              id,
              0,
              post.type),
        if (tag != '' && widget.type == PostCardType.detail) SizedBox(width: 8),
        if (widget.type == PostCardType.detail)
          TagShowWidget(
              getTypeName(widget.post.type), 100, 0, 0, widget.post.type, 0),
        if (post.campus != 0 && post.campus != null) SizedBox(width: 8),
        if (widget.type == PostCardType.detail) campus,
        if (widget.type == PostCardType.detail) Spacer(),

        if (widget.type == PostCardType.simple)
          SvgPicture.asset("assets/svg_pics/lake_butt_icons/big_eye.svg",
              color: ColorUtil.mainColor, width: 14.6.w),
        if (widget.type == PostCardType.simple)
          SizedBox(width: 2.w),
        if (widget.type == PostCardType.simple)
          Text(
            post.visitCount == null
                ? '0  '
                : post.visitCount < 1000
                    ? post.visitCount.toString() +
                        (post.visitCount < 100 ? '   ' : '  ')
                    : post.visitCount < 10000
                        ? (post.visitCount.toDouble() / 1000)
                                .toStringAsFixed(1)
                                .toString() +
                            'k  '
                        : (post.visitCount.toDouble() / 10000)
                                .toStringAsFixed(1)
                                .toString() +
                            'w  ',
            style: TextUtil.base.ProductSans.black2A.normal.sp(12).w700,
          ),
        if (widget.type == PostCardType.detail)
          Text(
            post.visitCount.toString(),
            style: TextUtil.base.NotoSansSC.mainGrey.normal.sp(10).w400,
          ),
        if (widget.type == PostCardType.detail)
          Text(
            '次浏览',
            style: TextUtil.base.NotoSansSC.mainGrey.normal.sp(10).w400,
          ),
      ],
    );

    var commentAndWatchedWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset("assets/svg_pics/lake_butt_icons/comment.svg",
            width: 11.67.w),
        SizedBox(width: 3.w),
        Text(
          post.commentCount.toString() +
              (post.commentCount < 100 ? '   ' : ' '),
          style: TextUtil.base.ProductSans.black2A.normal.sp(12).w700,
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
          )
        : IconWidget(
            IconType.like,
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
          )
        : DislikeWidget(
            size: 15.w,
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
          );

    var commentAndLike = [
      if (widget.type == PostCardType.simple) commentAndWatchedWidget,
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
          view,
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
          imagesWidget.add(singlePictureLoader);
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
      color: CommonPreferences.isSkinUsed.value
          ? Color(CommonPreferences.skinColorE.value)
          : Colors.white,
      boxShadow: [
        BoxShadow(
            blurRadius: 1.6,
            color: Colors.black12,
            offset: Offset(0, 0),
            spreadRadius: -1),
      ],
    );

    var body = GestureDetector(
        onTap: () async {
          await FeedbackService.visitPost(
            id: post.id,
            onFailure: (e) {
              ToastProvider.error(e.error.toString());
            },
          );
          if (widget.type == PostCardType.simple) {
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
        child: FeedbackBannerWidget(
          showBanner: widget.showBanner,
          questionId: post.id,
          builder: (tap) => Container(
            padding: EdgeInsets.fromLTRB(5.w, 14.w, 5.w, 10.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                mainWidget(tap),
                SizedBox(height: 8.w),
                ...imagesWidget,
                if (widget.type != PostCardType.detail) bottomWidget,
                if (widget.type == PostCardType.detail) visitWidget,
              ],
            ),
            decoration: decoration,
          ),
        ));
    return widget.type != PostCardType.outSide
        ? Padding(
            padding: EdgeInsets.fromLTRB(12.w, 12.w, 12.w, 2.w),
            child: body,
          )
        : Row(
            children: [
              SizedBox(width: 10),
              ...commentAndLike,
            ],
          );
  }

  _image(index, context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, FeedbackRouter.imageView, arguments: {
          "urlList": post.imageUrls,
          "urlListLength": post.imageUrls.length,
          "indexNow": index
        });
      },
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          child: Image.network(
              widget.type == PostCardType.detail
                  ? picBaseUrl + 'origin/' + post.imageUrls[index]
                  : picBaseUrl + 'thumb/' + post.imageUrls[index],
              fit: BoxFit.cover,
              width: (WePeiYangApp.screenWidth - 64.w) / post.imageUrls.length -
                  8.w,
              height: (WePeiYangApp.screenWidth - 64.w) /
                  post.imageUrls.length *
                  0.8,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: (WePeiYangApp.screenWidth - 64.w) / post.imageUrls.length -
                  8.w,
              height: (WePeiYangApp.screenWidth - 64.w) /
                  post.imageUrls.length *
                  0.8,
              child: Center(
                child: Container(
                  height: 40,
                  width: 40,
                  padding: EdgeInsets.all(4),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    backgroundColor: Colors.black12,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes
                        : null,
                  ),
                ),
              ),
            );
          }, errorBuilder: (BuildContext context, Object exception,
                  StackTrace stackTrace) {
            return Text(
              '💔[图片加载失败]',
              style: TextUtil.base.grey6C.w400.sp(12),
            );
          }),
        ),
      ),
    );
  }

  String getTypeName(int type) {
    Map<int, String> typeName = {};
    context.read<LakeModel>().tabList.forEach((e) {
      typeName.addAll({e.id: e.shortname});
    });
    return typeName[type];
  }
}

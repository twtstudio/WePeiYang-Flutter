import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/clip_copy.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/collect_widget.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/round_taggings.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/like_widget.dart';
import 'package:we_pei_yang_flutter/message/feedback_banner_widget.dart';

enum PostCardType { simple, detail }

typedef HitLikeCallback = void Function(bool, int);

typedef HitCollectCallback = void Function(bool);

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onContentPressed;
  final HitLikeCallback onLikePressed;
  final HitCollectCallback onFavoritePressed;
  final VoidCallback onContentLongPressed;
  final bool showBanner;
  final PostCardType type;

  PostCard.simple(
    this.post, {
    this.onContentPressed,
    this.onLikePressed,
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
    this.onFavoritePressed,
    this.onContentLongPressed,
    this.showBanner = false,
  }) : type = PostCardType.detail;

  @override
  _PostCardState createState() => _PostCardState(this.post);
}

class _PostCardState extends State<PostCard> {
  Post post;

  _PostCardState(this.post);

  @override
  Widget build(BuildContext context) {
    var title = Expanded(
      child: Text(
        post.title,
        maxLines: widget.type == PostCardType.detail ? 3 : 1,
        overflow: TextOverflow.ellipsis,
        style: FontManager.YaHeiRegular.copyWith(
          color: ColorUtil.boldTextColor,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    var tag = Text(
      (post.tags?.length ?? 0) > 0 ? '#${post.tags[0].name}' : '#无标签',
      style: FontManager.YaHeiRegular.copyWith(
          fontSize: 14, color: ColorUtil.lightTextColor),
    );

    var campus = post.campus > 0
        ? Container(
            decoration: BoxDecoration(
              color: ColorUtil.backgroundColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: ColorUtil.mainColor)
            ),
            padding: const EdgeInsets.fromLTRB(2, 2, 2, 1),
            child: Text(const ['', '卫津路', '北洋园'][post.campus],
                style: FontManager.YaHeiRegular.copyWith(
                    fontSize: 10, color: ColorUtil.mainColor)),
          )
        : Container();

    var content = Text(
      post.content,
      maxLines: widget.type == PostCardType.detail ? null : 2,
      overflow:
          widget.type == PostCardType.detail ? null : TextOverflow.ellipsis,
      style: FontManager.YaHeiRegular.copyWith(
        color: ColorUtil.boldTextColor,
      ),
    );

    List<Widget> rowList = [];

    rowList.add(Expanded(
      child: Column(
        children: [
          Row(children: [TagShowWidget(tag.data.toString().substring(1)), SizedBox(width: 8), campus]),
          SizedBox(height: 8),
          content,
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    ));

    if (widget.type == PostCardType.simple &&
        (post.topImgUrl?.isNotEmpty ?? false)) {
      rowList.addAll([
        SizedBox(width: 10),
        Image.network(
          post.topImgUrl,
          width: 80,
          height: 60,
          fit: BoxFit.cover,
        ),
      ]);
    }

    var middleWidget = Row(children: rowList);

    var mainWidget = (tap) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 5),
              Row(
                children: [
                  title,
                  SizedBox(width: 10),
                  if(post.isSolved == 1) SolvedWidget(),
                  if(post.isSolved == 0 && post.tags[0].name != "小树洞") UnSolvedWidget(),
                ],
              ),
              SizedBox(height: 5),
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

    var collectButton = CollectWidget(
      onCollectPressed: (boolNotifier) async {
        FeedbackService.postHitFavorite(
          id: post.id,
          isFavorite: post.isFavorite,
          onSuccess: () {
            widget.onFavoritePressed?.call(boolNotifier.value);
            post.isFavorite = !post.isFavorite;
          },
          onFailure: (e) {
            boolNotifier.value = boolNotifier.value;
            ToastProvider.error(e.error.toString());
          },
        );
      },
      isCollect: post.isFavorite,
    );

    var createTime = Text(
      post.createTime.time,
      textAlign: TextAlign.right,
      style: FontManager.Aspira.copyWith(
        color: ColorUtil.lightTextColor,
        fontSize: 12,
        textBaseline: TextBaseline.ideographic,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.3,

      ),
    );

    List<Widget> commentCount = [
      ClipOval(
        child: Icon(
          Icons.message_outlined,
          size: 16,
          color: ColorUtil.boldTextColor,
        ),
      ),
      SizedBox(width: 6),
      Text(
        post.commentCount.toString(),
        style: FontManager.YaHeiRegular.copyWith(
            fontSize: 14, color: ColorUtil.boldTextColor),
      )
    ];

    var likeWidget = LikeWidget(
      count: post.likeCount,
      onLikePressed: (isLiked, likeCount, success, failure) async {
        await FeedbackService.postHitLike(
          id: post.id,
          isLiked: post.isLiked,
          onSuccess: () {
            widget.onLikePressed?.call(!isLiked, likeCount);
            post.isLiked = !isLiked;
            post.likeCount = likeCount;
            success.call();
          },
          onFailure: (e) {
            ToastProvider.error(e.error.toString());
            failure.call();
          },
        );
      },
      isLiked: post.isLiked,
    );

    var unlikeWidget = LikeButton(
      likeBuilder: (bool isLiked) {
        if (isLiked) {
          return Icon(
            Icons.thumb_down,
            size: 16,
            color: Colors.blueGrey[900],
          );
        } else {
          return Icon(
            Icons.thumb_down_outlined,
            size: 16,
            color: ColorUtil.boldTextColor,
          );
        }
      },
      circleColor:
      CircleColor(start: Colors.black12, end: Colors.blue[200]),
      bubblesColor: BubblesColor(
        dotPrimaryColor: Colors.blueGrey,
        dotSecondaryColor: Colors.black26,
      ),
      animationDuration: Duration(milliseconds: 600),
      padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
    );


    var commentAndLike = [
      ...commentCount,
      SizedBox(width: 5),
      // Like count.
      likeWidget,
      SizedBox(width: 5),
      unlikeWidget
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
          collectButton,
        ]);

        if (post.imgUrlList.isNotEmpty) {
          var imageList = Row(
            children: List.generate(
              post.imgUrlList.length,
              (index) => _image(index, context),
            ),
          );
          imagesWidget.addAll([
            SizedBox(height: 10),
            imageList,
          ]);
        }

        imagesWidget.add(
          SizedBox(height: 10),
        );
        break;
    }

    var bottomWidget = Row(children: bottomList);

    var decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
            blurRadius: 5,
            color: Color.fromARGB(64, 236, 237, 239),
            offset: Offset(0, 0),
            spreadRadius: 3),
      ],
    );

    var body = FeedbackBannerWidget(
      showBanner: widget.showBanner,
      questionId: post.id,
      builder: (tap) => Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            mainWidget(tap),
            ...imagesWidget,
            bottomWidget,
          ],
        ),
        decoration: decoration,
      ),
    );

    return DefaultTextStyle(
      style: FontManager.YaHeiRegular,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: ClipCopy(
          toast: '复制提问成功',
          copy: post.content,
          child: body,
        ),
      ),
    );
  }

  _image(index, context) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, FeedbackRouter.imageView, arguments: {
            "urlList": post.imgUrlList,
            "urlListLength": post.imgUrlList.length,
            "indexNow": index
          });
        },
        child: FadeInImage.memoryNetwork(
            fit: BoxFit.cover,
            height: 200 - (post.thumbImgUrlList.length) * 40.0,
            placeholder: kTransparentImage,
            image: post.thumbImgUrlList[index]),
      ),
    );
  }
}

final Uint8List kTransparentImage = Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE
]);

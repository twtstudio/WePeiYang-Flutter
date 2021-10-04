import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/util/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/clip_copy.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/collect_widget.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/like_widget.dart';
import 'package:we_pei_yang_flutter/message/feedback_banner_widget.dart';

enum PostCardType { simple, detail }

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onContentPressed;
  final VoidCallback onLikePressed;
  final VoidCallback onFavoritePressed;
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
  }) : type = PostCardType.simple;

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
  Widget build(BuildContext context) {
    var title = Expanded(
      child: Text(
        post.title,
        maxLines: type == PostCardType.detail ? 3 : 1,
        overflow: TextOverflow.ellipsis,
        style: FontManager.YaHeiRegular.copyWith(
          color: ColorUtil.boldTextColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    var topWidget = Row(
      children: [
        title,
        if (post.isSolved == 1)
          Text(
            '官方已回复',
            style: FontManager.YaHeiRegular.copyWith(
                color: ColorUtil.boldTextColor, fontSize: 12),
          ),
      ],
    );

    var tag = Text(
      (post.tags?.length ?? 0) > 0 ? '#${post.tags[0].name}' : '#无标签',
      style: FontManager.YaHeiRegular.copyWith(
          fontSize: 13, color: ColorUtil.lightTextColor),
    );

    var content = Text(
      post.content,
      maxLines: type == PostCardType.detail ? null : 2,
      overflow: type == PostCardType.detail ? null : TextOverflow.ellipsis,
      style: FontManager.YaHeiRegular.copyWith(
        color: ColorUtil.boldTextColor,
      ),
    );

    List<Widget> rowList = [];

    rowList.add(Expanded(
      child: Column(
        children: [
          tag,
          SizedBox(height: 5),
          content,
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    ));

    if (type == PostCardType.simple && (post.topImgUrl?.isNotEmpty ?? false)) {
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
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 5),
              topWidget,
              SizedBox(height: 5),
              middleWidget,
            ],
          ),
          onTap: () async {
            onContentPressed?.call();
            await tap?.call();

            Navigator.pushNamed(
              context,
              FeedbackRouter.detail,
              arguments: post,
            );
          },
          onLongPress: onContentLongPressed,
        );

    var collectButton = CollectWidget(
      onCollectPressed: (boolNotifier) async {
        onFavoritePressed?.call();
        FeedbackService.postHitFavorite(
          id: post.id,
          isFavorite: post.isLiked,
          onSuccess: null,
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
      style: FontManager.YaHeiRegular.copyWith(
        color: ColorUtil.lightTextColor,
        fontSize: 12,
      ),
    );

    List<Widget> commentCount = [
      ClipOval(
        child: Icon(
          Icons.message_outlined,
          size: 16,
          color: ColorUtil.lightTextColor,
        ),
      ),
      SizedBox(width: 6),
      Text(
        post.commentCount.toString(),
        style: FontManager.YaHeiRegular.copyWith(
            fontSize: 14, color: ColorUtil.lightTextColor),
      )
    ];

    var likeWidget = LikeWidget(
      count: post.likeCount,
      onLikePressed: (boolNotifier) async {
        onLikePressed?.call();

        FeedbackService.postHitLike(
          id: post.id,
          isLiked: post.isLiked,
          onSuccess: null,
          onFailure: (e) {
            boolNotifier.value = boolNotifier.value;
            ToastProvider.error(e.error.toString());
          },
        );
        return true;
      },
      isLiked: post.isLiked,
    );

    var commentAndLike = [
      ...commentCount,
      SizedBox(width: 5),
      // Like count.
      likeWidget,
    ];

    List<Widget> bottomList = [];
    List<Widget> imagesWidget = [];

    switch (type) {
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
      showBanner: showBanner,
      questionId: post.id,
      builder: (tap) => Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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

import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/feedback/model/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/util/screen_util.dart';
import 'package:we_pei_yang_flutter/message/feedback_banner_widget.dart';
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

// ignore: must_be_immutable
class PostCard extends StatefulWidget {
  Post post;
  bool enableTopImg;
  bool enableImgList;
  void Function() onContentPressed = () {};
  void Function() onLikePressed = () {};
  void Function() onFavoritePressed = () {};
  void Function() onContentLongPressed = () {};
  bool showBanner;
  bool singleLineTitle;

  @override
  State createState() {
    return _PostCardState(post, enableTopImg, enableImgList, onContentPressed,
        onLikePressed, onFavoritePressed, onContentLongPressed);
  }

  /// Card without top image and content images.
  PostCard(this.post,
      {void Function() onContentPressed,
      void Function() onLikePressed,
      void Function() onFavoritePressed,
      void Function() onContentLongPressed,
      this.showBanner = false}) {
    this.post = post;
    this.enableTopImg = false;
    this.enableImgList = false;
    this.onContentPressed = onContentPressed;
    this.onLikePressed = onLikePressed;
    this.onFavoritePressed = onFavoritePressed;
    this.onContentLongPressed = onContentLongPressed;
    this.singleLineTitle = true;
  }

  /// Card with top image.
  PostCard.image(post,
      {void Function() onContentPressed,
      void Function() onLikePressed,
      void Function() onFavoritePressed,
      void Function() onContentLongPressed,
      this.showBanner = false}) {
    this.post = post;
    this.enableTopImg = true;
    this.enableImgList = false;
    this.onContentPressed = onContentPressed;
    this.onLikePressed = onLikePressed;
    this.onFavoritePressed = onFavoritePressed;
    this.onContentLongPressed = onContentLongPressed;
    this.singleLineTitle = true;
  }

  /// Card for DetailPage.
  PostCard.detail(post,
      {void Function() onContentPressed,
      void Function() onLikePressed,
      void Function() onFavoritePressed,
      void Function() onContentLongPressed,
      this.showBanner = false}) {
    this.post = post;
    this.enableTopImg = false;
    this.enableImgList = true;
    this.onContentPressed = onContentPressed;
    this.onLikePressed = onLikePressed;
    this.onFavoritePressed = onFavoritePressed;
    this.onContentLongPressed = onContentLongPressed;
    this.singleLineTitle = false;
  }
}

class _PostCardState extends State<PostCard> {
  final Post post;
  final bool enableTopImg;
  final bool enableImgList;
  final void Function() onContentPressed;
  final void Function() onLikePressed;
  final void Function() onFavoritePressed;
  final void Function() onContentLongPressed;

  _PostCardState(
      this.post,
      this.enableTopImg,
      this.enableImgList,
      this.onContentPressed,
      this.onLikePressed,
      this.onFavoritePressed,
      this.onContentLongPressed);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: FontManager.YaHeiRegular,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: GestureDetector(
          onLongPress: () {
            ClipboardData data = new ClipboardData(text: post.content);
            Clipboard.setData(data);
            ToastProvider.success('复制提问成功');
          },
          child: FeedbackBannerWidget(
            showBanner: widget.showBanner ?? false,
            questionId: post.id,
            builder: (tap) => Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 5),
                        Row(
                          children: [
                            // Post title.
                            Expanded(
                              child: Text(
                                post.title,
                                maxLines: widget.singleLineTitle ? 1 : 3,
                                overflow: TextOverflow.ellipsis,
                                style: FontManager.YaHeiRegular.copyWith(
                                  color: ColorUtil.boldTextColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (post.isSolved == 1)
                              Text(
                                '官方已回复',
                                style: FontManager.YaHeiRegular.copyWith(
                                    color: ColorUtil.boldTextColor,
                                    fontSize: 12),
                              ),
                          ],
                        ),
                        SizedBox(height: 5),
                        // Tag.
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    (post.tags?.length ?? 0) > 0
                                        ? '#${post.tags[0].name}'
                                        : '#无标签',
                                    style: FontManager.YaHeiRegular.copyWith(
                                        fontSize: 13,
                                        color: ColorUtil.lightTextColor),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    post.content,
                                    maxLines: enableImgList ? null : 2,
                                    overflow: enableImgList
                                        ? null
                                        : TextOverflow.ellipsis,
                                    style: FontManager.YaHeiRegular.copyWith(
                                      color: ColorUtil.boldTextColor,
                                    ),
                                  ),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                            ),
                            if (enableTopImg) SizedBox(width: 10),
                            // Thumbnail when top image enabled.
                            if (enableTopImg)
                              Image.network(
                                post.topImgUrl,
                                width: 80,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () async {
                      onContentPressed();
                      await tap?.call();
                    },
                    onLongPress: onContentLongPressed,
                  ),
                  if (enableImgList && post.imgUrlList.length != 0)
                    SizedBox(height: 10),
                  // Image list.
                  if (enableImgList && post.imgUrlList.length != 0)
                    Row(
                      children: [
                        for (int i = 0; i < post.imgUrlList.length; i++)
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, FeedbackRouter.imageView,
                                    arguments: {
                                      "urlList": post.imgUrlList,
                                      "urlListLength": post.imgUrlList.length,
                                      "indexNow": i
                                    });
                              },
                              child: FadeInImage.memoryNetwork(
                                  fit: BoxFit.cover,
                                  height: 200 -
                                      (post.thumbImgUrlList.length) * 40.0,
                                  placeholder: ScreenUtil.kTransparentImage,
                                  image: post.thumbImgUrlList[i]),
                            ),
                          ),
                      ],
                    ),
                  if (enableImgList) SizedBox(height: 10),

                  Row(
                    children: [
                      // Time.
                      if (enableImgList)
                        Text(
                          post.createTime.substring(0, 10) +
                              '  ' +
                              (post.createTime
                                      .substring(11)
                                      .split('.')[0]
                                      .startsWith('0')
                                  ? post.createTime
                                      .substring(12)
                                      .split('.')[0]
                                      .substring(0, 4)
                                  : post.createTime
                                      .substring(11)
                                      .split('.')[0]
                                      .substring(0, 5)),
                          style: FontManager.YaHeiRegular.copyWith(
                            color: ColorUtil.lightTextColor,
                          ),
                        ),
                      if (enableImgList) Spacer(),
                      // Comment count
                      ClipOval(
                        child: InkWell(
                          child: Icon(
                            Icons.message_outlined,
                            size: 16,
                            color: ColorUtil.lightTextColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        post.commentCount.toString(),
                        style: FontManager.YaHeiRegular.copyWith(
                            fontSize: 14, color: ColorUtil.lightTextColor),
                      ),
                      SizedBox(width: 5),
                      // Like count.
                      SizedBox(
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LikeButton(
                              likeBuilder: (bool isLiked) {
                                if (post.isLiked) {
                                  return Icon(
                                    Icons.thumb_up,
                                    size: 16,
                                    color: Colors.redAccent,
                                  );
                                } else {
                                  return Icon(
                                    Icons.thumb_up_outlined,
                                    size: 16,
                                    color: ColorUtil.lightTextColor,
                                  );
                                }
                              },
                              onTap: (value) async {
                                Future.delayed(Duration(seconds: 4));
                                onLikePressed();
                                return !value;
                              },
                              circleColor: CircleColor(
                                  start: Colors.black12, end: Colors.redAccent),
                              bubblesColor: BubblesColor(
                                dotPrimaryColor: Colors.redAccent,
                                dotSecondaryColor: Colors.redAccent,
                              ),
                              animationDuration: Duration(milliseconds: 600),
                              padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                            ),
                            Text(
                              post.likeCount.toString(),
                              style: FontManager.YaHeiRegular.copyWith(
                                  fontSize: 14,
                                  color: ColorUtil.lightTextColor),
                            ),
                          ],
                        ),
                      ),
                      if (!enableImgList) Spacer(),
                      if (enableImgList) SizedBox(width: 5),
                      // Favorite.
                      if (enableImgList)
                        LikeButton(
                          likeBuilder: (bool isLiked) {
                            if (post.isFavorite) {
                              return Icon(
                                Icons.star,
                                size: 19,
                                color: Colors.amberAccent,
                              );
                            } else {
                              return Icon(
                                Icons.star_border_outlined,
                                size: 19,
                                color: ColorUtil.lightTextColor,
                              );
                            }
                          },
                          onTap: (value) async {
                            Future.delayed(Duration(seconds: 4));
                            onFavoritePressed();
                            return !value;
                          },
                          circleColor: CircleColor(
                              start: Colors.black12, end: Colors.yellow),
                          bubblesColor: BubblesColor(
                            dotPrimaryColor: Colors.amber,
                            dotSecondaryColor: Colors.amberAccent,
                          ),
                          animationDuration: Duration(milliseconds: 600),
                          padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                        ),
                      if (!enableImgList)
                        Text(
                          post.createTime.substring(0, 10) +
                              '  ' +
                              (post.createTime
                                      .substring(11)
                                      .split('.')[0]
                                      .startsWith('0')
                                  ? post.createTime
                                      .substring(12)
                                      .split('.')[0]
                                      .substring(0, 4)
                                  : post.createTime
                                      .substring(11)
                                      .split('.')[0]
                                      .substring(0, 5)),
                          style: FontManager.YaHeiRegular.copyWith(
                            color: ColorUtil.lightTextColor,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      blurRadius: 5,
                      color: Color.fromARGB(64, 236, 237, 239),
                      offset: Offset(0, 0),
                      spreadRadius: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

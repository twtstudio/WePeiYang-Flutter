import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/feedback/model/post.dart';
import 'package:wei_pei_yang_demo/feedback/util/color_util.dart';
import 'package:wei_pei_yang_demo/feedback/util/feedback_router.dart';
import 'package:wei_pei_yang_demo/feedback/util/screen_util.dart';
import 'package:wei_pei_yang_demo/feedback/view/components/blank_space.dart';
import 'package:wei_pei_yang_demo/message/feedback_banner_widget.dart';

typedef GesturePressedCallback = void Function();

// ignore: must_be_immutable
class PostCard extends StatefulWidget {
  Post post;
  bool enableTopImg;
  bool enableImgList;
  GesturePressedCallback onContentPressed = () {};
  GesturePressedCallback onLikePressed = () {};
  GesturePressedCallback onFavoritePressed = () {};
  GesturePressedCallback onContentLongPressed = () {};
  bool showBanner;

  @override
  State createState() {
    return _PostCardState(
        this.post,
        this.enableTopImg,
        this.enableImgList,
        this.onContentPressed,
        this.onLikePressed,
        this.onFavoritePressed,
        this.onContentLongPressed);
  }

  /// Card without top image and content images.
  PostCard(post,
      {GesturePressedCallback onContentPressed,
      GesturePressedCallback onLikePressed,
      GesturePressedCallback onFavoritePressed,
      GesturePressedCallback onContentLongPressed,
      this.showBanner = false}) {
    this.post = post;
    this.enableTopImg = false;
    this.enableImgList = false;
    this.onContentPressed = onContentPressed;
    this.onLikePressed = onLikePressed;
    this.onFavoritePressed = onFavoritePressed;
    this.onContentLongPressed = onContentLongPressed;
  }

  /// Card with top image.
  PostCard.image(post,
      {GesturePressedCallback onContentPressed,
      GesturePressedCallback onLikePressed,
      GesturePressedCallback onFavoritePressed,
      GesturePressedCallback onContentLongPressed,
      this.showBanner = false}) {
    this.post = post;
    this.enableTopImg = true;
    this.enableImgList = false;
    this.onContentPressed = onContentPressed;
    this.onLikePressed = onLikePressed;
    this.onFavoritePressed = onFavoritePressed;
    this.onContentLongPressed = onContentLongPressed;
  }

  /// Card for DetailPage.
  PostCard.detail(post,
      {GesturePressedCallback onContentPressed,
      GesturePressedCallback onLikePressed,
      GesturePressedCallback onFavoritePressed,
      GesturePressedCallback onContentLongPressed,
      this.showBanner = false}) {
    this.post = post;
    this.enableTopImg = false;
    this.enableImgList = true;
    this.onContentPressed = onContentPressed;
    this.onLikePressed = onLikePressed;
    this.onFavoritePressed = onFavoritePressed;
    this.onContentLongPressed = onContentLongPressed;
  }
}

class _PostCardState extends State<PostCard> {
  final Post post;
  final bool enableTopImg;
  final bool enableImgList;
  final GesturePressedCallback onContentPressed;
  final GesturePressedCallback onLikePressed;
  final GesturePressedCallback onFavoritePressed;
  final GesturePressedCallback onContentLongPressed;

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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
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
                    BlankSpace.height(5),
                    Row(
                      children: [
                        // Post title.
                        Expanded(
                          child: Text(
                            post.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ColorUtil.boldTextColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                        ),
                        if (post.isSolved == 1)
                          Text(
                            '已解决',
                            style: TextStyle(
                                color: ColorUtil.boldTextColor, fontSize: 12),
                          ),
                      ],
                    ),
                    BlankSpace.height(5),
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
                                style:
                                    TextStyle(color: ColorUtil.lightTextColor),
                              ),
                              BlankSpace.height(5),
                              Text(
                                post.content,
                                maxLines: enableImgList ? null : 2,
                                overflow: enableImgList
                                    ? null
                                    : TextOverflow.ellipsis,
                                style: TextStyle(
                                  height: 1,
                                  color: ColorUtil.boldTextColor,
                                ),
                              ),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                        ),
                        if (enableTopImg) BlankSpace.width(10),
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
                BlankSpace.height(10),
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
                                arguments: post.imgUrlList[i]);
                          },
                          child: FadeInImage.memoryNetwork(
                              fit: BoxFit.cover,
                              height:
                                  200 - (post.thumbImgUrlList.length) * 40.0,
                              placeholder: ScreenUtil.kTransparentImage,
                              image: post.thumbImgUrlList[i]),
                        ),
                      ),
                  ],
                ),
              if (enableImgList)
                BlankSpace.height(10),
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
                      style: TextStyle(
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
                  BlankSpace.width(6),
                  Text(
                    post.commentCount.toString(),
                    style: TextStyle(
                        fontSize: 14, color: ColorUtil.lightTextColor),
                  ),
                  BlankSpace.width(8),
                  // Like count.
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      // color: Colors.blue,
                      width: 40,
                      height: 25,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            !post.isLiked
                                ? Icons.thumb_up_outlined
                                : Icons.thumb_up,
                            size: 16,
                            color: !post.isLiked
                                ? ColorUtil.lightTextColor
                                : Colors.red,
                          ),
                          BlankSpace.width(6),
                          Text(
                            post.likeCount.toString(),
                            style: TextStyle(
                                fontSize: 14, color: ColorUtil.lightTextColor),
                          ),
                        ],
                      ),
                    ),
                    onTap: onLikePressed,
                  ),
                  if (!enableImgList) Spacer(),
                  if (enableImgList) BlankSpace.width(5),
                  // Favorite.
                  if (enableImgList)
                    Container(
                      width: 30,
                      height: 25,
                      // color: Colors.red,
                      child: InkWell(
                        child: Icon(
                          post.isFavorite ? Icons.star : Icons.star_border,
                          size: 20,
                          color: post.isFavorite
                              ? Colors.amber
                              : ColorUtil.lightTextColor,
                        ),
                        onTap: onFavoritePressed,
                      ),
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
                      style: TextStyle(
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/feedback/model/post.dart';
import 'package:wei_pei_yang_demo/feedback/util/color_util.dart';
import 'package:wei_pei_yang_demo/feedback/view/components/blank_space.dart';

typedef GesturePressedCallback = void Function();

// ignore: must_be_immutable
class PostCard extends StatefulWidget {
  Post post;
  bool enableTopImg;
  bool enableImgList;
  GesturePressedCallback onContentPressed = () {};
  GesturePressedCallback onLikePressed = () {};
  GesturePressedCallback onFavoritePressed = () {};

  @override
  State createState() {
    return _PostCardState(this.post, this.enableTopImg, this.enableImgList,
        this.onContentPressed, this.onLikePressed, this.onFavoritePressed);
  }

  /// Card without top image and content images.
  PostCard(post,
      {GesturePressedCallback onContentPressed,
      GesturePressedCallback onLikePressed,
      GesturePressedCallback onFavoritePressed}) {
    this.post = post;
    this.enableTopImg = false;
    this.enableImgList = false;
    this.onContentPressed = onContentPressed;
    this.onLikePressed = onLikePressed;
    this.onFavoritePressed = onFavoritePressed;
  }

  /// Card with top image.
  PostCard.image(post,
      {GesturePressedCallback onContentPressed,
      GesturePressedCallback onLikePressed,
      GesturePressedCallback onFavoritePressed}) {
    this.post = post;
    this.enableTopImg = true;
    this.enableImgList = false;
    this.onContentPressed = onContentPressed;
    this.onLikePressed = onLikePressed;
    this.onFavoritePressed = onFavoritePressed;
  }

  /// Card for DetailPage.
  PostCard.detail(post,
      {GesturePressedCallback onContentPressed,
      GesturePressedCallback onLikePressed,
      GesturePressedCallback onFavoritePressed}) {
    this.post = post;
    this.enableTopImg = false;
    this.enableImgList = true;
    this.onContentPressed = onContentPressed;
    this.onLikePressed = onLikePressed;
    this.onFavoritePressed = onFavoritePressed;
  }
}

class _PostCardState extends State<PostCard> {
  final Post post;
  final bool enableTopImg;
  final bool enableImgList;
  final GesturePressedCallback onContentPressed;
  final GesturePressedCallback onLikePressed;
  final GesturePressedCallback onFavoritePressed;

  _PostCardState(this.post, this.enableTopImg, this.enableImgList,
      this.onContentPressed, this.onLikePressed, this.onFavoritePressed);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
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
                // Avatar and user name when image list enabled.
                if (enableImgList)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/images/user_image.jpg',
                          fit: BoxFit.cover,
                          width: 20,
                          height: 20,
                        ),
                      ),
                      BlankSpace.width(5),
                      Expanded(
                        child: Text(
                          post.userName,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                              fontSize: 14, color: ColorUtil.lightTextColor),
                        ),
                      ),
                    ],
                  ),
                if (enableImgList) BlankSpace.height(5),
                // Tag.
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            post.tags.length > 0
                                ? '#${post.tags[0].name}'
                                : '#无标签',
                            style: TextStyle(color: ColorUtil.lightTextColor),
                          ),
                          BlankSpace.height(5),
                          Text(
                            post.content,
                            maxLines: enableImgList ? null : 2,
                            overflow:
                                enableImgList ? null : TextOverflow.ellipsis,
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
            onTap: onContentPressed,
          ),
          if (enableImgList && post.imgUrlList.length != 0)
            BlankSpace.height(10),
          // Image list.
          if (enableImgList && post.imgUrlList.length != 0)
            ListView.builder(
              itemBuilder: (context, index) =>
                  Image.network(post.imgUrlList[index]),
              itemCount: post.imgUrlList.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
            ),
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
              BlankSpace.width(8),
              Text(
                post.commentCount.toString(),
                style: TextStyle(fontSize: 14, color: ColorUtil.lightTextColor),
              ),
              BlankSpace.width(16),
              // Like count.
              GestureDetector(
                child: Row(
                  children: [
                    ClipOval(
                      child: Icon(
                        !post.isLiked
                            ? Icons.thumb_up_outlined
                            : Icons.thumb_up,
                        size: 16,
                        color: !post.isLiked
                            ? ColorUtil.lightTextColor
                            : Colors.red,
                      ),
                    ),
                    BlankSpace.width(8),
                    Text(
                      post.likeCount.toString(),
                      style: TextStyle(
                          fontSize: 14, color: ColorUtil.lightTextColor),
                    ),
                  ],
                ),
                onTap: onLikePressed,
              ),
              if (!enableImgList) Spacer(),
              // Avatar and user name.
              if (!enableImgList)
                ClipOval(
                  child: Image.asset(
                    'assets/images/user_image.jpg',
                    fit: BoxFit.cover,
                    width: 20,
                    height: 20,
                  ),
                ),
              if (enableImgList) BlankSpace.width(16),
              // Favorite.
              if (enableImgList)
                ClipOval(
                  child: InkWell(
                    child: Icon(
                      post.isFavorite ? Icons.star : Icons.star_border,
                      size: 16,
                      color: post.isFavorite
                          ? Colors.amber
                          : ColorUtil.lightTextColor,
                    ),
                    onTap: onFavoritePressed,
                  ),
                ),
              if (!enableImgList) BlankSpace.width(5),
              // TODO: Long user name may cause overflow.
              if (!enableImgList)
                Text(
                  post.userName,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style:
                      TextStyle(fontSize: 14, color: ColorUtil.lightTextColor),
                ),
            ],
          ),
          BlankSpace.height(5),
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
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
    );
  }
}

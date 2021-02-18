import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/feedback/model/post.dart';
import 'package:wei_pei_yang_demo/feedback/util/color_util.dart';
import 'package:wei_pei_yang_demo/feedback/view/components/blank_space.dart';

// ignore: must_be_immutable
class PostCard extends StatefulWidget {
  Post post;
  bool enableTopImg;
  bool enableImgList;

  @override
  State createState() {
    return _PostCardState(this.post, this.enableTopImg, this.enableImgList);
  }

  /// Card without top image and content images.
  PostCard(post) {
    this.post = post;
    this.enableTopImg = false;
    this.enableImgList = false;
  }

  /// Card with top image.
  PostCard.image(post) {
    this.post = post;
    this.enableTopImg = true;
    this.enableImgList = false;
  }

  /// Card for DetailPage.
  PostCard.detail(post) {
    this.post = post;
    this.enableTopImg = false;
    this.enableImgList = true;
  }
}

class _PostCardState extends State<PostCard> {
  final Post post;
  final bool enableTopImg;
  final bool enableImgList;

  _PostCardState(this.post, this.enableTopImg, this.enableImgList);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: InkWell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          post.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: ColorUtil.boldTextColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
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
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '#' + post.tags[0].name,
                              style: TextStyle(color: ColorUtil.lightTextColor),
                            ),
                            BlankSpace.height(5),
                            Text(
                              post.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                      ),
                      if (enableTopImg) BlankSpace.width(10),
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
            ),
            // TODO: Image list here.
            BlankSpace.height(10),
            Row(
              children: [
                ClipOval(
                  child: InkWell(
                    child: Icon(
                      Icons.message_outlined,
                      size: 16,
                      color: ColorUtil.lightTextColor,
                    ),
                    onTap: () {},
                  ),
                ),
                BlankSpace.width(8),
                Text(
                  post.commentCount.toString(),
                  style:
                      TextStyle(fontSize: 14, color: ColorUtil.lightTextColor),
                ),
                BlankSpace.width(16),
                ClipOval(
                  child: InkWell(
                    child: Icon(
                      !post.isLiked ? Icons.thumb_up_outlined : Icons.thumb_up,
                      size: 16,
                      color:
                          !post.isLiked ? ColorUtil.lightTextColor : Colors.red,
                    ),
                    onTap: () {},
                  ),
                ),
                BlankSpace.width(8),
                Text(
                  post.likeCount.toString(),
                  style:
                      TextStyle(fontSize: 14, color: ColorUtil.lightTextColor),
                ),
                // TODO: Do not display Spacer and Avatar here when imgList display enabled.
                Spacer(),
                ClipOval(
                  child: Image.asset(
                    'assets/images/user_image.jpg',
                    fit: BoxFit.cover,
                    width: 20,
                    height: 20,
                  ),
                ),
                BlankSpace.width(5),
                // TODO: Long user name may cause overflow.
                Text(
                  post.userName,
                  style:
                      TextStyle(fontSize: 14, color: ColorUtil.lightTextColor),
                ),
              ],
            ),
            BlankSpace.height(5),
          ],
        ),
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

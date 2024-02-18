import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../view/components/widget/icon_widget.dart';
import 'base64_image_ui.dart';
// 确保导入了所有必要的包，比如你自定义的Widget或其他依赖

class RatingCommentBlock extends StatelessWidget {
  final int index;

  RatingCommentBlock({Key? key, required this.index}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    /***************************************************************
        变量
     ***************************************************************/
    double screenWidth = MediaQuery.of(context).size.width;
    double mm = screenWidth * 0.9 / 60; //获取现实中1毫米的像素长度

    /***************************************************************
        圆形用户图片
     ***************************************************************/
    Widget userImage = Base64Image(
      base64String:
      "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAMwAAADACAMAAAB/Pny7AAAAA1BMVEWFhYWbov8QAAAAPUlEQVR4nO3BMQEAAADCoPVPbQ0PoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAvgyZwAABCrx9CgAAAABJRU5ErkJggg==",
      width: 6 * mm,
      height: 6 * mm,
    );
    userImage = ClipRRect(
      borderRadius: BorderRadius.circular(5 * mm),
      child: userImage,
    );

    /***************************************************************
        用户名与评分与评论与点赞按钮
     ***************************************************************/

    Widget body = Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              userImage,
              Container(
                width: 2 * mm,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "用户名称",
                    style: TextStyle(
                      fontSize: 3 * mm,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    height: 1 * mm,
                  ),
                  // 确保RatingBar.builder在这里能正常工作，或者根据需要替换为相似的Widget
                  RatingBar.builder(
                    initialRating: 3.5,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 3 * mm,
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.lightBlue,
                    ),
                    onRatingUpdate: (rating) {
                      print(rating);
                    },
                  ),
                  Container(
                    height: 2 * mm,
                  ),
                  Text(
                    "评论内容",
                    style: TextStyle(
                      fontSize: 3 * mm,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    height: 2 * mm,
                  ),
                  // 确保IconWidget在这里能正常工作，或者根据需要替换为相似的Widget
                  IconWidget(
                    IconType.like,
                    count: 123,
                    onLikePressed:
                        (isLike, likeCount, success, failure) async {
                      success();
                    },
                    isLike: true,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    /***************************************************************
        合并
     ***************************************************************/

    return Column(
      children: [
        Container(
          height: 2 * mm,
        ),
        body,
        Container(
          height: 2 * mm,
        ),
      ],
    );
  }
}

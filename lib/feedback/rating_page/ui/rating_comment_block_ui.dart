import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/comment_like_button.dart';

import '../../view/components/widget/icon_widget.dart';
import '../modle/rating/rating_page_data.dart';
import 'base64_image_ui.dart';
// 确保导入了所有必要的包，比如你自定义的Widget或其他依赖

class RatingCommentBlock extends StatefulWidget {
  final DataIndex dataIndex;

  RatingCommentBlock({Key? key, required this.dataIndex}) : super(key: key);

  @override
  _RatingCommentBlockState createState() => _RatingCommentBlockState();
}

class _RatingCommentBlockState extends State<RatingCommentBlock> {
  @override
  void initState() {
    loadUI();
    super.initState();
  }

  /***************************************************************
      变量
   ***************************************************************/
  String userId = " ";
  String userImageBase64 = " ";
  String userName = "虚位以待~";

  String updateAt = "2024-3-3";
  double ratingValue = 5.0;
  String commentContext = "......";
  int likeCount = 0;

  loadUI() async {
    bool stopFlag = true;
  }

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
      base64String: userImageBase64,
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
                    userName,
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
                    initialRating: ratingValue,
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
                ],
              ),
              Container(
                width: 2 * mm,
              ),
              LikeButton(),
            ],
          ),
          Center(
            child: Container(
              width: screenWidth * 0.7,
              child: Text(
                commentContext,
                style: TextStyle(
                  fontSize: 3 * mm,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          Container(
            height: (widget.dataIndex == NullDataIndex) ? 2 * mm : 0,
          ),
          Center(
            child: Container(
              color: Colors.grey.withOpacity(0.4),
              width: screenWidth*0.8,
              height: 0.5 * mm,
            )
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

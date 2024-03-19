import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/user_data.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/delete_button.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/like_ui.dart';

import '../modle/rating/rating_page_data.dart';
import 'base64_image_ui.dart';
//离散数学知道吗,跟这个没关系
//非常好注释,使代码可维护性旋转

//我觉得这个网络层写得不好,但是很难再重构了
//当时应该考虑接口json数据格式变更的情况

//元神怎么你了

class RatingCommentBlock extends StatefulWidget {
  final DataIndex dataIndex;

  RatingCommentBlock({Key? key, required this.dataIndex}) : super(key: key);

  @override
  _RatingCommentBlockState createState() => _RatingCommentBlockState();
}

class _RatingCommentBlockState extends State<RatingCommentBlock> {
  @override
  void initState() {
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
  String commentContent = " ";
  List<String> likeId = [];
  int likeCount = 0;

  List<String> getLikeId(String likeId){
    return likeId.contains("!@#%") ? likeId.split("!@#%") : [];
  }

  /***************************************************************
      加载UI
   ***************************************************************/
//////////////////////////////////////////////////////
  DataIndexLeaf myLeaf() =>
      context
          .read<RatingPageData>()
          .getDataIndexLeaf(widget.dataIndex);
//////////////////////////////////////////////////////
  RatingPageUser myUser(String userId) =>
      context
          .read<RatingUserData>()
          .getUser(userId);
//////////////////////////////////////////////////////
  loadUI() async {
    /************************************************
      "userId": 1,
      "userName": "云云",
      "userImg": "1231213123"

      "commentContent": "test",
      "commentCreator": "55442",
      "ratingValue": 0.0,
      "updatedAt": "2024-03-03T22:08:59",
      "commentImage": " ",
      "createdAt": "2024-03-03T22:08:59",
      "likeCount": 0,
      "likeId": " ",
      "object": 27,
      "commentId": 1
    ************************************************/
    try{
      assert(widget.dataIndex != NullDataIndex);
    }
    catch(e){
      return;
    }
//////////////////////////////////////////////////////
    try{
      assert(myLeaf().isSucceed("get"));
      ////////////////////////////////////////////////
      try{
        userId = myLeaf()
            .dataM["get"]!['commentCreator'];
        assert(myUser(userId).isSucceed("get"));
        userImageBase64 = myUser(userId)
            .dataM["get"]!['userImg'];
        userName = myUser(userId)
            .dataM["get"]!['userName'];
      }
      catch(e){
        throw("user数据错误");
      }
      ////////////////////////////////////////////////
      try{
        updateAt = myLeaf()
            .dataM["get"]!['updatedAt'];
        ratingValue = myLeaf()
            .dataM["get"]!['ratingValue'];
        commentContent = myLeaf()
            .dataM["get"]!['commentContent'];
        likeId = getLikeId(
            myLeaf().dataM["get"]!['likeId']
        );
        likeCount =
            myLeaf().dataM["get"]!['likeCount']
        ;
      }
      catch(e){
        throw(e);
      }
      ////////////////////////////////////////////////
      setState(() {});
      //debugOutput(context, "加载评论");
    }
    catch(e){
      print(e.toString());
      //200毫秒重试
      Future.delayed(Duration(milliseconds: 200), () {
        loadUI();
      });
      return;
    }
//////////////////////////////////////////////////////
  }

  @override
  Widget build(BuildContext context) {
    loadUI();
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
          Center(
            child: Container(
              width: 0.9*screenWidth,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  userImage,
                  Container(
                    width: 2 * mm,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            userName,
                            style: TextStyle(fontFamily: "NotoSansHans",
                              fontSize: 3 * mm,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            width: 2 * mm,
                          ),
                          Text(
                            updateAt,
                            style: TextStyle(fontFamily: "NotoSansHans",
                              fontSize: 2 * mm,
                              color: Colors.grey,
                            ),
                          )
                        ],
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
                  Spacer(),
                  LikeButton(
                    dataIndex: widget.dataIndex,
                  ),
                  Container(
                    width: 4 * mm,
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              width: screenWidth * 0.7,
              child: Text(
                commentContent,
                style: TextStyle(fontFamily: "NotoSansHans",
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
              color: Colors.grey.withOpacity(0.05),
              width: screenWidth*0.8,
              height: 0.4 * mm,
            )
          ),
        ],
      ),
    );

    /***************************************************************
        合并
     ***************************************************************/

    Widget allInOne = Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 2 * mm,
          ),
          body,
          Container(
            height: 2 * mm,
          ),
        ],
      ),
    );

    allInOne = GestureDetector(
      onLongPressStart: (details) {
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy,
            details.globalPosition.dx,
            details.globalPosition.dy,
          ),
          items: <PopupMenuEntry>[
            PopupMenuItem(
              child: Row(
                children: [
                  DeleteButton(
                    dataIndex: widget.dataIndex,
                  ),
                  Text("删除评论~",style: TextStyle(color:Colors.grey, fontFamily: "NotoSansHans",fontWeight: FontWeight.bold),),
                ],
              ),
              value: 1,
            ),
          ],
        );
      },
      child: allInOne,
    );

    return allInOne;


  }
}

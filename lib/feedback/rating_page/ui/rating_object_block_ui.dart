//评分主题页面下的组件
//用于展示评分对象
import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/create/create_comment.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/rating_page_data.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/base64_image_ui.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/rating_comment_block_ui.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/star_ui.dart';
import '../../view/components/widget/icon_widget.dart';
import '../page/main_part/object_page.dart';
import '../page/main_part/theme_page.dart';
import 'loading_dot.dart';

class hotComment {
  String creatorImg = " ";
  String creatorName = "加载中";
  double ratingValue = 5.0;
  String commentContext = "加载中";
  int likeCount = 0;

  hotComment(this.creatorImg, this.creatorName, this.ratingValue,
      this.commentContext, this.likeCount);
}

//用来展现评分主题的方块组件
class RatingObjectBlock extends StatefulWidget {
  DataIndex dataIndex;
  ScrollController scrollController;

  RatingObjectBlock({required this.dataIndex, required this.scrollController});

  @override
  _RatingObjectBlockState createState() => _RatingObjectBlockState();
}

class _RatingObjectBlockState extends State<RatingObjectBlock> {

  @override
  void initState() {
    UI.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  bool isScroll() {
    return widget.scrollController.position.isScrollingNotifier.value;
  }

  @override
  void dispose() {
    super.dispose();
  }

  /***************************************************************
      变量
   ***************************************************************/
  //评分对象图片
  String objectImageBase64 = " ";
  String objectName = "加载中";
  String objectDescribe = "加载中";
  double objectRating = 0.0;
  int commentCount = 0;

  List<DataIndex> hotCommentIndexL = [NullDataIndex,NullDataIndex];

  ValueNotifier<bool> UI = ValueNotifier<bool>(false);

  //还是pvp大佬
  Future<void> loadUI() async {
    bool stopFlag = true;
    try {
      //先加载叶片
      if (context
          .read<RatingPageData>()
          .getDataIndexLeaf(widget.dataIndex)
          .isSucceed("get")
      ) {
        objectImageBase64 = context
            .read<RatingPageData>()
            .getDataIndexLeaf(widget.dataIndex)
            .dataM["get"]!["objectImage"];
        objectName = context
            .read<RatingPageData>()
            .getDataIndexLeaf(widget.dataIndex)
            .dataM["get"]!["objectName"];
        objectDescribe = context
            .read<RatingPageData>()
            .getDataIndexLeaf(widget.dataIndex)
            .dataM["get"]!["objectDescribe"];
        objectRating = context
            .read<RatingPageData>()
            .getDataIndexLeaf(widget.dataIndex)
            .dataM["get"]!["objectRating"];
        commentCount = context
            .read<RatingPageData>()
            .getDataIndexLeaf(widget.dataIndex)
            .dataM["get"]!["commentCount"];
      } else {
        stopFlag = false;
      }
      //在加载索引,索引后加载子叶片
      if(
      context
          .read<RatingPageData>()
          .getDataIndexTree(widget.dataIndex)
          .isFinish()
      ){
        hotCommentIndexL = context
            .read<RatingPageData>()
            .getDataIndexTree(widget.dataIndex)
            .children['hot']!;
      } else {
        stopFlag = false;
      }
    } catch (e) {
      //powerLog(e.toString());
      stopFlag = true;
    }

    if (!stopFlag) {
      //等待200毫秒后
      Timer(Duration(milliseconds: 200), () {
        loadUI();
      });
    }
    else{
      UI.value = !UI.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    loadUI();
    /***************************************************************
        变量
     ***************************************************************/
    double screenWidth = MediaQuery.of(context).size.width;
    double mm = screenWidth * 0.9 / 60; //获取现实中1毫米的像素长度

    var radius = BorderRadius.circular(8);

    /***************************************************************
        评分对象图片
     ***************************************************************/

    Widget objectImage = Base64Image(
      base64String:
          objectImageBase64,
      width: 15 * mm,
      height: 21 * mm,
    );

    //裁剪圆角
    objectImage = ClipRRect(
      borderRadius: radius,
      child: objectImage,
    );

    /***************************************************************
        评分对象名称与简介
     ***************************************************************/

    Widget objectTitle = Container(
      width: 15 * mm,
      height: 20 * mm,
      child: Column(
        //靠左
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            objectName,
            style: TextStyle(
              fontSize: 3 * mm,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            height: 3 * mm,
          ),
          Text(
            objectDescribe,
            style: TextStyle(
              fontSize: 2 * mm,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );

    /***************************************************************
        评分组件与评分与评分人数
     ***************************************************************/

    Widget ratingWidget = Container(
      width: 20 * mm,
      height: 20 * mm,
      child: Column(
        //居中
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          StarUI(
            rating: objectRating,
            size: 4 * mm,
            onRatingUpdate: (rating) {
              showCommentDialog(context, rating, widget.dataIndex);
            },
          ),
          Container(
            height: 3 * mm,
          ),
          Text(
            //转为double后保留一位小数点
            objectRating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 5 * mm,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            height: 1 * mm,
          ),
          Text(
            commentCount.toString()+"评分",
            style: TextStyle(
              fontSize: 2 * mm,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );

    /***************************************************************
        拼接上三组件
     ***************************************************************/

    Widget topPart = Container(
      width: screenWidth,
      height: 25 * mm,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          objectImage,
          Container(
            width: 3 * mm,
          ),
          objectTitle,
          Container(
            width: 2 * mm,
          ),
          ratingWidget,
        ],
      ),
    );

    topPart = Column(
      children: [
        Container(
          height: 0.5 * mm,
          width: screenWidth,
          color: Colors.grey.withOpacity(0.4),
        ),
        topPart,
        Container(
          height: 1 * mm,
        ),
        Container(
          height: 0.5 * mm,
          width: screenWidth,
          color: Colors.grey.withOpacity(0.4),
        ),
        Container(
          height: 1 * mm,
        ),
      ],
    );

    /***************************************************************
        热评标题与热评组件
     ***************************************************************/

    Widget hotCommentTitle = Container(
        width: 10 * mm,
        height: 5 * mm,
        child: Text(
          "热评",
          style: TextStyle(
            fontSize: 4 * mm,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ));

    /***************************************************************
        最后一步,拼接并裁剪所有组件
     ***************************************************************/

    Widget allInOne = Container(
        width: screenWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            topPart,
            hotCommentTitle,
          RatingCommentBlock(dataIndex: hotCommentIndexL.isNotEmpty ? hotCommentIndexL[0] : NullDataIndex),
          RatingCommentBlock(dataIndex: hotCommentIndexL.length > 1 ? hotCommentIndexL[1] : NullDataIndex),
          ],
        ));

    /***************************************************************
        填满页面宽度使得组件居中,并设置间隔
     ***************************************************************/

    allInOne = Container(
      width: screenWidth,
      child: Center(
        child: allInOne,
      ),
    );

    /***************************************************************
        点击后跳转页面
     ***************************************************************/

    allInOne = InkWell(
        onTap: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => ObjectPage(
                  dataIndex: widget.dataIndex,
                  objectBlock: topPart,
                ),
              ));
        },
        child: allInOne);

    allInOne = Container(
      child: allInOne,
    );

    /***************************************************************
        完成!
     ***************************************************************/

    return allInOne;
  }
}

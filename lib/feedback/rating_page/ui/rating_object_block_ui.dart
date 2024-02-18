//评分主题页面下的组件
//用于展示评分对象
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/rating_page_data.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/base64_image_ui.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/rating_comment_block_ui.dart';
import '../../view/components/widget/icon_widget.dart';
import '../page/main_part/object_page.dart';
import '../page/main_part/theme_page.dart';

//用来展现评分主题的方块组件
class RatingObjectBlock extends StatefulWidget {
  DataIndex dataIndex;

  RatingObjectBlock({required this.dataIndex});

  @override
  _RatingObjectBlockState createState() => _RatingObjectBlockState();
}

class _RatingObjectBlockState extends State<RatingObjectBlock> {
  late Timer changingDataTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    changingDataTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAMwAAADACAMAAAB/Pny7AAAAA1BMVEWFhYWbov8QAAAAPUlEQVR4nO3BMQEAAADCoPVPbQ0PoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAvgyZwAABCrx9CgAAAABJRU5ErkJggg==",
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
            "评分对象名称",
            style: TextStyle(
              fontSize: 3 * mm,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            height: 3 * mm,
          ),
          Text(
            "评分对象"
            "简介...",
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
          RatingBar.builder(
            initialRating: 3.5,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 4 * mm,
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.lightBlue,
            ),
            onRatingUpdate: (rating) {
              print(rating);
            },
          ),
          Container(
            height: 3 * mm,
          ),
          Text(
            "5.0",
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
            "1999评分",
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
        Divider(),
        topPart,
        Divider(),
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
            RatingCommentBlock(index: 1),
            RatingCommentBlock(index: 2),
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
                builder: (context) => ObjectPage(dataIndex: widget.dataIndex,objectBlock: topPart,),
              ));
        },
        child: allInOne);

    /***************************************************************
        完成!
     ***************************************************************/

    return allInOne;
  }
}

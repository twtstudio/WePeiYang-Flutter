import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/rating_page_data.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/base64_image_ui.dart';

import '../page/main_part/theme_page.dart';
import 'loading_dot.dart';


// Helper function to convert RGB to HSL
List<double> rgbToHsl(int r, int g, int b) {
  double red = r / 255;
  double green = g / 255;
  double blue = b / 255;

  double max_ = max(max(red, green), blue);
  double min_ = min(min(red, green), blue);

  double hue, saturation, lightness = (max_ + min_) / 2;

  if (max_ == min_) {
    hue = saturation = 0;
  } else {
    double d = max_ - min_;
    saturation = lightness > 0.5 ? d / (2 - max_ - min_) : d / (max_ + min_);

    if (max_ == red) {
      hue = (green - blue) / d + (green < blue ? 6 : 0);
    } else if (max_ == green) {
      hue = (blue - red) / d + 2;
    } else {
      hue = (red - green) / d + 4;
    }

    hue *= 60;
  }

  return [hue, saturation, lightness];
}

// Helper function to convert HSL to RGB
Color hslToColor(double hue, double saturation, double lightness) {
  double c = (1 - (2 * lightness - 1).abs()) * saturation;
  double x = c * (1 - (((hue / 60) % 2) - 1).abs());
  double m = lightness - c / 2;

  double red, green, blue;
  if (hue >= 0 && hue < 60) {
    red = c;
    green = x;
    blue = 0;
  } else if (hue >= 60 && hue < 120) {
    red = x;
    green = c;
    blue = 0;
  } else if (hue >= 120 && hue < 180) {
    red = 0;
    green = c;
    blue = x;
  } else if (hue >= 180 && hue < 240) {
    red = 0;
    green = x;
    blue = c;
  } else if (hue >= 240 && hue < 300) {
    red = x;
    green = 0;
    blue = c;
  } else {
    red = c;
    green = 0;
    blue = x;
  }

  int r = ((red + m) * 255).round();
  int g = ((green + m) * 255).round();
  int b = ((blue + m) * 255).round();

  return Color.fromARGB(255, r, g, b);
}

Color getInverseColor(Color baseColor) {
  // Convert RGB to HSL
  List<double> hsl = rgbToHsl(baseColor.red, baseColor.green, baseColor.blue);

  // Calculate analogous color by varying hue
  double hueOffset = (hsl[0] + 30) % 360;

  // Convert hue back to RGB
  Color bestColor = hslToColor(hueOffset, hsl[1], hsl[2]);

  return bestColor;
}

//用来展现评分主题的方块组件喵
class RatingThemeBlock extends StatefulWidget {

  //根据dataId来获取子数据喵
  final DataIndex dataIndex;

  final Color color;

  RatingThemeBlock({required this.dataIndex, required this.color});

  @override
  _RatingThemeBlockState createState() => _RatingThemeBlockState();
}

class _RatingThemeBlockState extends State<RatingThemeBlock> {

  late Timer changingDataTimer;
  ValueNotifier<bool> UI = ValueNotifier(false);

  //首先是评分主题的标题喵
  String themeName = "加载中";
  //然后是三个最热门的评分对象的标题喵
  List<String> hotObjectNameL = ["虚位以待", "虚位以待", "虚位以待"];
  //然后是三个最热门的评分对象的图片喵
  List<String> hotObjectImageL = [" ", " ", " "];
  //然后是三个最热门的评分对象的评分喵
  List<double> hotObjectRatingL = [4.0, 4.0, 4.0];
  //然后是三个最热门的评分对象的评分数量喵
  List<int> hotObjectCommentCountL = [0, 0, 0];
  //创建时间
  String createAt = "2024-3-13 zhk";

  @override
  void initState(){
    UI.addListener(() { setState(() {});});
    super.initState();
  }

  @override
  void dispose() {
    changingDataTimer.cancel();
    super.dispose();
  }

  loadUI() async {
    if(context
        .read<RatingPageData>()
        .getDataIndexLeaf(widget.dataIndex).isSucceed("get")){
      themeName= context
          .read<RatingPageData>()
          .getDataIndexLeaf(widget.dataIndex).dataM["get"]!["themeName"];
      try{
        createAt=
        context
            .read<RatingPageData>()
            .getDataIndexLeaf(widget.dataIndex)
            .dataM["get"]!["createdAt"];
      }
      catch(e){
      }
      for(var i=0;i<3;++i){
        if(context
            .read<RatingPageData>()
            .getDataIndexLeaf(widget.dataIndex).dataM["get"]!.containsKey("object$i")
        ){
          hotObjectNameL[i]=
          context
              .read<RatingPageData>()
              .getDataIndexLeaf(widget.dataIndex)
              .dataM["get"]!["object$i"]["objectName"];
          hotObjectImageL[i]=
          context
              .read<RatingPageData>()
              .getDataIndexLeaf(widget.dataIndex)
              .dataM["get"]!["object$i"]["objectImage"];
          hotObjectRatingL[i]=
          context
              .read<RatingPageData>()
              .getDataIndexLeaf(widget.dataIndex)
              .dataM["get"]!["object$i"]["objectRating"];
          hotObjectCommentCountL[i]=
          context
              .read<RatingPageData>()
              .getDataIndexLeaf(widget.dataIndex)
              .dataM["get"]!["object$i"]["commentCount"];
        }
        else{
          hotObjectNameL[i]="虚位以待~";
          hotObjectImageL[i]=" ";
          hotObjectRatingL[i]=4.0;
          hotObjectCommentCountL[i]=0;
        }
      }
      UI.value = !UI.value;
    }
    else{
      //400毫秒后再执行
      //UI.value = !UI.value;
      changingDataTimer = Timer(Duration(milliseconds: 400), () {
        loadUI();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    loadUI();
    double screenWidth = MediaQuery.of(context).size.width;
    double mm = screenWidth * 0.9 / 60; //获取现实中1毫米的像素长度

    var radius = BorderRadius.circular(4);

    /***************************************************************
        背景
        宽度:60mm
        高度:50mm
        颜色:白
     ***************************************************************/
    double width1 = 60 * mm; // 宽度为屏幕宽度
    double height1 = 54.5 * mm; // 高度为屏幕宽度
    Color color1 = widget.color.withOpacity(0.10);

    Widget widget1 = Container(
      width: width1,
      height: height1,
      color: color1,
    );

    widget1 = ClipRRect(
      borderRadius: radius,
      child: widget1,
    );

    /***************************************************************
        第一层颜色块
        宽度:60mm
        高度:20mm
        颜色:蓝色
     ***************************************************************/
    double width2 = 60 * mm;
    double height2 = 20 * mm;
    Color color2 = widget.color.withOpacity(0.8);

    Widget widget2 = Container(
      width: width2,
      height: height2,
      color: color2,
    );

    widget2 = ClipRRect(
      borderRadius: radius,
      child: widget2,
    );

    widget2 = Positioned(top: 0 * mm, left: 0 * mm, child: widget2);

    /***************************************************************
        第二层颜色块
        宽度:60mm
        高度:20mm
        颜色:渐变透明白色
        坐标:左0,上14mm
     ***************************************************************/
    double width3 = 60 * mm;
    double height3 = 6 * mm;

    Widget widget3 = Container(
      width: width3,
      height: height3,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.1), Colors.white], // 渐变透明白色
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );

    widget3 = Positioned(
      top: 14 * mm,
      left: 0 * mm,
      child: widget3,
    );

    /***************************************************************
        第三层颜色块
        宽度:60mm
        高度:20mm
        颜色:主题
        坐标:左0,上14mm
     ***************************************************************/
    double width4 = 60 * mm;
    double height4 = 1 * mm;
    Color color4 = widget.color.withOpacity(0.1);

    Widget widget4 = Container(
      width: width4,
      height: height4,
      color: color4,
    );

    widget4 = ClipRRect(
      borderRadius: radius,
      child: widget4,
    );

    widget4 = Positioned(bottom: 1 * mm, left: 0 * mm, child: widget4);

    /***************************************************************
        第四层颜色块
        宽度:60mm
        高度:20mm
        颜色:主题
        坐标:左0,上14mm
     ***************************************************************/
    double width5 = 60 * mm;
    double height5 = 0 * mm;
    Color color5 = Colors.black.withOpacity(0.5);

    Widget widget5 = Container(
      width: width5,
      height: height5,
      color: color5,
    );

    widget5 = ClipRRect(
      borderRadius: radius,
      child: widget5,
    );

    widget5 = Positioned(top: 0 * mm, left: 0 * mm, child: widget5);

    /***************************************************************
        标题文字区域
        宽度:未知
        高度:5mm
        颜色:白色
        主题:粗体
        坐标:左4mm,上3mm
     ***************************************************************/
    double topicWidth = 40 * mm;
    double topicHeight = 7 * mm;

    Widget topicWidget = Text(
      themeName + " >",
      style: TextStyle(
        fontFamily: "NotoSansHans",
        fontWeight: FontWeight.bold, // 设置字体为粗体
        fontSize: 4 * mm, // 设置字体尽可能大
        color: Colors.black,
      ),
    );

    topicWidget = Container(
      width: topicWidth,
      height: topicHeight,
      child: topicWidget,
    );

    topicWidget = Positioned(
      top: 3 * mm,
      left: 2 * mm,
      child: topicWidget,
    );

    /***************************************************************
        装饰图标
     ***************************************************************/
    Widget iconWidget = Row(
      children: [
        Icon(
          Icons.keyboard_double_arrow_right_rounded,
          color: widget.color.withOpacity(0.4),
          size: 6 * mm,
        ),
        Icon(
          Icons.keyboard_double_arrow_right_rounded,
          color: widget.color.withOpacity(0.4),
          size: 6 * mm,
        ),
      ],
    );

    iconWidget = Positioned(
      top: 5 * mm,
      right: 3 * mm,
      child: iconWidget,
    );

    /***************************************************************
        装饰条纹
        宽度:10mm
        高度:3mm
        颜色:半透明白色
        字体:粗体
        坐标:左4mm,上9.5mm
     ***************************************************************/
    double ratingCountWidth = 30 * mm;
    double ratingCountHeight = 3.5 * mm;

    Widget ratingCountWidget;

    ratingCountWidget = Container(
      color: Colors.white.withOpacity(0.8),
      child: Text(
        " "+createAt+" ",
        style: TextStyle(
          fontFamily: "NotoSansHans",
          fontWeight: FontWeight.bold,
          fontSize: 2.7 * mm, // 设置字体
          color: Colors.black.withOpacity(0.8),
        ),
      ),
    );
    
    //圆角
    ratingCountWidget = ClipRRect(
      borderRadius: radius,
      child: ratingCountWidget,
    );

    ratingCountWidget = Positioned(
      top: 9.4 * mm,
      left: 2 * mm,
      child: ratingCountWidget,
    );

    /***************************************************************
        进入按钮
        宽度:10mm
        高度:6mm
        颜色:半透明白色
        字体:粗体
        坐标:左4mm,上9mm
     ***************************************************************/

    Widget nextPageButton;

    nextPageButton = ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withOpacity(0.6),
            Colors.white.withOpacity(0.6)
          ],
        ).createShader(bounds);
      },
      child: Text(
        '',
        style: TextStyle(
          fontFamily: "NotoSansHans",
          fontSize: 4*mm, // 设置字体大小
          fontWeight: FontWeight.bold, // 设置字体为粗体
          color: Colors.white,
        ),
      ),
    );

    nextPageButton = Positioned(
      top: 5 * mm,
      right: 4 * mm,
      child: nextPageButton,
    );

    /***************************************************************
        预览窗口
        宽度:56mm
        高度:10mm
        颜色:白色
        字体:粗体
        坐标:左2mm,上15mm
     ***************************************************************/

    Widget someOfObject(int index) {
      /***************************************************************
          背景
       ***************************************************************/

      ///背景
      Widget background = Container(
        width: 56 * mm,
        height: 11.5 * mm,
        color: Colors.white,
      );

      //裁剪
      background = ClipRRect(
        borderRadius: radius,
        child: background,
      );

      /***************************************************************
          评分对象图片
       ***************************************************************/

      ///图片组件
      Widget base64Image = Base64Image(
        base64String: hotObjectImageL[index],
        width: 9 * mm,
        height: 9 * mm,
      );

      ///裁剪图片
      base64Image = ClipRRect(
        borderRadius: radius,
        child: base64Image,
      );

      base64Image = Positioned(
        top: 1.25 * mm,
        left: 1.25 * mm,
        child: base64Image,
      );

      /***************************************************************
          评分对象标题
       ***************************************************************/

      ///标题组件
      Widget title = Text(
        hotObjectNameL[index],
        style: TextStyle(
          fontFamily: "NotoSansHans",
          fontWeight: FontWeight.bold, // 设置字体为粗体
          fontSize: 3.5*mm,
          color: Colors.black,
        ),
      );

      title = Positioned(
        top: 2 * mm,
        left: 11.5 * mm,
        child: title,
      );

      /***************************************************************
          热评(被取缔)
       ***************************************************************/

      double hotCommentWidth = 30 * mm;
      double hotCommentHeight = 2 * mm;

      Widget hotComment;

      hotComment = Container(
        width: hotCommentWidth,
        height: hotCommentHeight,
        color: widget.color.withOpacity(0.1),
      );

      hotComment = Positioned(
        bottom: 1.25 * mm,
        left: 11.5 * mm,
        child: hotComment,
      );

      /***************************************************************
          评分对象评分
       ***************************************************************/

      ///评分组件
      Widget rating = Text(
        //保留一位小数
        (hotObjectCommentCountL[index] >= 2)?
        hotObjectRatingL[index].toStringAsFixed(1):
        "--",
        style: TextStyle(
          fontFamily: "NotoSansHans",
          fontWeight: FontWeight.bold, // 设置字体为粗体
          fontSize: 5*mm, // 设置字体
          color: getInverseColor(widget.color).withOpacity(0.6),
        ),
      );

      rating = Positioned(
        top: 0.7 * mm,
        right: 2 * mm,
        child: rating,
      );

      /***************************************************************
          评分数量
       ***************************************************************/

      ///评分数量组件
      Widget commentCount = Text(
          (hotObjectCommentCountL[index] >= 2)?
          hotObjectCommentCountL[index].toString() + "评分" :
          "评分收集中",
        style: TextStyle(
          fontFamily: "NotoSansHans",
          fontWeight: FontWeight.bold, // 设置字体为粗体
          fontSize: 2*mm, // 设置字体
          color: Colors.grey,
        ),
      );

      commentCount = Positioned(
        bottom: 1 * mm,
        right: 1.5 * mm,
        child: commentCount,
      );

      /***************************************************************
          整合
       ***************************************************************/

      Widget allInOne = Stack(
        children: [
          background,
          base64Image,
          title,
          hotComment,
          rating,
          commentCount
        ],
      );

      allInOne = Positioned(
        top: 15 * mm + (index) * 12.5 * mm + ((index>0)?0.5*mm*(index):0),
        left: 2 * mm,
        child: allInOne,
      );

      return allInOne;
    }

    /***************************************************************
        最后一步,拼接并裁剪所有组件
     ***************************************************************/

    Widget allInOne = Container(
      width: 60 * mm,
      height: 55.8 * mm,
      child: Stack(
        children: [
          widget1,
          //widget2,
          //widget3,
          //widget4,
          //widget5,
          topicWidget,
          iconWidget,
          ratingCountWidget,
          nextPageButton,
          someOfObject(0),
          someOfObject(1),
          someOfObject(2),

          (!context.read<RatingPageData>().getDataIndexLeaf(widget.dataIndex).isSucceed("get"))?
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0,sigmaY: 2.0),///整体模糊度
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 0),///背景透明
                  borderRadius: BorderRadius.all(Radius.circular(1.2))///圆角
              ),
              child: IndexLeafLoadingDots(
                  context.read<RatingPageData>().getDataIndexLeaf(widget.dataIndex)
              ),
            ),
          ):
          Container(),
        ],
      ),
    );

    /***************************************************************
        填满页面宽度使得组件居中,并设置间隔
     ***************************************************************/

    allInOne = Container(
      width: screenWidth,
      height: 55.8 * mm,
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
                builder: (context) => ThemePage(dataIndex: widget.dataIndex,color: widget.color,),
              ));
        },
        child: allInOne
    );

    /***************************************************************
        完成!
     ***************************************************************/

    return allInOne;
  }
}

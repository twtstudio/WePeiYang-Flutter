import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/rating_page_data.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/user_data.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/base64_image_ui.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/rating_theme_block_ui.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/rating_object_block_ui.dart';

import '../../../../commons/widgets/loading.dart';
import '../../../view/lake_home_page/normal_sub_page.dart';
import '../../ui/loading_dot.dart';

class ThemePage extends StatefulWidget {
  DataIndex dataIndex;
  Color color;

  ThemePage({required this.dataIndex, required this.color});

  @override
  _ThemePageState createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  /***************************************************************
      数据
   ***************************************************************/

  //排序方式
  late String sortType;

  //大更新魔法
  ValueNotifier<bool> UI = ValueNotifier(false);

  //大状态魔法
  bool loadState = false;

  String themeName = "名称加载中";
  String themeDescribe = "简介加载中";
  String themeCreator = "55442";
  String createdAt = "2024-2-29";
  String updatedAt = "2024-2-29";

  //创作者的图片与名称
  String creatorImg = " ";
  String creatorName = "不知道";

  //当然还有数量
  int objectCount = 1;
  List<DataIndex> objectIndexL = [NullDataIndex];

  //当数量为0时候,不能通过余除获得索引,此时应该返回

  /***************************************************************
      变量与函数
   ***************************************************************/
  RefreshController refreshController = RefreshController();
  ScrollController _scrollController = ScrollController();

  late Timer changingDataTimer;

  Future<void> _fakeLoadData() async {
    await Future.delayed(Duration(microseconds: 2000), () {
      refreshController.refreshCompleted();
    });
    context.read<RatingPageData>().nowSortType.value =
        (context.read<RatingPageData>().nowSortType.value == "热度")
            ? "时间"
            : "热度";
    setState(() {});
  }

  //144循环列表
  int getIndex(int i) {
    if (i == 0) return -1;
    return 144 % i;
  }

  bool lockLoad = false;

  loadUI() {
    bool stopFlag = true;
    try {
      if (context
          .read<RatingPageData>()
          .getDataIndexLeaf(widget.dataIndex)
          .isSucceed("get")) {
        //判断值有没有变化

        themeName = context
            .read<RatingPageData>()
            .getDataIndexLeaf(widget.dataIndex)
            .dataM["get"]!["themeName"];
        themeDescribe = context
            .read<RatingPageData>()
            .getDataIndexLeaf(widget.dataIndex)
            .dataM["get"]!["themeDescribe"];
        themeCreator = context
            .read<RatingPageData>()
            .getDataIndexLeaf(widget.dataIndex)
            .dataM["get"]!["themeCreator"];
        createdAt = context
            .read<RatingPageData>()
            .getDataIndexLeaf(widget.dataIndex)
            .dataM["get"]!["createdAt"];
        updatedAt = context
            .read<RatingPageData>()
            .getDataIndexLeaf(widget.dataIndex)
            .dataM["get"]!["updatedAt"];

        UI.value = !UI.value;

        if (context
            .read<RatingUserData>()
            .getUser(themeCreator)
            .isSucceed("get")) {
          creatorImg = context
              .read<RatingUserData>()
              .getUser(themeCreator)
              .dataM["get"]!["userImg"];
          creatorName = context
              .read<RatingUserData>()
              .getUser(themeCreator)
              .dataM["get"]!["userName"];

          UI.value = !UI.value;
        } else {
          stopFlag = false;
        }
      } else {
        stopFlag = false;
      }

      if (context
          .read<RatingPageData>()
          .getDataIndexTree(widget.dataIndex)
          .isFinish()) {
        objectCount = context
            .read<RatingPageData>()
            .getDataIndexTree(widget.dataIndex)
            .children
            .length;
        objectIndexL = context
            .read<RatingPageData>()
            .getDataIndexTree(widget.dataIndex)
            .children[sortType]!;

        loadState = true;
        UI.value = !UI.value;
      } else {
        stopFlag = false;
      }
    } catch (e) {
      stopFlag = true;
    }

    if (!stopFlag) {
      changingDataTimer = Timer(Duration(milliseconds: 400), () {
        loadUI();
      });
    } else {
      lockLoad = true;
    }
  }

  /***************************************************************
      生命周期
   ***************************************************************/
  @override
  void initState() {
    loadUI();
    sortType = context.read<RatingPageData>().nowSortType.value;
    UI.addListener(() {
      setState(() {});
    });

    //排序方式变化时,也更新数据
    context.read<RatingPageData>().nowSortType.addListener(() {
      setState(() {
        sortType = context.read<RatingPageData>().nowSortType.value;
      });
    });
    super.initState();
  }

  /***************************************************************
      构建
   ***************************************************************/
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double mm = screenWidth * 0.9 / 60; //获取现实中1毫米的像素长度

    context.read<RatingPageData>().refreshController = refreshController;
    //powerDebug(context);

    double getProgress() {
      try {
        return _scrollController.offset /
            (_scrollController.position.maxScrollExtent + 0.01);
      } catch (e) {
        return 0.0;
      }
    }

    /***************************************************************
        顶部的颜色块
     ***************************************************************/

    Widget topBlueBlock = Container(
      width: screenWidth,
      height: 40 * mm,
      //渐变蓝色,自上而下,由蓝到白
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.color.withOpacity(0.8),
            widget.color.withOpacity(0.4),
          ],
        ),
      ),
    );
    topBlueBlock = Positioned(
      top: 0,
      left: 0,
      child: topBlueBlock,
    );

    /***************************************************************
        顶部的颜色块
     ***************************************************************/

    Widget topWhiteBlock = Container(
      width: screenWidth,
      height: 3 * mm,
      color: Colors.white,
    );

    topWhiteBlock = Positioned(
      top: 0,
      left: 0,
      child: topWhiteBlock,
    );

    /***************************************************************
        返回按钮,用于返回到上一页面
     ***************************************************************/

    Widget backButton = Container(
      width: 4 * mm,
      height: 4 * mm,
      child: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );

    backButton = Positioned(
      top: 8 * mm,
      left: 4 * mm,
      child: backButton,
    );

    /***************************************************************
        标题,粗体黑色文本
     ***************************************************************/

    Widget title = Container(
      width: screenWidth,
      height: 5 * mm,
      child: Center(
        child: Text(
          "主题",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold, // 设置字体为粗体
            fontSize: 22,
          ),
        ),
      ),
    );

    title = Positioned(
      top: 8 * mm,
      left: 0,
      child: title,
    );

    /***************************************************************
        评分主题名称
     ***************************************************************/

    Widget themeNameWidget = Container(
      width: 40 * mm,
      height: 6 * mm,
      child: Text(
        themeName,
        style: TextStyle(
          color: Colors.white, // 设置文本颜色为黑色
          fontWeight: FontWeight.bold, // 设置文本粗体
          fontSize: 26.0, // 设置文本字体大小
        ),
      ),
    );

    themeNameWidget = Positioned(
      top: 16 * mm,
      left: 4 * mm,
      child: themeNameWidget,
    );

    /***************************************************************
        评分主题简介
     ***************************************************************/

    Widget themeIntroduction = Container(
      width: 50 * mm,
      height: 7 * mm,
      child: Text(
        themeDescribe,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.0, // 设置文本字体大小
        ),
      ),
    );

    themeIntroduction = Positioned(
      top: 23 * mm,
      left: 4 * mm,
      child: themeIntroduction,
    );

    /***************************************************************
        创建者信息,包含圆形图片,创建者名称,创建时间
     ***************************************************************/

    Widget creatorInfo = Container(
      height: 5 * mm,
      child: Row(
        children: [
          Container(
              width: 5 * mm,
              height: 5 * mm,
              child: ClipOval(
                  child: Base64Image(
                      base64String: creatorImg,
                      width: 5 * mm,
                      height: 5 * mm)
              )
          ),
          Row(
            children: [
              Container(
                width: 1.5 * mm,
              ),
              Text(
                creatorName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0, // 设置文本字体大小
                ),
              ),
              Container(
                width: 1 * mm,
              ),
              Text(
                createdAt,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0, // 设置文本字体大小
                ),
              ),
            ],
          ),
        ],
      ),
    );

    creatorInfo = Positioned(
      top: 32 * mm,
      left: 4 * mm,
      child: creatorInfo,
    );

    /***************************************************************
        顶部组件合并
     ***************************************************************/

    Widget topPart = Stack(
      children: [
        topBlueBlock,
        //topWhiteBlock,
        backButton,
        title,
        themeNameWidget,
        themeIntroduction,
        creatorInfo,
      ],
    );

    topPart = Container(
      width: screenWidth,
      height: 40 * mm,
      child: topPart,
    );

    /***************************************************************
        主页面
     ***************************************************************/

    Widget mainPage = Container(
      child: SmartRefresher(
        physics: BouncingScrollPhysics(),
        controller: refreshController,
        header: ClassicHeader(
          height: 5.h,
          completeDuration: Duration(milliseconds: 300),
          idleText: '下拉以刷新推送方式',
          releaseText: '下拉以刷新推送方式',
          refreshingText: "刷新中",
          completeText: '刷新完成 (ﾉ*･ω･)ﾉ',
          failedText: '刷新失败（；´д｀）ゞ',
        ),
        cacheExtent: 11,
        enablePullDown: true,
        onRefresh: _fakeLoadData,
        footer: ClassicFooter(
          idleText: '下拉以刷新',
          noDataText: '无数据',
          loadingText: '终于写完了',
          failedText: '加载失败（；´д｀）ゞ',
        ),
        enablePullUp: true,
        onLoading: _fakeLoadData,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: 144,
          itemBuilder: (BuildContext context, int index) {
            /***************************************************************
                顶部组件
             ***************************************************************/
            if (index == 0) {
              index -= 1;
              return Column(
                children: [
                  topPart,
                  Container(
                    height: 1.5 * mm,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 20,
                      ),
                      Text(
                        "热度 ",
                        style: TextStyle(
                          color: context
                                      .read<RatingPageData>()
                                      .nowSortType
                                      .value ==
                                  "热度"
                              ? Colors.blue
                              : Colors.grey,
                          fontWeight: FontWeight.bold, // 设置字体为粗体
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        "时间 ",
                        style: TextStyle(
                          color: context
                                      .read<RatingPageData>()
                                      .nowSortType
                                      .value ==
                                  "时间"
                              ? Colors.blue
                              : Colors.grey,
                          fontWeight: FontWeight.bold, // 设置字体为粗体
                          fontSize: 20,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            "    (下拉以切换)",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold, // 设置字体为粗体
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(),
                ],
              );
            }

            /***************************************************************
                列表内组件
             ***************************************************************/

            return Center(
                child: ListTile(
              title: RatingObjectBlock(
                dataIndex: (objectCount == 0)
                    ? NullDataIndex
                    : objectIndexL[getIndex(objectIndexL.length)],
              ),
              // 添加其他列表项的内容和样式
            ));
          },
        ),
      ),
      color: Colors.white,
    );

    Widget allInOne = Stack(
      children: [
        mainPage,
        (context
                .read<RatingPageData>()
                .getDataIndexTree(widget.dataIndex)
                .isFinish())
            ? Container()
            : BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),

                ///整体模糊度
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 255, 255, 0),

                      ///背景透明
                      borderRadius: BorderRadius.all(Radius.circular(1.2))

                      ///圆角
                      ),
                  child: IndexTreeLoadingDots(context
                      .read<RatingPageData>()
                      .getDataIndexTree(widget.dataIndex)),
                ),
              ),
      ],
    );

    return allInOne;
  }
}

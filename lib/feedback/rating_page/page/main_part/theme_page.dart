import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/rating_page_data.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/rating_theme_block_ui.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/rating_object_block_ui.dart';

import '../../../../commons/widgets/loading.dart';
import '../../../view/lake_home_page/normal_sub_page.dart';

class ThemePage extends StatefulWidget {
  DataIndex dataIndex;
  Color color;

  ThemePage({required this.dataIndex,required this.color});
  @override
  _ThemePageState createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {

  /***************************************************************
      数据
   ***************************************************************/

  //索引
  late DataIndexTree dataIndexTree;
  //数据
  late DataIndexLeaf dataIndexLeaf;
  //排序方式
  late String sortType;

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
    context.read<RatingPageData>().nowSortType.value == "热度" ? "时间" : "热度";
    setState(() {});
  }

  /***************************************************************
      生命周期
   ***************************************************************/
  @override
  void initState() {
    //初始化
    context.read<RatingPageData>().buildDataIndex(widget.dataIndex);

    sortType = context.read<RatingPageData>().nowSortType.value;
    dataIndexTree = context.read<RatingPageData>().getDataIndexTree(widget.dataIndex);
    dataIndexLeaf = context.read<RatingPageData>().getDataIndexLeaf(widget.dataIndex);

    //当loadingState发生变化时刻,更新页面数据
    dataIndexTree.loadingState[transSortType[sortType]]!.addListener(() {
      setState(() {
        dataIndexTree = context.read<RatingPageData>().getDataIndexTree(widget.dataIndex);
      });
    });

    //页面数据变化时,也更新数据
    dataIndexLeaf.loadingState.addListener(() {
      setState(() {
        dataIndexLeaf = context.read<RatingPageData>().getDataIndexLeaf(widget.dataIndex);
      });
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
      width: 4*mm,
      height: 4*mm,
      child: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );

    backButton = Positioned(
      top:8*mm,
      left:4*mm,
      child: backButton,
    );

    /***************************************************************
        标题,粗体黑色文本
     ***************************************************************/

    Widget title = Container(
      width: screenWidth,
      height: 5*mm,
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
      top: 8*mm,
      left: 0,
      child: title,
    );

    /***************************************************************
        评分主题名称
     ***************************************************************/

    Widget themeName = Container(
      width: 40*mm,
      height: 6*mm,
      child: Text(
        "评分主题名称",
        style: TextStyle(
          color: Colors.white, // 设置文本颜色为黑色
          fontWeight: FontWeight.bold, // 设置文本粗体
          fontSize: 26.0, // 设置文本字体大小
        ),
      ),
    );

    themeName = Positioned(
      top: 16*mm,
      left: 4*mm,
      child: themeName,
    );

    /***************************************************************
        评分主题简介
     ***************************************************************/

    Widget themeIntroduction = Container(
      width: 50*mm,
      height: 7*mm,
      child: Text(
        "评分主题简介...",
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.0, // 设置文本字体大小
        ),
      ),
    );

    themeIntroduction = Positioned(
      top: 23*mm,
      left: 4*mm,
      child: themeIntroduction,
    );

    /***************************************************************
        创建者信息,包含圆形图片,创建者名称,创建时间
     ***************************************************************/

    Widget creatorInfo = Container(
      width: 50*mm,
      height: 5*mm,
      child: Row(
        children: [
          Container(
            width: 5*mm,
            height: 5*mm,
            child: CircleAvatar(
              backgroundImage: AssetImage("assets/images/feedback/rating_page/creator.jpg"),
            ),
          ),
          Row(
            children: [
              Container(
                width: 1*mm,
              ),
              Text(
                "创建者名称",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0, // 设置文本字体大小
                ),
              ),
              Container(
                width: 1*mm,
              ),
              Text(
                "创建时间",
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
      top: 32*mm,
      left: 4*mm,
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
        themeName,
        themeIntroduction,
        creatorInfo,
      ],
    );

    topPart = Container(
      width: screenWidth,
      height: 40*mm,
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
          itemCount:
          dataIndexTree.children[sortType]!.length + 100,
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
                    height: 1.5*mm,
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
                  title: RatingObjectBlock(dataIndex: dataIndexTree.children[sortType]![index],),
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
      ],
    );

    return allInOne;
  }
}

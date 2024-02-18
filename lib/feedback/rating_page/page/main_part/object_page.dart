import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/rating_page_data.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/rating_comment_block_ui.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/rating_theme_block_ui.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/rating_object_block_ui.dart';

import '../../../../commons/widgets/loading.dart';
import '../../../view/lake_home_page/normal_sub_page.dart';

class ObjectPage extends StatefulWidget {

  DataIndex dataIndex;
  Widget objectBlock;

  ObjectPage({required this.dataIndex,required this.objectBlock});
  @override
  _ObjectPageState createState() => _ObjectPageState();
}

class _ObjectPageState extends State<ObjectPage> {

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
    dataIndexTree.loadingState[sortType]!.addListener(() {
      setState(() {

      });
    });

    context.read<RatingPageData>().getDataIndexLeaf(widget.dataIndex).loadingState.addListener(() {
      setState(() {

      });
    });

    context.read<RatingPageData>().nowSortType.addListener(() {
      setState(() {

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
        顶部的白色颜色块
     ***************************************************************/

    Widget topBlock = Container(
      width: screenWidth,
      height: 25 * mm,
      color: Colors.white,
    );
    topBlock = Positioned(
      top: 0,
      left: 0,
      child: topBlock,
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
          "评分",
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
        创建者信息,包含圆形图片,创建者名称,创建时间
     ***************************************************************/

    Widget creatorInfo = Container(
      child: Row(
        children: [
          Container(
            width: 8*mm,
            height: 8*mm,
            child: CircleAvatar(
              backgroundImage: AssetImage("assets/images/feedback/rating_page/creator.jpg"),
            ),
          ),
          Container(width: 2*mm,),
          Column(
            //靠左对齐
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "创建者名称",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 3*mm, // 设置文本字体大小
                ),
              ),
              Text(
                "创建时间",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 2.5*mm, // 设置文本字体大小
                ),
              ),
            ],
          ),
        ],
      ),
    );

    creatorInfo = Positioned(
      top: 16*mm,
      left: 4*mm,
      child: creatorInfo,
    );

    /***************************************************************
        关于评分对象
     ***************************************************************/

    Widget objectBlock = widget.objectBlock;
    objectBlock = Positioned(
      top: 22*mm,
      left: 0*mm,
      child: objectBlock,
    );

    /***************************************************************
        顶部组件合并
     ***************************************************************/

    Widget topPart = Stack(
      children: [
        topBlock,
        //topWhiteBlock,
        backButton,
        title,
        creatorInfo,
        objectBlock,
      ],
    );

    topPart = Container(
      width: screenWidth,
      height: 50*mm,
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
          dataIndexTree.children[
            context.read<RatingPageData>().nowSortType
          ]!.length + 100,
          itemBuilder: (BuildContext context, int index) {

            /***************************************************************
                顶部组件
             ***************************************************************/
            if (index == 0) {
              index -= 1;
              return Column(
                children: [
                  topPart,
                  //分割线
                  Divider(),
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
                  //黑色粗体文本,全部评论

                ],
              );
            }

            /***************************************************************
                列表内组件
             ***************************************************************/
            return Center(
                child: ListTile(
                  title: RatingCommentBlock(index: index,),
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

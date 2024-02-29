import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/create/create_theme.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/rating_page_data.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/user_data.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/create_button.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/loading_dot.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/rating_theme_block_ui.dart';

import '../../../../commons/widgets/loading.dart';
import '../../../view/lake_home_page/normal_sub_page.dart';
import '../../ui/tag_ui.dart';

class RatingPageMainPart extends StatefulWidget {

  DataIndex dataIndex;
  RatingPageMainPart({required this.dataIndex});

  @override
  _RatingPageMainPartState createState() => _RatingPageMainPartState();
}

class _RatingPageMainPartState extends State<RatingPageMainPart> {

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
    dataIndexTree.reset();

    void _writeToClipboard(String text) {
      Clipboard.setData(ClipboardData(text: text))
          .then((value) => print('Text copied to clipboard: $text'));
    }

    setState(() async {
      //监听变量组件
      //debugOutput(context, context.read<RatingUserData>().myUser.dataM.toString());
      //_writeToClipboard(context.read<RatingUserData>().userMap[].dataM.toString());
    });
  }

  Color? getGradientColor(double value) {
    // 定义起始颜色和结束颜色
    Color startColor = Colors.blue;
    Color endColor = Colors.red;

    // 使用Color.lerp进行线性插值
    return Color.lerp(startColor, endColor, value);
  }

  /***************************************************************
      初始化

      在加载一个页面之前,需要先获取当前页面当前分支下的数据索引
   ***************************************************************/
  @override
  void initState() {
    //初始化
    context.read<RatingPageData>().buildDataIndex(widget.dataIndex);

    sortType = context.read<RatingPageData>().nowSortType.value;
    dataIndexTree = context.read<RatingPageData>().getDataIndexTree(widget.dataIndex);
    dataIndexLeaf = context.read<RatingPageData>().getDataIndexLeaf(widget.dataIndex);

    //debugOutput(context, dataIndexTree.loadingState.toString());

    //当loadingState发生变化时刻,更新页面数据
    dataIndexTree.UI.addListener(() {
      setState(() {
        //debugOutput(context, "数据更新");
      });
    });

    context.read<RatingPageData>().nowSortType.addListener(() {
      setState(() {
        sortType = context.read<RatingPageData>().nowSortType.value;
        context.read<RatingPageData>().getDataIndexTree(widget.dataIndex);
        //debugOutput(context, dataIndexTree.loadingState.toString()+dataIndexTree.children.toString());
      });
    });


    super.initState();
  }

  /***************************************************************
      构建
   ***************************************************************/
  @override
  Widget build(BuildContext context) {

    //debugOutput(context, context.read<RatingUserData>().myUserImg.toString());

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
        函数
     ***************************************************************/

    Color? getProgressColor(double value) {
      // 定义光谱的颜色列表
      List<Color> spectrumColors = [
        Colors.blue,
        Colors.green,
        Colors.purple,
        Colors.orange,
        Colors.red,
      ];

      // 计算在光谱颜色列表中的索引
      int index = (value * (spectrumColors.length - 1)).toInt();
      if (index < 0) {
        index = 0;
      } else if (index >= spectrumColors.length - 1) {
        index = spectrumColors.length - 2;
      }

      // 计算线性插值值
      double fraction =
          (value * (spectrumColors.length - 1)) - index.toDouble();

      // 根据索引和插值值获取光谱颜色
      Color? color = Color.lerp(
          spectrumColors[index], spectrumColors[index + 1], fraction);

      return color;
    }

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

        //列表视图
        child: ListView.builder(

          controller: _scrollController,
          itemCount:
              145,
          itemBuilder: (BuildContext context, int index) {

            /***************************************************************
                顶部组件
             ***************************************************************/
            if (index == 0) {
              index -= 1;
              Widget top = Column(
                children: [
                  AnnouncementBannerWidget(),

                  Container(
                    height: 10,
                  ),

                  AdCardWidget(),

                  Container(
                    height: 10,
                  ),

                  //分割线
                  Divider(),

                  TagUI(dataIndexTree: dataIndexTree),

                  Divider(),

                ],
              );

              return top;
            }
            index-=1;

            /***************************************************************
                列表内组件
             ***************************************************************/
            return Center(
                child: ListTile(
                  title: RatingThemeBlock(
                      dataIndex:
                      (dataIndexTree.children[transSortType[sortType]]!.length!=0)?
                        dataIndexTree.children[transSortType[sortType]]![index % dataIndexTree.children[transSortType[sortType]]!.length]
                          : NullDataIndex,
                      color: getProgressColor(getProgress())!,
                  ),
                  // 添加其他列表项的内容和样式
                )
            );

          },
        ),
      ),
      color: Colors.white,
    );

    Widget allInOne = Stack(
      children: [

        mainPage,
        CreateButton(onPressed: ()
        {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateTheme()),
          );
        }),

        (!dataIndexTree.isFinish())?
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0,sigmaY: 2.0),///整体模糊度
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0),///背景透明
                borderRadius: BorderRadius.all(Radius.circular(1.2))///圆角
            ),
            child: IndexTreeLoadingDots(dataIndexTree),
          ),
        ):
        Container(),
      ],
    );

    return allInOne;

  }
}

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/rating_page_data.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/rating_theme_block_ui.dart';

import '../../../commons/widgets/loading.dart';
import '../../view/lake_home_page/normal_sub_page.dart';

class RatingPageMainPart extends StatefulWidget {
  @override
  _RatingPageMainPartState createState() => _RatingPageMainPartState();
}

class _RatingPageMainPartState extends State<RatingPageMainPart> {
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

  @override
  void initState() {
    context.read<RatingPageData>().nowSortType.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  Color? getGradientColor(double value) {
    // 定义起始颜色和结束颜色
    Color startColor = Colors.blue;
    Color endColor = Colors.red;

    // 使用Color.lerp进行线性插值
    return Color.lerp(startColor, endColor, value);
  }

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
          loadingText: '',
          failedText: '加载失败（；´д｀）ゞ',
        ),
        enablePullUp: true,
        onLoading: _fakeLoadData,
        child: ListView.builder(
          controller: _scrollController,
          itemCount:
              context.read<RatingPageData>().dataLinkMap.value.length + 100,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              index -= 1;
              return Column(
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
                  Container(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 20,
                      ),
                      Text(
                        '今日推送:',
                        style: TextStyle(
                          color: Colors.blue, // 设置文本颜色为黑色
                          fontWeight: FontWeight.bold, // 设置文本粗体
                          fontSize: 24.0, // 设置文本字体大小
                        ),
                      ),
                    ],
                  ),

                  Container(
                    height: 4,
                  ),
                ],
              );
            }

            return Center(
                child: ListTile(
              title: RatingThemeBlock(
                  index: index, color: getProgressColor(getProgress())!),
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

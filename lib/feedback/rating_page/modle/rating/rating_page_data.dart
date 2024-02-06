//管理评分页面的数据

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/page/rating_page_main_part.dart';

///2024.2.1

//数据链接
class DataLink {
  String dataType;
  String dataId;

  DataLink({required this.dataType, required this.dataId});
}

class DataJson {
  String jsonString;

  DataJson({required this.jsonString});

  Map<String, dynamic> getMap() {
    return json.decode(jsonString);
  }
}

class DataEyes {
  int nowIndex;
  DataPart dataPart;

  DataEyes({required this.nowIndex, required this.dataPart});
}

//数据部分
mixin DataPart {
  /***************************************************************
      数据存储相关参数

      dataLinkMap["rating_page"]["0"]["time"]
      //第一键值表示类型,第二键值表示id,第三键值表示排序方式
      //表示主页面下评分主题按时间排序的索引(最多200条)
      //返回值为List<dataLink>,可根据dataLink以及类型来获取数据

      dataLinkMap["rating_theme"]["12312"]["hot"]
      //表示id为12312的评分主题下按热度排序的索引
      //返回值为List<dataId>,可根据dataId以及类型进行排序

      dataJsonMap["rating_theme"]["12312"];
      //表示类型为评分主题,id为12312的json数据
      //返回值为dataJosn,可以为ui提供数据

      dataEyesMap["rating_theme"]["12312"]["hot"]
      //表示id为12312的评分主题下用户查看的进度
      //返回值为dataEyes

   ***************************************************************/

  //数据链接检索库
  ValueNotifier<Map<String, Map<String, Map<String, List<DataLink>>>>>
      dataLinkMap = ValueNotifier({});

  //json数据组
  ValueNotifier<Map<String, Map<String, DataJson>>> dataMap = ValueNotifier({});

  //数据阅读进度
  ValueNotifier<Map<String, Map<String, Map<String, DataEyes>>>>
  dataEyesMap = ValueNotifier({});

}

//ui部分
mixin UIPart {
  /***************************************************************
      标签选择相关参数
   ***************************************************************/

  //标签选择器动画
  late ValueNotifier<TabController> tabController;

  //当前标签索引
  ValueNotifier<int> nowTagIndex = ValueNotifier(0);

  //当前标签
  ValueNotifier<String> nowTagString = ValueNotifier("主页");

  //标签列表
  ValueNotifier<List<String>> nowTagList = ValueNotifier(["主页"]);

  /***************************************************************
      标签下的页面
   ***************************************************************/

  //页面列表
  ValueNotifier<Map<String, Widget>> nowPageMap = ValueNotifier({
    "主页": RatingPageMainPart(),
    "敬请期待": Loading(),
  });

  ValueNotifier<Widget> nowPageWidget = ValueNotifier(RatingPageMainPart());

  /***************************************************************
      数据排序相关参数
   ***************************************************************/

  //当前的排序方式
  ValueNotifier<String> nowSortType = ValueNotifier("热度");

  //数据索引排序(点赞数排序)
  ValueNotifier<List<String>> dataLinkListSortByLike = ValueNotifier([]);

  //数据索引排序(时间排序)
  ValueNotifier<List<String>> dataLinkListSortByTime = ValueNotifier([]);

  /***************************************************************
      下拉刷新相关参数
   ***************************************************************/

  //下拉刷新控制器
  late RefreshController refreshController;

  /***************************************************************
      时间与动画变量
   ***************************************************************/

  ValueNotifier<int> refreshRate = ValueNotifier(120);

  //时钟,记录已经生成的帧(120分之一秒为一帧)
  ValueNotifier<int> myFrame = ValueNotifier(0);

  //当前,已经走过的毫秒数
  ValueNotifier<int> myTime = ValueNotifier(0);

  //loadingBlock的颜色变化
  ValueNotifier<Color> lodingBlockColor =
      ValueNotifier(Color.fromRGBO(128, 128, 128, 1.0));

  //计算颜色的函数
  int calculateTrigonometricValue({
    required double period,
    required double maxValue,
    required double minValue,
    required double x,
  }) {
    if (period <= 0 || maxValue <= minValue) {
      throw ArgumentError(
          'Invalid arguments: period should be greater than 0, and maxValue should be greater than minValue.');
    }

    // 计算 x 在周期内的相对位置
    double relativeX = (x % period) / period;

    // 计算三角函数值
    double trigValue = (maxValue - minValue) / 2 * sin(2 * pi * relativeX) +
        (maxValue + minValue) / 2;

    // 将最终值取整
    return trigValue.round();
  }

  //时间流逝
  changeMyTime() async {
    Timer.periodic(Duration(milliseconds: 1000 ~/ refreshRate.value), (timer) {
      myFrame.value += 1;
      //避免数值溢出
      myFrame.value = myFrame.value % 10000000;
      myTime.value = myFrame.value * (1000 ~/ refreshRate.value);

      int c = calculateTrigonometricValue(
          period: 1400,
          maxValue: 188,
          minValue: 68,
          x: myTime.value.toDouble());
      lodingBlockColor.value = Color.fromRGBO(c, c, c, 1.0);
    });
  }
}

//整合
class RatingPageData extends ChangeNotifier with DataPart, UIPart{

  /***************************************************************
      初始化
   ***************************************************************/

  var isInit = false;

  init() {
    if (isInit) return;

    changeMyTime();

    nowTagIndex.addListener(() {
      nowTagString.value =
          nowTagList.value[nowTagIndex.value];
      nowPageWidget.value =
          nowPageMap.value[nowTagString.value]!;
    });
    isInit = true;
  }
}

//管理评分页面的数据

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/page/main_part/rating_page_main_part.dart';

import 'package:http/http.dart' as http;

///2024.2.1

/***************************************************************
    服务器IP,与基本数据类型
 ***************************************************************/
const String ServerIP = "http://4l88qh58.dongtaiyuming.net";
const List<String> dataTypeList = ["mainPage","theme","object","comment"];

const transDataType = {
  "mainPage":"主页",
  "theme":"评分主题",
  "object":"评分对象",
  "comment":"评论"
};

const transSortType = {
  "时间":"time",
  "热度":"hot"
};


/***************************************************************
    DEBUG
 ***************************************************************/
void debugOutput(BuildContext context, String dialogText) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('测试弹窗(应在正式版移除)'),
        content: Text(dialogText),
        actions: <Widget>[
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
          ),
        ],
      );
    },
  );
}


/***************************************************************
    数据索引
 ***************************************************************/
@immutable
class DataIndex {
  final String dataType;
  final String dataId;

  DataIndex(this.dataType, this.dataId);

  @override
  int get hashCode => dataType.hashCode ^ dataId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DataIndex
              && runtimeType == other.runtimeType
              && dataType == other.dataType
              && dataId == other.dataId;
}

DataIndex NullDataIndex = DataIndex("null","null");

/***************************************************************
    数据层级
 ***************************************************************/
class DataIndexTree{

  /***************************************************************
      初始化变量
   ***************************************************************/
  DataIndex myIndex;
  List<String> tagList;
  List<String> tagListChinese = [];

  DataIndexTree({required this.myIndex,required this.tagList}){
    for(var tag in tagList){
      children[tag] = [];

      switch(tag){
        case "time":
          tagListChinese.add("时间");
          break;
        case "hot":
          tagListChinese.add("热度");
          break;
      }
      //这个bug找了三个小时,注意初始化!!!
      loadingState[tag] = ValueNotifier("null");
      loadingState[tag]!.addListener(() {
        changeUI();
      });
      loading(tag);
    }
  }

  //重置
  reset(){
    for(var tag in tagList){
      loadingState[tag]!.value = "null";
      loading(tag);
    }
  }

  //当前状态四种:未加载"null",网络错误"error",加载中"loading",加载完成"finish"
  Map<String,ValueNotifier<String>> loadingState = {};
  Map<String,List<DataIndex>> children = {};
  ValueNotifier<bool> UI = ValueNotifier(false);

  //验证所有标签都加载完毕?
  bool isFinish(){
    for(var tag in tagList){
      if(loadingState[tag]!.value != "finish")return false;
    }
    changeUI();
    return true;
  }

  changeUI(){
    UI.value = !UI.value;
  }

  /***************************************************************
      网络请求
   ***************************************************************/
  Future<void> loading(String tag) async {

    if(loadingState[tag]!.value=="loading" || loadingState[tag]!.value=="finish")
      return;

    ///网络请求
    loadingState[tag]!.value = "loading";

    ///获得次级数据类型
    String childDataType = "";
    for(int i=0;i<dataTypeList.length;++i)if(dataTypeList[i]==myIndex.dataType)childDataType = dataTypeList[i+1]??"";

    var headers = {
      'User-Agent': 'Apifox/1.0.0 (https://apifox.com)'
    };

    String url = '$ServerIP/rating/page?'
        'dataType=${childDataType}'
        '&dataId=${myIndex.dataId}'
        '&sortType=${tag}';

    var request = http.Request('POST',
        Uri.parse(
            url
        )
    );

    request.headers.addAll(headers);

    ///接收数据
    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        ///成功请求
        loadingState[tag]!.value = "finish";

        ///解析数据
        var jsonString = await response.stream.bytesToString();
        List<dynamic> dataIdList = jsonDecode(jsonString);
        /*
        dataIdList:[1,2,3,4,5,6,7,8,9]
        ->
        dataIndexList:[DataIndex("theme","1"),DataIndex("theme","2"),DataIndex("theme","3")...]
         */

        List<DataIndex> dataIndexList = [];
        for(var dataId in dataIdList) {
          dataIndexList.add(
              DataIndex(childDataType,dataId.toString())
          );
        }
        children[tag] = dataIndexList;

      } else {
        ///失败请求
        loadingState[tag]!.value = "error";
        loading(tag);
      }
    } catch (e) {
      ///网络错误
      loadingState[tag]!.value = "error";
      loading(tag);
    }
  }
}

/***************************************************************
    数据缓存
 ***************************************************************/
class DataIndexLeaf {

  /***************************************************************
      变量初始化
   ***************************************************************/
  DataIndex myIndex;
  DataIndexLeaf({required this.myIndex});
  //当前状态四种:未加载"null",网络错误"error",加载中"loading",加载完成"finish"
  ValueNotifier<String> loadingState = ValueNotifier("null");
  late String jsonString;

  Map<String, dynamic> getMap() {
    return json.decode(jsonString);
  }

  /***************************************************************
      网络请求
   ***************************************************************/
  Future<void> loading() async {

    if(loadingState.value=="loading" || loadingState.value=="finish")
      return;

    loadingState.value = "loading";
    var headers = {
      'User-Agent': 'Apifox/1.0.0 (https://apifox.com)'
    };
    var request = http.Request('POST',
        Uri.parse(
            '$ServerIP/rating/get?'
            'dataType=${myIndex.dataType}'
            '&dataId=${myIndex.dataId}'
        )
    );
    request.headers.addAll(headers);
    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        ///成功请求
        loadingState.value = "finish";
        jsonString = await response.stream.bytesToString();
      } else {
        ///失败请求
        loadingState.value = "error";
        loading();
      }
    } catch (e) {
      ///网络错误
      loadingState.value = "error";
      loading();
    }

  }

}


/***************************************************************
    数据模块
 ***************************************************************/

mixin DataPart {

  /***************************************************************
      数据存储相关参数
   ***************************************************************/

  //数据树
  ValueNotifier<Map<DataIndex, DataIndexTree>> dataIndexTreeMap = ValueNotifier({});

  //数据组
  ValueNotifier<Map<DataIndex, DataIndexLeaf>> dataIndexLeafMap = ValueNotifier({});

  DataIndex getDataIndex(String dataType,String dataId){
    return DataIndex(dataType, dataId);
  }

  //创建空对象
  buildDataIndex(DataIndex theIndex){
    dataIndexTreeMap.value[theIndex] = DataIndexTree(myIndex: theIndex,tagList: ["time","hot"]);
    dataIndexLeafMap.value[theIndex] = DataIndexLeaf(myIndex: theIndex);
  }

  //返回监听器
  getIndexTreeLoadingState(DataIndex theIndex){
    if(dataIndexLeafMap.value.containsKey(theIndex)){
      return dataIndexLeafMap.value[theIndex]!;
    }
    else buildDataIndex(theIndex);
  }

  //返回监听器
  getIndexLeafLoadingState(DataIndex theIndex){
    if(dataIndexLeafMap.value.containsKey(theIndex)){
      return dataIndexLeafMap.value[theIndex]!;
    }
    else buildDataIndex(theIndex);
  }

  //获取索引树
  DataIndexTree getDataIndexTree(DataIndex theIndex){

    //如果存在则返回已经存在的数据
    if(dataIndexTreeMap.value.containsKey(theIndex)) return dataIndexTreeMap.value[theIndex]!;
    else buildDataIndex(theIndex);
    return getDataIndexTree(theIndex);
  }

  //获取数据叶
  DataIndexLeaf getDataIndexLeaf(DataIndex theIndex){

    //如果存在则返回已经存在的数据
    if(dataIndexLeafMap.value.containsKey(theIndex)){

      String loadingState = dataIndexLeafMap.value[theIndex]!.loadingState.value;
      //如果没加载则加载
      if(loadingState == "null"){
        dataIndexLeafMap.value[theIndex]!.loading();
      }
      //加载中
      else if(loadingState == "error"){
        return dataIndexLeafMap.value[theIndex]!;
      }
      else if(loadingState == "loading"){
        return dataIndexLeafMap.value[theIndex]!;
      }
      else if(loadingState == "finish"){
        return dataIndexLeafMap.value[theIndex]!;
      }
    }

    else buildDataIndex(theIndex);
    return getDataIndexLeaf(theIndex);
  }

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
  ValueNotifier<List<String>> nowTagList = ValueNotifier(["主页","敬请期待"]);

  /***************************************************************
      标签下的页面
   ***************************************************************/

  //页面列表
  ValueNotifier<Map<String, Widget>> nowPageMap = ValueNotifier({
    "主页": RatingPageMainPart(dataIndex: DataIndex("mainPage","1"),),
    "敬请期待": Loading(),
  });

  ValueNotifier<Widget> nowPageWidget = ValueNotifier(RatingPageMainPart(dataIndex: DataIndex("mainPage","1"),));

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

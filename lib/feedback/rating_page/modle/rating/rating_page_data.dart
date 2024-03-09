//管理评分页面的数据

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/power_load.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/user_data.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/page/main_part/rating_page_main_part.dart';

import 'package:http/http.dart' as http;

import '../../../../commons/preferences/common_prefs.dart';

///2024.2.1

/***************************************************************
    服务器IP,与基本数据类型
 ***************************************************************/
const String ServerIP = "http://120.26.59.82:2077";
const List<String> dataTypeList = ["mainPage","theme","object","comment"];
const bool isDebug = true;

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

String getMPID() {
  return CommonPreferences.lakeUid.value;
}

String truncateString(String input, {int maxLength = 8}) {
  if (input.length <= maxLength) {
    return input;
  } else {
    return input.substring(0, maxLength) + "...";
  }
}


/***************************************************************
    DEBUG
 ***************************************************************/

//调试输出
void debugOutput(BuildContext context, String dialogText) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('提示'),
        content: Text(dialogText),
        actions: <Widget>[
          TextButton(
            child: Text('收到'),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
          ),
        ],
      );
    },
  );
}

class LogDataValue {
  final List<String> logs;
  final List<Color> colors;

  LogDataValue(this.logs, this.colors);
}

class LogData extends ValueNotifier<LogDataValue> {
  LogData() : super(LogDataValue([], []));

  void addLog(String log, Color color) {
    value.logs.insert(0, log); // 添加到列表开始位置
    value.colors.insert(0, color); // 保持颜色和日志同步
    // 如果超过1000条日志，自动移除最早的条目
    if (value.logs.length > 100) {
      value.logs.removeLast();
      value.colors.removeLast();
    }
    notifyListeners(); // 通知监听者数据变更
  }

  void clear() {
    value = LogDataValue([], []);
  }
}

LogData logData = LogData();

String getFirstLog(){
  return logData.value.logs[0]??" ";
}

powerLog(String log, {Color color = Colors.black}) {
  logData.addLog(log, color);
  if (isDebug) {
    print(log);
  }
}

void powerDebug(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('日志系统'),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.9, //屏幕宽度的90%
          height: MediaQuery.of(context).size.width * 0.9, //屏幕高度的150%
          child: ValueListenableBuilder<LogDataValue>(
            valueListenable: logData,
            builder: (context, value, child) {
              return ListView.builder(
                itemCount: value.logs.length,
                itemBuilder: (context, index) {
                  return Container(
                    color: value.colors[index],
                    child: ListTile(
                      title: Text(value.logs[index],
                          style: TextStyle(color: Colors.white)),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('收到'),
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

  bool stopFlag = false;
  int loadingCount = 0;

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
        isFinish();
      });
      loading(tag);
    }
  }

  //重置
  reset(){
    stopFlag = false;
    loadingCount = 0;
    for(var tag in tagList){
      loadingState[tag]!.value = "null";
      loading(tag);
    }
    changeUI();
  }

  stop(){
    stopFlag = true;
  }

  reTry(){
    stopFlag = false;
    loadingCount = 0;
    for(var tag in tagList){
      loading(tag);
    }
    changeUI();
  }

  //当前状态四种:未加载"null",网络错误"error",加载中"loading",加载完成"finish"
  Map<String,ValueNotifier<String>> loadingState = {};
  Map<String,List<DataIndex>> children = {};
  ValueNotifier<bool> UI = ValueNotifier(false);

  //验证所有标签都加载完毕?
  bool isFinish(){
    for(String tag in tagList){
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

    //中断网络请求
    loadingCount += 1;
    if(loadingCount>8*tagList.length){
      stop();
    }
    if(stopFlag)return;

    if(loadingState[tag]!.value=="finish")
      return;

    ///网络请求
    if(loadingState[tag]!.value=="null")loadingState[tag]!.value = "loading";

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

        ///解析数据
        var jsonString = await response.stream.bytesToString();
        dynamic jsonData;
        try {
          jsonData = jsonDecode(jsonString);
        } catch (e) {
          // JSON 解析出错，处理异常情况
          print('JSON 解析出错: $e');
          loadingState[tag]!.value = "error";
          //等待400毫秒
          await Future.delayed(Duration(milliseconds: 400));
          loading(tag);
          return;
        }

        List<dynamic> dataIdList;
        // 检查数据是否为 List 类型
        if (jsonString.toString().contains("[")) {
          dataIdList = jsonData;
        } else {
          // 如果数据不是列表，则进行相应的错误处理
          print('数据不是列表类型');
          loadingState[tag]!.value = "error";
          //等待400毫秒
          await Future.delayed(Duration(milliseconds: 400));
          loading(tag);
          return;
        }


        ///成功请求
        loadingState[tag]!.value = "finish";
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
        //等待400毫秒
        await Future.delayed(Duration(milliseconds: 400));
        loading(tag);
        return;
      }
    } catch (e) {
      ///网络错误
      loadingState[tag]!.value = "error";
      //等待400毫秒
      await Future.delayed(Duration(milliseconds: 400));
      loading(tag);
      return;
    }
  }
}

/***************************************************************
    数据缓存
 ***************************************************************/
class DataIndexLeaf with PowerLoad{

  //数据创建
  create(String dataType,Map<String,String>data) async{
    init("create", "$ServerIP/rating/create", {
      "dataType":dataType,
      "data":json.encode(data),
    }, [
      "succeed"
    ]
    );
    await loading("create", true);
  }
  //数据缓存
  get(DataIndex myIndex) async {

    List<String>keyL;
    if(myIndex.dataType == "theme")keyL = [
      "commentCount",
      "updatedAt",
      "themeDescribe",
      "createdAt",
      "themeName",
      "themeCreator",
      "themeId"
    ];
    else keyL = [];
    init("get", "$ServerIP/rating/get", {
      "dataType":myIndex.dataType,
      "dataId":myIndex.dataId,
    }, keyL
    );
    await loading("get", true);
  }
  //更新数据
  update(DataIndex myIndex,Map<String,String>data) async{
    init("update", "$ServerIP/rating/update", {
      "dataType":myIndex.dataType,
      "dataId":myIndex.dataId,
      "data":json.encode(data),
      "userId":myUserId,
    }, [
      "succeed"
    ]
    );
    await loading("update", true);
  }
  //删除数据
  delete(DataIndex myIndex) async{
    init("delete", "$ServerIP/rating/delete", {
      "dataType":myIndex.dataType,
      "dataId":myIndex.dataId,
      "userId":myUserId,
    }, [
      "succeed"
    ]
    );
    await loading("delete", true);
  }
  //点赞
  like(DataIndex myIndex) async{
    init("like", "$ServerIP/rating/like", {
      "dataType":myIndex.dataType,
      "dataId":myIndex.dataId,
      "userId":myUserId,
    }, [
      "succeed"
    ]
    );
    await loading("like", true);
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
    dataIndexLeafMap.value[theIndex] = DataIndexLeaf();
  }

  /*
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

   */

  //获取索引树
  DataIndexTree getDataIndexTree(DataIndex theIndex){

    //如果存在则返回已经存在的数据
    if(dataIndexTreeMap.value.containsKey(theIndex)){
      return dataIndexTreeMap.value[theIndex]!;
    }
    else buildDataIndex(theIndex);
    return getDataIndexTree(theIndex);
  }

  //获取数据叶
  DataIndexLeaf getDataIndexLeaf(DataIndex theIndex){

    //如果存在则返回已经存在的数据
    if(dataIndexLeafMap.value.containsKey(theIndex)){
      dataIndexLeafMap.value[theIndex]!.focus();
      if(dataIndexLeafMap.value[theIndex]!.isSucceed("get"))
        return dataIndexLeafMap.value[theIndex]!;
      dataIndexLeafMap.value[theIndex]!.get(theIndex);
      return dataIndexLeafMap.value[theIndex]!;
    }

    else {
      buildDataIndex(theIndex);
      //遍历dataLeafMap
      dataIndexLeafMap.value.forEach((key, value) {
        value.release();
      });
    }
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

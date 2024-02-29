import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/rating_page_data.dart';

class LoadingState{
  /***************************************************************
      记录加载状态
      //未加载:null,加载中:loading,加载成功:success,加载失败:error
   ***************************************************************/
  String loadingState = "null";
  ValueNotifier<int> progress = ValueNotifier(0);//加载进度

  /***************************************************************
      中止与释放参数
   ***************************************************************/
  int stopCount = 0;
  bool stopFlag = false;
  changeProgress(int progress){
    this.progress.value = progress;
  }
  bool isSucceed(){
    return loadingState == "success";
  }
  bool isError(){
    return loadingState == "error";
  }
  stop(){
    stopFlag = true;
  }
  retry(){
    loadingState = "null";
    stopFlag = false;
    stopCount = 0;
  }
}

///独立的post加载模块,可以嵌入到任意数据类中
///专为微北洋评分模块开发
mixin PowerLoad{

  /***************************************************************
      记录加载情况
   ***************************************************************/
  Map<String,String> uriM = {};
  Map<String,Map<String,String>> bodyM = {};
  Map<String,List<String>> keyL = {};
  Map<String,Map<String,dynamic>> dataM = {};
  Map<String,LoadingState> loadingStateM = {};

  int releaseCount = 0;
  int nowLoading = 0; ///当前加载的进程数量

  List<String> log = [];

  LL(String l){
    if(!isDebug)return;
    log.add(l);
    if(log.length>20)log.removeAt(0);
  }

  /***************************************************************
      通知UI更新
   ***************************************************************/
  ValueNotifier<bool> UI = ValueNotifier(false);
  //改变UI
  changeUI(){
    UI.value = !UI.value;
  }
  //是否加载成功
  bool isSucceed(String loadingCmd){
    if(!loadingStateM.containsKey(loadingCmd))
      return false;
    if(loadingStateM[loadingCmd]!.isSucceed())
      changeUI();
    return loadingStateM[loadingCmd]!.isSucceed();
  }
  //是否加载失败
  bool isError(String loadingCmd){
    if(!loadingStateM.containsKey(loadingCmd))
      return true;
    if(loadingStateM[loadingCmd]!.isError())
      changeUI();
    return loadingStateM[loadingCmd]!.isError();
  }

  /***************************************************************
      细节操作
   ***************************************************************/
  //中止
  stop(String loadingCmd){
    loadingStateM[loadingCmd]!.stop();
    changeUI();
  }
  //全部重置
  reset(String loadingCmd){
    loadingStateM[loadingCmd]!.retry();
    changeUI();
  }
  //重试
  retry(String loadingCmd){
    loadingStateM[loadingCmd]!.retry();
    loading(loadingCmd,true);
  }
  // 焦点
  focus(){
    releaseCount = 0;
  }
  //释放
  release(){
    releaseCount+=1;
    if(releaseCount>=100&&nowLoading==0){
      releaseCount = 0;
      dataM = {};
      //重置全部
      for(var key in loadingStateM.keys)
        loadingStateM[key]!=LoadingState();
    }
  }
  //初始化
  init(String loadingCmd,String uri,Map<String,String> body,List<String> keyL){
    //此处参数为必填,上回没填全引发了非空断言bug
    this.uriM[loadingCmd] = uri;
    this.bodyM[loadingCmd] = body;
    this.keyL[loadingCmd] = keyL;
    this.dataM[loadingCmd] = {};
    this.loadingStateM[loadingCmd] = LoadingState();
  }
  //错误处理
  error(String loadingCmd,bool autoStop) async {
    powerLog("指令$loadingCmd加载失败");
    loadingStateM[loadingCmd]!.loadingState = "error";
    if(autoStop)
      await Future.delayed(Duration(microseconds: 144));
    else await Future.delayed(Duration(microseconds: 1444));
    loading(loadingCmd,autoStop);
    changeUI();
  }
  //成功处理
  success(String loadingCmd){
    loadingStateM[loadingCmd]!.loadingState = "success";
    nowLoading-=1;
    changeUI();
  }

  /***************************************************************
      网络请求
      //canStop:是否可以中止
   ***************************************************************/
  Future<void> loading(String loadingCmd,bool autoStop) async {

    nowLoading+=1;
    if(uriM[loadingCmd] == null)
      throw ArgumentError("url不能为空,请先使用init()再使用loading()");

    if(loadingStateM[loadingCmd]!.loadingState == "success")return;
    loadingStateM[loadingCmd]!.loadingState = "loading";

    if(autoStop){
      if(loadingStateM[loadingCmd]!.stopFlag)return;
      loadingStateM[loadingCmd]!.stopCount+=1;
      if(loadingStateM[loadingCmd]!.stopCount>=4)stop(loadingCmd);
    }

    powerLog("初始化指令$loadingCmd");
    var headers = {
      'User-Agent': 'Apifox/1.0.0 (https://apifox.com)'
    };
    var request = http.MultipartRequest('POST', Uri.parse(uriM[loadingCmd]!));
    request.fields.addAll(bodyM[loadingCmd]!);

    request.headers.addAll(headers);

    powerLog("打包完成,开始连接");

    http.StreamedResponse response;
    try{
      response = await request.send();
    }
    catch(e){
      powerLog(e.toString());
      return error(loadingCmd,autoStop);
    }


    powerLog("连接状态${response.statusCode.toString()}");

    //成功
    if (response.statusCode == 200) {
      String json = await response.stream.bytesToString();
      powerLog("服务器返回$json");
      //解析json
      dataM[loadingCmd] = jsonDecode(json);
      //验证全部key是否存在
      for(var key in keyL[loadingCmd]!)
        if(!dataM[loadingCmd]!.containsKey(key))
          return error(loadingCmd,autoStop);
      //成功
      powerLog("指令$loadingCmd成功完成");
      return success(loadingCmd);
    }
    //寄了
    else return await error(loadingCmd,autoStop);
  }

}
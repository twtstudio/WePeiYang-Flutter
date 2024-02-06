//声明网络类,用于获取相关数据

import 'dart:convert';
import 'dart:js';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';

import 'rating_page_data.dart';



class RatingDataService {

  //优先级列表
  Map<String,List<String>> loadingLinkList = {"now":[],"sort":[],"sub":[]};

  getJsonFromServer(String dataPath){
    //如果本地已经存在该数据,则直接返回该数据
    //
    if(Provider.of<RatingPageData>(context as BuildContext).dataMap.value.containsKey(dataPath)) {
      
    }
  }



}
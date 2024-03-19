import 'dart:convert';
import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/rating_page_data.dart';

import 'power_load.dart';

//连接微北洋论坛与评分页面数据的桥梁
class RatingPageUser with PowerLoad{
  //用户的id
  String userId;
  RatingPageUser({required this.userId});

  //获取用户的数据
  Future<void> get(String userId) async{
    init(
        "get",
        "$ServerIP/user/get",
        {
          "id":userId,
        },
        ["userId","userName","userImg"]
    );
    loading("get", true);
  }

  //更新信息(一直执行,直到成功)
  Future<void> add(String userName,String userImg) async{
    init(
        "add",
        "$ServerIP/user/add",
        {
          "id":userId,
          "name":userName,
          "img":userImg,
        },
        ["output"]
    );
    loading("add", false);
  }

}

late String myUserId;
late String myUserName;
late String myUserImg;

//管理评分系统里用户的数据
class RatingUserData extends ChangeNotifier{
  //存储本用户的信息

  late RatingPageUser myUser;
  bool isInit=false;

  Map<String,RatingPageUser> userMap={};

  Future<String> urlToBase64(String imageUrl) async {

    if(imageUrl == "")return "";
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      final Uint8List bytes = response.bodyBytes;
      final String base64Image = base64Encode(bytes);
      return base64Image;
    } else {
      throw Exception('Failed to load image');
    }
  }

  RatingPageUser getUser(String userId){

    //如果存在则返回已经存在的数据
    if(userMap.containsKey(userId)){
      //powerLog("${userMap[userId]!.dataM.toString()}");
      userMap[userId]!.focus();
      if(userMap[userId]!.isSucceed("get"))
        return userMap[userId]!;

      userMap[userId]!.get(userId);
      return userMap[userId]!;
    }

    else {
      userMap[userId] = RatingPageUser(userId: userId);
      //遍历dataLeafMap
      userMap[userId]!.get(userId);
    }
    return userMap[userId]!;
  }

  //初始化函数
  init() async {
    myUserId = CommonPreferences.lakeUid.value;
    myUserName = CommonPreferences.lakeNickname.value;
    myUserImg = await urlToBase64('https://qnhdpic.twt.edu.cn/download/origin/'+CommonPreferences.avatar.value);

    //但凡有一个为空,两秒后重新获取
    if(myUserId == "" || myUserName == "" || myUserImg == ""){
      Future.delayed(Duration(seconds: 2), () async{
        return init();
      });
    }
    userMap[myUserId] = RatingPageUser(userId: myUserId);
    userMap[myUserId]!.add(myUserName, myUserImg);
    userMap[myUserId]!.get(myUserId);
    isInit = true;
  }

}
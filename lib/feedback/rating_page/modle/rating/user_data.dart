import 'dart:ffi';

import 'package:flutter/cupertino.dart';

//管理评分系统里用户的数据
class RatingUserData extends ChangeNotifier{
  //是否点赞过??(id到是否)
  ValueNotifier<Map<String,Bool>>
  isLiked
  =ValueNotifier({});
  //创建过哪些评分主题/对象/评论(索引形式)
  ValueNotifier<List<String>>
  userCreateLinkList
  =ValueNotifier([]);
  //对索引的解析
  ValueNotifier<List<String>>
  userCreateList
  =ValueNotifier([]);

}
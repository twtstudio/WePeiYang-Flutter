import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import '../../ui/rating_page_tarbar_ui.dart';
import '../../page/main_part/rating_page_main_part.dart';
import '../../page/rating_page.dart';

// 管理页面切换按钮中数据的类
class PageSwitchingData extends ChangeNotifier{

  /***************************************************************
      定义页面列表相关参数
   ***************************************************************/

  // 当前页面类型
  ValueNotifier<String>
  nowPageTypeString
  = ValueNotifier(
      "论坛"
  );

  // 页面类型列表
  ValueNotifier<List<String>>
  pageTypeList 
  = ValueNotifier(["论坛","评分"]);

  // 页面类型所对应的页面 Widget 列表
  ValueNotifier<Map<String, Widget>>
  pageWidgetMap
  = ValueNotifier(
      {"评分": RatingPage()}
  );

  //页面类型所对应的专题选择器列表
  ValueNotifier<Map<String, Widget>>
  pageTabBarMap
  = ValueNotifier(
      {"评分": RatingPageTabBar()}
  );

  /***************************************************************
      选择器ui相关参数
   ***************************************************************/

  // 当前按钮显示的文字
  ValueNotifier<String>
  nowButtonTextString
  = ValueNotifier(
      "论坛"
  );

  // 当前按钮文字显示的颜色
  ValueNotifier<Color>
  nowTextColor
  = ValueNotifier(
      Colors.blue
  );

  /***************************************************************
      当前页面
   ***************************************************************/

  // 当前页面
  ValueNotifier<Widget>
  nowPageWidget
  = ValueNotifier(
      Loading(),
  );

  // 当前标签选择器
  ValueNotifier<Widget>
  nowPageTabBarWidget
  = ValueNotifier(
      Loading(),
  );

  /***************************************************************
      初始化
   ***************************************************************/

  // 是否初始化了?
  var isInit=false;

  init(){
    if(isInit)return;
    //根据当前页面类型变化修改其他参数
    nowPageTypeString.addListener(() {
      nowButtonTextString.value = nowPageTypeString.value;
      nowPageWidget.value = pageWidgetMap.value[nowPageTypeString.value]!;
      nowPageTabBarWidget.value = pageTabBarMap.value[nowPageTypeString.value]!;
    });

    isInit = true;
  }

}

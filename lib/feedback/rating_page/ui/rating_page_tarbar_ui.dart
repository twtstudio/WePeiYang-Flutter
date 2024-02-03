import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/rating_page_data.dart';

import '../../../commons/util/color_util.dart';
import '../../../commons/util/text_util.dart';
import '../../../message/feedback_message_page.dart';
import '../../view/components/widget/tab.dart';

class RatingPageTabBar extends StatefulWidget {
  @override
  _RatingPageTabBarState createState() => _RatingPageTabBarState();
}

class _RatingPageTabBarState extends State<RatingPageTabBar>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {

  late TabController tabController;

  @override
  void initState() {
    super.initState();

    tabController = TabController(
      length: context.read<RatingPageData>().nowTagList.value.length,
      vsync: this,
    );

    tabController.addListener(() {
      context.read<RatingPageData>().nowTagIndex.value = tabController.index;
    });
  }
  @override
  Widget build(BuildContext context) {

    List<String> nowTagList = context.read<RatingPageData>().nowTagList.value;

    var tabBar1 = TabBar(
      indicatorPadding: EdgeInsets.only(bottom: 2),
      // 指示器底部的填充
      labelPadding: EdgeInsets.only(bottom: 3),
      // 选中标签底部的填充
      isScrollable: true,
      // 允许选项卡栏水平滚动
      physics: BouncingScrollPhysics(),
      // 滚动效果使用BouncingScrollPhysics
      controller: tabController,
      // 使用LakeModel中的tabController作为控制器
      labelColor: ColorUtil.blue2CColor,
      // 选中标签的文本颜色
      labelStyle: TextUtil.base.w400.NotoSansSC.sp(18),
      // 选中标签的文本样式
      unselectedLabelColor: ColorUtil.black2AColor,
      // 未选中标签的文本颜色
      unselectedLabelStyle: TextUtil.base.w400.NotoSansSC.sp(18),
      // 未选中标签的文本样式
      indicator: CustomIndicator(
        // 指示器的自定义外观
        borderSide: BorderSide(
          color: ColorUtil.blue2CColor, // 指示器的颜色
          width: 2, // 指示器的宽度
        ),
      ),
      tabs: List<Widget>.generate(
        // 生成选项卡
        nowTagList.length, // 选项卡的数量，根据tabList的长度确定
        (index) => DaTab(
          // 创建DaTab小部件
          text: nowTagList[index], // 选项卡文本，根据tabList中的shortname属性确定
          withDropDownButton: false,
        ),
      ),
      onTap: (a)=> context.read<RatingPageData>().nowTagIndex.value = tabController.index,
    );

    return tabBar1;
  }

  @override
  bool get wantKeepAlive => true;
}

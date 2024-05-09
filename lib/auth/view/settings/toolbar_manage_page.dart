import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/order_update_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/auth/view/settings/edit_user_tool_bottom_sheet.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/home/view/wpy_page.dart';
import 'package:we_pei_yang_flutter/schedule/view/edit_widgets.dart';
import '../../../commons/widgets/colored_icon.dart';
import '../../../feedback/view/components/widget/long_text_shower.dart';
import '../../../gpa/gpa_router.dart';
import '../../../home/home_router.dart';
import '../../../home/view/map_calendar_page.dart';
import '../../../commons/preferences/common_prefs.dart';
import '../../../commons/themes/template/wpy_theme_data.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/util/text_util.dart';
import '../../../commons/widgets/w_button.dart';
import '../../../schedule/schedule_router.dart';

class ToolbarManagePage extends StatefulWidget {
  @override
  _ToolbarManagePageState createState() => _ToolbarManagePageState();
}

class _ToolbarManagePageState extends State<ToolbarManagePage> {
  List<CardBean> peiYangTools = [
    CardBean("assets/svg_pics/lake_butt_icons/daily.png", 21.w, '课程表',
        'Schedule', ScheduleRouter.course),
    CardBean('assets/svg_pics/lake_butt_icons/QR.png', 24.w, '入校码', 'Entry QR',
        HomeRouter.casQR),
    CardBean("assets/svg_pics/lake_butt_icons/news.png", 24.w, '新闻网', 'News',
        HomeRouter.news),
    CardBean('assets/images/schedule/add.png', 24.w, '地图·校历', 'Map-\nCalendar',
        HomeRouter.mapCalenderPage),
    CardBean('assets/svg_pics/lake_butt_icons/wiki.png', 24.w, '北洋维基', 'Wiki',
        'https://wiki.tjubot.cn/'),
    CardBean('assets/svg_pics/lake_butt_icons/gpa.png', 24.w, '成绩', 'GPA',
        GPARouter.gpa),
    CardBean('assets/svg_pics/lake_butt_icons/game.png', 33.w, '小游戏', 'Game',
        HomeRouter.game)
  ];
  List<CardBean> userTools = CommonPreferences.userTool.value;

  bool isDisplayed(CardBean bean) {
    //根据label检索
    for (int e = 0; e < CommonPreferences.displayedTool.value.length; e++) {
      if (CommonPreferences.displayedTool.value[e].label == bean.label)
        return true;
    }
    return false;
  }

  Future<dynamic> showDetailDialog(BuildContext context, int i) {
    return showDialog(
        context: context,
        builder: (BuildContext c) {
          return Center(
            child: detailDialog(context, i, c),
          );
        });
  }

  final _scrollController = ScrollController();
  final _gridViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Container detailDialog(BuildContext context, int i, BuildContext c) {
    return Container(
      width: 300.w,
      height: 250.h,
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
      decoration: BoxDecoration(
          color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
          borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              WButton(
                onPressed: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back,
                    color: WpyTheme.of(context).get(WpyColorKey.oldActionColor),
                    size: 25.r),
              ),
              SizedBox(width: 10.w),
              Text('个性化工具详情',
                  style: TextUtil.base.PingFangSC.bold.label(context).sp(18))
            ],
          ),
          CardWidget(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text("标题：${CommonPreferences.userTool.value[i].label}",
                      style:
                          TextUtil.base.PingFangSC.bold.label(context).sp(14))
                ],
              ),
              Row(
                children: [
                  Text("副标题：${CommonPreferences.userTool.value[i].eng}",
                      style:
                          TextUtil.base.PingFangSC.bold.label(context).sp(14))
                ],
              ),
              Row(
                children: [
                  Text("跳转坐标：",
                      style:
                          TextUtil.base.PingFangSC.bold.label(context).sp(14))
                ],
              ),
              ExpandableText(
                text: '${CommonPreferences.userTool.value[i].route}',
                style: TextUtil.base.PingFangSC.bold.label(context).sp(14),
                maxLines: 5,
                expand: false,
                buttonIsShown: true,
                isHTML: false,
              )
            ],
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              WButton(
                onPressed: () => Navigator.pop(c),
                child: Padding(
                  padding: EdgeInsets.only(right: 15.w),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 6.h),
                    decoration: BoxDecoration(
                      color: WpyTheme.of(context)
                          .get(WpyColorKey.oldSwitchBarColor)
                          .withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text('关闭',
                        style: TextUtil.base.medium.sp(16).oldHint(context)),
                  ),
                ),
              ),
              WButton(
                onPressed: () {
                  setState(() {
                    CommonPreferences.userTool.value.removeAt(i);
                  });
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 15.w),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 6.h),
                    decoration: BoxDecoration(
                      color: WpyTheme.of(context)
                          .get(WpyColorKey.dangerousRed)
                          .withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text('删除',
                        style: TextUtil.base.medium.sp(16).bright(context)),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('管理工具栏',
            style: TextUtil.base.bold.sp(16).oldActionColor(context)),
        centerTitle: true,
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: WButton(
              child: Icon(Icons.arrow_back,
                  color: WpyTheme.of(context).get(WpyColorKey.oldActionColor),
                  size: 32.r),
              onPressed: () => Navigator.pop(context)),
        ),
        actions: [
          WButton(
            onPressed: () {
              setState(() {
                CommonPreferences.displayedTool.value.clear();
                CommonPreferences.displayedTool.value.addAll(peiYangTools);
              });
              ToastProvider.success("已重置！");
            },
            child: Padding(
              padding: EdgeInsets.only(right: 15.w),
              child: Container(
                padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 6.h),
                decoration: BoxDecoration(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.dangerousRed)
                      .withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text('重置',
                    style: TextUtil.base.medium.sp(16).bright(context)),
              ),
            ),
          )
        ],
      ),
      backgroundColor:
          WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          children: [
            SizedBox(height: 5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('长按拖拽可调整应用位置（首页也可以喵）',
                    style: TextUtil.base.medium.sp(14).oldHint(context))
              ],
            ),
            SizedBox(height: 5.h),
            //首页显示的工具栏
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
              decoration: BoxDecoration(
                color: WpyTheme.of(context)
                    .get(WpyColorKey.primaryBackgroundColor),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('首页工具栏',
                      style: TextUtil.base.bold.sp(16).oldActionColor(context)),
                  SizedBox(
                    height: 10.h,
                  ),
                  ReorderableBuilder(
                    children: [
                      for (int i = 0;
                          i < CommonPreferences.displayedTool.value.length;
                          i++)
                        WButton(
                          key: ValueKey(
                              CommonPreferences.displayedTool.value[i].route),
                          onPressed: () {
                            setState(() {
                              if (CommonPreferences
                                      .displayedTool.value.length <=
                                  2)
                                ToastProvider.error("您保留的太少啦！最少两个哦");
                              else
                                CommonPreferences.displayedTool.value
                                    .removeAt(i);
                            });
                          },
                          child: generateSelectCard(
                              context,
                              CommonPreferences.displayedTool.value[i],
                              true,
                              true),
                        )
                    ],
                    builder: (children) {
                      return GridView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          key: _gridViewKey,
                          controller: _scrollController,
                          children: children,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 30 / 19,
                            crossAxisSpacing: 15.w,
                          ));
                    },
                    onReorder: (List<OrderUpdateEntity> orderUpdateEntities) {
                      for (final orderUpdateEntity in orderUpdateEntities) {
                        final _displayTool = CommonPreferences
                            .displayedTool.value
                            .removeAt(orderUpdateEntity.oldIndex);
                        CommonPreferences.displayedTool.value
                            .insert(orderUpdateEntity.newIndex, _displayTool);
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            //系统自带的工具
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
              decoration: BoxDecoration(
                color: WpyTheme.of(context)
                    .get(WpyColorKey.primaryBackgroundColor),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('系统默认工具',
                      style: TextUtil.base.bold.sp(16).oldActionColor(context)),
                  SizedBox(
                    height: 10.h,
                  ),
                  Wrap(
                    spacing: 20.w,
                    children: [
                      for (int i = 0; i < peiYangTools.length; i++)
                        isDisplayed(peiYangTools[i])
                            ? generateSelectCard(
                                context, peiYangTools[i], false, true)
                            : WButton(
                                onPressed: () {
                                  setState(() {
                                    if (CommonPreferences
                                            .displayedTool.value.length >=
                                        8)
                                      ToastProvider.error("会不会太多了呢？最多8个喵~");
                                    else
                                      CommonPreferences.displayedTool.value
                                          .add(peiYangTools[i]);
                                  });
                                },
                                child: generateSelectCard(
                                    context, peiYangTools[i], false, false),
                              )
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 10.h),
            //用户可自己新建的工具
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
              decoration: BoxDecoration(
                color: WpyTheme.of(context)
                    .get(WpyColorKey.primaryBackgroundColor),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('个性化工具',
                          style: TextUtil.base.bold
                              .sp(16)
                              .oldActionColor(context)),
                      WButton(
                        onPressed: () {
                          if (CommonPreferences.userTool.value.length < 8)
                            showModalBottomSheet(
                              context: context,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20.r)),
                              ),
                              isDismissible: true,
                              enableDrag: false,
                              isScrollControlled: true,
                              builder: (context) => EditUserToolBottomSheet(),
                            ).then((value) => setState(() {}));
                          else
                            ToastProvider.error("会不会太多了呢？最多8个喵~");
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 5.w),
                          child: Container(
                            padding: EdgeInsets.fromLTRB(8.w, 2.h, 8.w, 2.h),
                            decoration: BoxDecoration(
                              color: WpyTheme.of(context)
                                  .get(WpyColorKey.primaryActionColor),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text('+',
                                style: TextUtil.base.medium
                                    .sp(18)
                                    .bright(context)),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 15.h),
                  CommonPreferences.userTool.value.isEmpty
                      ? Container(
                          height: 48.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('这里还什么都没有呢，快去创建一个吧↗',
                                  style: TextUtil.base.medium
                                      .sp(14)
                                      .oldHint(context))
                            ],
                          ),
                        )
                      : Wrap(
                          spacing: 20.w,
                          children: [
                            for (int i = 0;
                                i < CommonPreferences.userTool.value.length;
                                i++)
                              isDisplayed(CommonPreferences.userTool.value[i])
                                  ? GestureDetector(
                                      onLongPress: () {
                                        showDetailDialog(context, i);
                                      },
                                      child: generateSelectCard(
                                          context,
                                          CommonPreferences.userTool.value[i],
                                          false,
                                          true),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (CommonPreferences
                                                  .displayedTool.value.length >=
                                              8)
                                            ToastProvider.error(
                                                "会不会太多了呢？最多8个喵~");
                                          else
                                            CommonPreferences
                                                .displayedTool.value
                                                .add(CommonPreferences
                                                    .userTool.value[i]);
                                        });
                                      },
                                      onLongPress: () {
                                        showDetailDialog(context, i);
                                      },
                                      child: generateSelectCard(
                                          context,
                                          CommonPreferences.userTool.value[i],
                                          false,
                                          false),
                                    )
                          ],
                        ),
                ],
              ),
            ),
            SizedBox(height: 5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('长按查看个性化工具详情',
                    style: TextUtil.base.medium.sp(14).oldHint(context))
              ],
            ),
            SizedBox(height: 20.h)
          ],
        ),
      ),
    );
  }

  Container generateSelectCard(
      //实际上是两个组件写在同一个里面，第一个bool控制是不是被选中的列表，第二个bool控制在非选中列表中，该元素有没有被选中
      BuildContext context,
      CardBean bean,
      bool isDisplayed,
      bool isSelected) {
    return Container(
      width: 150.w,
      height: 80.h,
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: MapAndCalenderState().cardDecoration(context),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(width: 4.w),
              Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 0.2,
                    child: Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            WpyTheme.of(context).get(WpyColorKey.beanDarkColor),
                      ),
                    ),
                  ),
                  ColoredIcon(
                    bean.path,
                    width: bean.width,
                    color: WpyTheme.of(context).primary,
                  )
                ],
              ),
              SizedBox(width: 14.w),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 70.w,
                    child: Text(bean.eng,
                        maxLines: 2,
                        style: TextUtil.base.w500.label(context).sp(12).w400,
                        overflow: TextOverflow.ellipsis),
                  ),
                  SizedBox(
                    width: 70.w,
                    child: Text(bean.label,
                        maxLines: 2,
                        style: TextUtil.base.w400.label(context).sp(12).medium),
                  ),
                ],
              )
            ],
          ),
          Align(
            alignment: Alignment.topRight,
            child: Transform.translate(
              offset: Offset(5.r, -5.r),
              child: isDisplayed
                  ? Image.asset(
                      width: 22.r,
                      "assets/images/tool_minus.png",
                    )
                  : isSelected
                      ? null
                      : Image.asset(
                          width: 22.r,
                          "assets/images/tool_add.png",
                        ),
            ),
          )
        ],
      ),
    );
  }
}

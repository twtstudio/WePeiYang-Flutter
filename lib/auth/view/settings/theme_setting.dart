import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/colored_icon.dart';
import 'package:we_pei_yang_flutter/commons/widgets/schedule_background.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/home/view/map_calendar_page.dart';

class ThemeSetting extends StatefulWidget {
  const ThemeSetting({super.key});

  @override
  State<ThemeSetting> createState() => _ThemeSettingState();
}

class _ThemeSettingState extends State<ThemeSetting>
    with SingleTickerProviderStateMixin {
  late WpyThemeData shiftTheme;
  bool canMove = true;

  @override
  void initState() {
    super.initState();
  }

  shift() {
    shiftToLight();
    shiftToDark();
  }

  shiftToLight() {
    if (globalTheme.value.meta.brightness == Brightness.dark) {
      globalTheme.value = shiftTheme;
      CommonPreferences.appDarkThemeId.clear();
      CommonPreferences.usingDarkTheme.value = 1;
    }
  }

  shiftToDark() {
    if (globalTheme.value.meta.brightness == Brightness.light) {
      globalTheme.value = shiftTheme;
      CommonPreferences.appDarkThemeId.value = shiftTheme.meta.darkThemeId;
      CommonPreferences.usingDarkTheme.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    shiftTheme = WpyThemeData.themeList.firstWhere((element) {
      return element.meta.themeId ==
          (globalTheme.value.meta.brightness == Brightness.light
              ? globalTheme.value.meta.darkThemeId
              : CommonPreferences.appThemeId.value);
    }, orElse: () => WpyThemeData.brightThemeList[0]);
    Widget gridView = GridView(
      //解决无限高度问题
      shrinkWrap: true,
      physics: new NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
      ),
      children: [
        for (final theme in WpyThemeData.brightThemeList)
          GestureDetector(
            onTap: () {
              globalTheme.value = theme;
              CommonPreferences.usingDarkTheme.value = 0;
              CommonPreferences.appThemeId.value = theme.meta.themeId;
            },
            child: WpyThemeCard(
              name: theme.meta.name,
              primaryColor: theme.meta.representativeColor,
              hintTextColor: theme.meta.hintTextColor,
              selected: theme.meta.themeId ==
                  WpyTheme.of(context).themeData.meta.themeId,
            ),
          ),
      ],
    );

    Widget exampleCard = Container(
      width: 150.w,
      height: 80.h,
      margin: EdgeInsets.fromLTRB(18.h, 2.h, 0, 16.h),
      decoration: MapAndCalenderState().cardDecoration(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: 12.w),
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
                    color: WpyTheme.of(context).get(
                      WpyColorKey.beanLightColor,
                    ),
                  ),
                ),
              ),
              ColoredIcon(
                "assets/svg_pics/lake_butt_icons/daily.png",
                width: 21.w,
                color: WpyTheme.of(context).primary,
              ),
            ],
          ),
          SizedBox(width: 14.w),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 10.h,
                width: 60.w,
                decoration: BoxDecoration(
                  color: WpyTheme.of(context).get(WpyColorKey.labelTextColor),
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.w),
                  ),
                ),
              ),
              SizedBox(height: 4.5.h),
              Container(
                height: 6.h,
                width: 50.w,
                decoration: BoxDecoration(
                  color: WpyTheme.of(context).get(WpyColorKey.unlabeledColor),
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.w),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
    Widget exampleCard2 = Container(
      width: 150.w,
      height: 80.h,
      margin: EdgeInsets.fromLTRB(18.h, 2.h, 0, 16.h),
      decoration: MapAndCalenderState().cardDecoration(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: 12.w),
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
                    color: WpyTheme.of(context).get(
                      WpyColorKey.beanLightColor,
                    ),
                  ),
                ),
              ),
              ColoredIcon(
                "assets/svg_pics/lake_butt_icons/lost_and_found.png",
                width: 21.w,
                color: WpyTheme.of(context).primary,
              ),
            ],
          ),
          SizedBox(width: 14.w),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 10.h,
                width: 60.w,
                decoration: BoxDecoration(
                  color: WpyTheme.of(context).get(WpyColorKey.labelTextColor),
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.w),
                  ),
                ),
              ),
              SizedBox(height: 4.5.h),
              Container(
                height: 6.h,
                width: 50.w,
                decoration: BoxDecoration(
                  color: WpyTheme.of(context).get(WpyColorKey.unlabeledColor),
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.w),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );

    Widget layout = Stack(
      children: [
        InkWell(
          onTap: () => shift(),
          child: Opacity(
            opacity: globalTheme.value.meta.brightness == Brightness.light
                ? 0.9
                : 0.5,
            child: Container(
              height: 0.74.sw,
              width: 1.sw - 10.w,
              clipBehavior: Clip.hardEdge,
              margin: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.w)),
                  color: shiftTheme.meta.representativeColor),
              child: Stack(
                alignment: Alignment.centerLeft,
                clipBehavior: Clip.hardEdge,
                fit: StackFit.loose,
                children: [
                  Positioned(
                    left: 10,
                    top: -0.09.sw,
                    child: Text(
                      shiftTheme.meta.name,
                      overflow: TextOverflow.clip,
                      style: TextUtil.base.w900
                          .sp(80)
                          .copyWith(color: Colors.white30),
                    ),
                  ),
                  Positioned(
                    left: 20.w,
                    top: 0.04.sw,
                    child: Text(
                      '切换至浅色主题',
                      overflow: TextOverflow.clip,
                      style: TextUtil.base.w400.sp(18).copyWith(
                          color:
                              shiftTheme.data.get(WpyColorKey.brightTextColor)),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    bottom: -0.09.sw,
                    child: Text(
                      shiftTheme.meta.name,
                      overflow: TextOverflow.clip,
                      style: TextUtil.base.whiteO60.w900
                          .sp(80)
                          .copyWith(color: Colors.white10),
                    ),
                  ),
                  Positioned(
                    left: 20.w,
                    bottom: 0.04.sw,
                    child: Text(
                      '切换至深色主题',
                      overflow: TextOverflow.clip,
                      style: TextUtil.base.w400
                          .sp(18)
                          .copyWith(color: Colors.white60),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        GestureDetector(
          onVerticalDragEnd: (e) {
            if (canMove = true && e.velocity.pixelsPerSecond.distance > 10.w) {
              if (CommonPreferences.autoDarkTheme.value) {
                setState(() {
                  CommonPreferences.autoDarkTheme.value = false;
                });
              }

              if (e.velocity.pixelsPerSecond.direction < pi / 2) {
                canMove = false;
                shiftToLight();
              } else {
                canMove = false;
                shiftToDark();
              }
            }
          },
          child: AnimatedContainer(
            onEnd: () {
              canMove = true;
            },
            clipBehavior: Clip.hardEdge,
            margin: EdgeInsets.fromLTRB(
                5.w,
                globalTheme.value.meta.brightness == Brightness.light
                    ? 5.w
                    : 0.14.sw + 5.w,
                5.w,
                5.w),

            // 这个删了会报错
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.w),
                topRight: Radius.circular(10.w),
              ),
            ),

            height: 0.6.sw,
            width: 1.sw - 10.w,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInCubic,
            child: Stack(
              children: [
                ScheduleBackground(),
                Column(
                  children: [
                    Container(
                      height: 60.h,
                      margin:
                          EdgeInsets.only(left: 30.w, top: 10.h, bottom: 14.h),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'HELLO${(CommonPreferences.lakeNickname.value == '') ? '' : ', ${CommonPreferences.lakeNickname.value}'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextUtil.base.bright(context).w400.sp(22),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 1.sw,
                        decoration: BoxDecoration(
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.primaryBackgroundColor),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.w),
                            topRight: Radius.circular(30.w),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Spacer(),
                            Row(
                              children: [exampleCard, exampleCard2],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0.001.sw,
                  child: Icon(
                    Icons.drag_handle,
                    color: Colors.black.withOpacity(0.3),
                    size: 35.w,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    Widget autoDarkThemeSelect = Container(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
      decoration: BoxDecoration(
        color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('深色模式跟随系统'), SizedBox(height: 3.h), Text('默认开启')],
            ),
          ),
          Switch(
            value: CommonPreferences.autoDarkTheme.value,
            onChanged: (value) {
              CommonPreferences.autoDarkTheme.value = value;
              setState(() {
                if (CommonPreferences.autoDarkTheme.value &&
                    MediaQuery.platformBrightnessOf(context) ==
                        Brightness.dark) {
                  shiftToDark();
                } else {
                  shiftToLight();
                }
              });
            },
            activeColor:
                WpyTheme.of(context).get(WpyColorKey.oldSecondaryActionColor),
            inactiveThumbColor:
                WpyTheme.of(context).get(WpyColorKey.oldHintColor),
            activeTrackColor:
                WpyTheme.of(context).get(WpyColorKey.oldSwitchBarColor),
            inactiveTrackColor:
                WpyTheme.of(context).get(WpyColorKey.oldSwitchBarColor),
          ),
        ],
      ),
    );

    return Scaffold(
        appBar: AppBar(
          title: Text("主题设置",
              style: TextUtil.base.bold.sp(16).oldActionColor(context)),
          elevation: 0,
          centerTitle: true,
          backgroundColor:
              WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
          leading: Padding(
            padding: EdgeInsets.only(left: 15.w),
            child: WButton(
              child: Icon(Icons.arrow_back,
                  color: WpyTheme.of(context).get(WpyColorKey.oldActionColor),
                  size: 32),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
        body: ListView(
          children: [layout, autoDarkThemeSelect, gridView],
        ));
  }
}

class WpyThemeCard extends StatelessWidget {
  WpyThemeCard({
    super.key,
    required this.name,
    required this.primaryColor,
    required this.hintTextColor,
    this.selected = false,
  });

  final String name;
  final Color primaryColor;
  final Color hintTextColor;
  final bool selected;

  BorderSide getBorder(context) {
    if (!selected) return BorderSide.none;

    return BorderSide(
      color: Colors.white60,
      width: 4,
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(10.w);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: getBorder(context),
      ),
      elevation: 0,
      shadowColor: WpyTheme.of(context).get(WpyColorKey.basicTextColor),
      margin: EdgeInsets.all(5.w),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            color: primaryColor,
            width: double.infinity,
            height: double.infinity,
          ),
          Column(
            children: [
              Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.reverseBackgroundColor)
                      .withOpacity(0.3),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                alignment: Alignment.centerLeft,
                width: double.infinity,
                child: Text(
                  name,
                  style: TextStyle(
                    color: hintTextColor,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          if (selected)
            Center(
              child: Icon(
                Icons.check_circle,
                color: Colors.white60,
                size: 30.w,
              ),
            )
        ],
      ),
    );
  }
}

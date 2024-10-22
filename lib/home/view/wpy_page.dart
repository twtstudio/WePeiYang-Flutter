import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:we_pei_yang_flutter/auth/model/nacid_info.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/time.util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/colored_icon.dart';
import 'package:we_pei_yang_flutter/commons/widgets/scroll_synchronizer.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/gpa/view/gpa_curve_detail.dart';
import 'package:we_pei_yang_flutter/message/feedback_message_page.dart';
import 'package:we_pei_yang_flutter/schedule/view/wpy_course_widget.dart';
import 'package:we_pei_yang_flutter/schedule/view/wpy_exam_widget.dart';
import 'package:we_pei_yang_flutter/studyroom/view/widget/main_page_widget.dart';

import 'dialogs/acid_check_dialog.dart';
import 'dialogs/activity_dialog.dart';
import 'map_calendar_page.dart';

class WPYPage extends StatefulWidget {
  @override
  WPYPageState createState() => WPYPageState();
}

class WPYPageState extends State<WPYPage> with SingleTickerProviderStateMixin {
  ValueNotifier<bool> showSchedule = ValueNotifier(true);
  ValueNotifier<bool> useRound = ValueNotifier(true);

  final ScrollController _sc = ScrollController();
  late final TabController _tc;

  String md = '';

  ValueNotifier<DateTime> _now = ValueNotifier(DateTime.now());
  Future<NAcidInfo> acidInfo = AuthService.checkNuclearAcid();
  bool hasShow = false;

  void showActivityDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ActivityDialog(),
    );
  }

  void showAcidCheckDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AcidCheckDialog(acidInfo, _now);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 3, vsync: this);
    //隐私政策部分挪到了app一打开就会显示的部分（login_page.dart里面
    // if (CommonPreferences.firstPrivacy.value == true) {
    //   rootBundle.loadString('privacy/privacy_content.md').then((str) {
    //     setState(() {
    //       md = str;
    //     });
    //   });
    // }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // if (CommonPreferences.firstPrivacy.value == true) {
      //   showDialog(
      //       context: context,
      //       barrierDismissible: false,
      //       builder: (BuildContext context) {
      //         return PrivacyDialog(md);
      //       });
      //   CommonPreferences.firstPrivacy.value = false;
      // }
      var info = await acidInfo;
      if (info.id != -1 &&
          hasShow == false &&
          info.endTime != null &&
          DateTime.now().isBefore(info.endTime!.add(Duration(hours: 1)))) {
        showAcidCheckDialog();
        hasShow = true;
      }

      var _show = () {
        showActivityDialog();
        CommonPreferences.lastActivityDialogShownDate.value =
            DateTime.now().toString();
      };

      try {
        final lastDate =
            DateTime.parse(CommonPreferences.lastActivityDialogShownDate.value);
        if (!lastDate.isSameDay(DateTime.now())) _show();
      } catch (_) {
        _show();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _sc.addListener(() {
      if (_sc.position.maxScrollExtent - _sc.offset < 20.h &&
          showSchedule.value == true) showSchedule.value = false;
      if (_sc.position.maxScrollExtent - _sc.offset > 20.1.h &&
          showSchedule.value == false) showSchedule.value = true;
    });

    return Provider<ScrollSynchronizer>(
      create: (_) => ScrollSynchronizer.fromExist(_sc),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ListenableBuilder(
              listenable: showSchedule,
              builder: (context, _) {
                return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    decoration: BoxDecoration(
                        gradient: WpyTheme.of(context).getGradient(
                            showSchedule.value && !Platform.isWindows
                                ? WpyColorSetKey.primaryGradient
                                : WpyColorSetKey.gradientPrimaryBackground)));
              }),
          SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 70.h),
                  child: ListenableBuilder(
                    listenable: useRound,
                    builder: (context, oldChild) {
                      return ClipRRect(
                        borderRadius: useRound.value
                            ? BorderRadius.only(
                                topLeft: Radius.circular(40.r),
                                topRight: Radius.circular(40.r))
                            : BorderRadius.zero,
                        child: oldChild!,
                      );
                    },
                    child: ScrollConfiguration(
                      behavior: WPYScrollBehavior(),
                      child: ListView(
                        controller: _sc,
                        children: <Widget>[
                          TodayCoursesWidget(),
                          AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                              margin: EdgeInsets.only(top: 20.h),
                              padding: EdgeInsets.only(top: 40.h),
                              decoration: BoxDecoration(
                                  color: WpyTheme.of(context)
                                      .get(WpyColorKey.primaryBackgroundColor),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(40.r),
                                      topRight: Radius.circular(40.r))),
                              child: _functionCardsView()),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 60.h,
                  margin: EdgeInsets.only(left: 30.w, top: 10.h),
                  alignment: Alignment.centerLeft,
                  child: ListenableBuilder(
                      listenable: showSchedule,
                      builder: (context, lastChild) {
                        return AnimatedDefaultTextStyle(
                          style: showSchedule.value && !Platform.isWindows
                              ? TextUtil.base.bright(context).w400.sp(22)
                              : TextUtil.base.primary(context).w400.sp(22),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                          onEnd: () => useRound.value = showSchedule.value,
                          child: SizedBox(
                            width: 1.sw - 60.w,
                            child: Text(
                              'HELLO${(CommonPreferences.lakeNickname.value == '') ? '' : ', ${CommonPreferences.lakeNickname.value}'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _functionCardsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 功能跳转卡片
        SliverCardsWidget(CommonPreferences.displayedTool.value),
        if (CommonPreferences.showMap.value) MapAndCalender(),
        Padding(
          padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, 0),
          child: TabBar(
              controller: _tc,
              dividerHeight: 0,
              labelStyle: TextUtil.base.w400.sp(14),
              labelPadding: EdgeInsets.zero,
              labelColor: WpyTheme.of(context).get(WpyColorKey.basicTextColor),
              unselectedLabelColor:
                  WpyTheme.of(context).get(WpyColorKey.secondaryTextColor),
              indicator: CustomIndicator(
                  left: true,
                  borderSide: BorderSide(
                      color: WpyTheme.of(context).get(WpyColorKey.warningColor),
                      width: 4)),
              tabs: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Tab(text: 'Study Room')),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Tab(text: 'GPA Curves')),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Tab(text: 'Exam Detail')),
              ]),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height - 365.h,
          child: TabBarView(
              controller: _tc,
              physics: BouncingScrollPhysics(),
              children: [
                // Container(
                //   width: 1.sw - 60.w,
                //   height: 300.h,
                //   child: MainPageStudyRoomWidget(),
                // ),
                Container(
                  width: 1.sw - 60.w,
                  height: 300.h,
                  child: MainPageStudyRoomWidget(),
                ),
                Container(
                  width: 1.sw - 60.w,
                  height: 300.h,
                  child: GPAPreview(),
                ),
                Container(
                  width: 1.sw - 60.w,
                  height: 300.h,
                  child: WpyExamWidget(),
                ),
              ]),
        ),
      ],
    );
  }
}

class SliverCardsWidget extends StatelessWidget {
  final List<CardBean> cards;
  final ScrollController controller = ScrollController();
  static List<String> peiyangLabel = [
    '课程表',
    '入校码',
    '新闻网',
    '地图·校历',
    '成绩',
    // '小游戏'
    // '失物招领'
  ];

  SliverCardsWidget(this.cards);

  @override
  Widget build(BuildContext context) {
    Widget cardList = ReorderableListView.builder(
      proxyDecorator: (Widget child, int index, Animation<double> animation) {
        return child;
      },
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(left: 16.h),
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      itemCount: CommonPreferences.displayedTool.value.length,
      itemBuilder: (context, i) {
        if (!peiyangLabel
            .contains(CommonPreferences.displayedTool.value[i].label)) {
          return WButton(
            key: ValueKey(CommonPreferences.displayedTool.value[i].route),
            onPressed: () async {
              if (await canLaunchUrl(
                  Uri.parse(CommonPreferences.displayedTool.value[i].route))) {
                await launchUrl(
                    Uri.parse(CommonPreferences.displayedTool.value[i].route),
                    mode: LaunchMode.externalApplication);
              } else {
                ToastProvider.error('请检查网络状态');
              }
            },
            child:
                generateCard(context, CommonPreferences.displayedTool.value[i]),
          );
        } else {
          return WButton(
            key: ValueKey(CommonPreferences.displayedTool.value[i].route),
            onPressed: () {
              Navigator.pushNamed(
                  context, CommonPreferences.displayedTool.value[i].route);
            },
            child:
                generateCard(context, CommonPreferences.displayedTool.value[i]),
          );
        }
      },
      onReorder: (int oldIndex, int newIndex) {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final CardBean item =
            CommonPreferences.displayedTool.value.removeAt(oldIndex);
        CommonPreferences.displayedTool.value.insert(newIndex, item);
      },
    );

    return SizedBox(
      height: 100.h,
      width: double.infinity,
      child: cardList,
    );
  }

  Widget generateCard(BuildContext context, CardBean bean) {
    return Container(
      width: 150.w,
      height: 80.h,
      margin: EdgeInsets.fromLTRB(0, 2.h, 18.h, 16.h),
      decoration: MapAndCalenderState().cardDecoration(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(width: 8.w),
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
                    color: bean.label == '地图·校历'
                        ? WpyTheme.of(context).get(WpyColorKey.beanLightColor)
                        : WpyTheme.of(context).get(WpyColorKey.beanDarkColor),
                  ),
                ),
              ),
              ColoredIcon(
                bean.path,
                color: WpyTheme.of(context).primary,
                width: bean.width,
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
    );
  }
}

class CardBean {
  String path;
  double? width;
  String label;
  String eng;
  String route;

  CardBean(this.path, this.width, this.label, this.eng, this.route);
}

class WPYScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return GlowingOverscrollIndicator(
      child: child,
      showLeading: false,
      showTrailing: false,
      axisDirection: AxisDirection.down,
      color: WpyTheme.of(context).get(WpyColorKey.defaultActionColor),
    );
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return ClampingScrollPhysics();
  }
}

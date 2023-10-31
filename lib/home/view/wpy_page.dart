import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:we_pei_yang_flutter/auth/model/nacid_info.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/auth/view/privacy/privacy_dialog.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/time.util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/gpa/view/gpa_curve_detail.dart';
import 'package:we_pei_yang_flutter/home/view/dialogs/acid_check_dialog.dart';
import 'package:we_pei_yang_flutter/home/view/dialogs/activity_dialog.dart';
import 'package:we_pei_yang_flutter/home/view/map_calender_page.dart';
import 'package:we_pei_yang_flutter/message/feedback_message_page.dart';
import 'package:we_pei_yang_flutter/schedule/view/wpy_course_widget.dart';
import 'package:we_pei_yang_flutter/schedule/view/wpy_exam_widget.dart';
import 'package:we_pei_yang_flutter/studyroom/view/widget/main_page_widget.dart';

class WPYPage extends StatefulWidget {
  @override
  WPYPageState createState() => WPYPageState();
}

class WPYPageState extends State<WPYPage> with SingleTickerProviderStateMixin {
  bool showSchedule = true;
  bool useRound = true;

  final ScrollController _sc = ScrollController();
  late final TabController _tc;

  final List<CardBean> cards = [
    CardBean(
        Image.asset(
          'assets/svg_pics/lake_butt_icons/daily.png',
          width: 24.w,
        ),
        '课程表',
        'Schedule',
        ScheduleRouter.course),
    CardBean(
        Image.asset(
          'assets/images/schedule/add.png',
          width: 24.w,
        ),
        '地图·校历',
        'Map-\nCalender',
        HomeRouter.mapCalenderPage),
    CardBean(
        Image.asset(
          'assets/svg_pics/lake_butt_icons/wiki.png',
          width: 24.w,
        ),
        '北洋维基',
        'Wiki',
        'https://wiki.tjubot.cn/'),
    CardBean(Icon(Icons.timeline, size: 25), '成绩', 'GPA', GPARouter.gpa),

  ];
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
    if (CommonPreferences.firstPrivacy.value == true) {
      rootBundle.loadString('privacy/privacy_content.md').then((str) {
        setState(() {
          md = str;
        });
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (CommonPreferences.firstPrivacy.value == true) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return PrivacyDialog(md);
            });
        CommonPreferences.firstPrivacy.value = false;
      }
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      systemNavigationBarColor: Colors.white,
    ));
    _sc.addListener(() {
      if (_sc.position.maxScrollExtent - _sc.offset < 20.h &&
          showSchedule == true)
        setState(() {
          showSchedule = false;
        });
      if (_sc.position.maxScrollExtent - _sc.offset > 20.1.h &&
          showSchedule == false)
        setState(() {
          showSchedule = true;
        });
    });
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeIn,
            decoration: BoxDecoration(
                gradient: showSchedule && !Platform.isWindows
                    ? LinearGradient(
                        colors: [
                          Color(0xFF2C7EDF),
                          Color(0xFFA6CFFF),
                          // 用来挡下面圆角左右的空
                          Colors.white
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        // 在0.7停止同理
                        stops: [0, 0.53, 0.7])
                    : LinearGradient(colors: [Colors.white, Colors.white]))),
        SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 70.h),
                child: ClipRRect(
                  borderRadius: useRound
                      ? BorderRadius.only(
                          topLeft: Radius.circular(40.r),
                          topRight: Radius.circular(40.r))
                      : BorderRadius.zero,
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
                                color: Colors.white,
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
                child: AnimatedDefaultTextStyle(
                  style: showSchedule && !Platform.isWindows
                      ? TextUtil.base.white.w400.sp(22)
                      : TextUtil.base.black00.w400.sp(22),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  onEnd: () => setState(() => useRound = showSchedule),
                  child: SizedBox(
                    width: 1.sw - 60.w,
                    child: Text(
                      'HELLO${(CommonPreferences.lakeNickname.value == '') ? '' : ', ${CommonPreferences.lakeNickname.value}'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _functionCardsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 功能跳转卡片
        SliverCardsWidget(cards),
        if (CommonPreferences.showMap.value) MapAndCalender(),
        Padding(
          padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, 0),
          child: TabBar(
              controller: _tc,
              labelStyle: TextUtil.base.w400.sp(14),
              labelPadding: EdgeInsets.zero,
              labelColor: Colors.black,
              unselectedLabelColor: ColorUtil.lightTextColor,
              indicator: CustomIndicator(
                  left: true,
                  borderSide: BorderSide(color: ColorUtil.warning, width: 4)),
              tabs: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Tab(text: 'GPA Curves')),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Tab(text: 'Exam Detail')),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Tab(text: 'Coming Soon')),
              ]),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height - 370.h,
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
                  child: GPAPreview(),
                ),
                Container(
                  width: 1.sw - 60.w,
                  height: 300.h,
                  child: WpyExamWidget(),
                ),
                Container(
                  width: 1.sw - 60.w,
                  height: 300.h,
                  child: Image.asset("assets/images/schedule_empty.png"),
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

  SliverCardsWidget(this.cards);

  @override
  Widget build(BuildContext context) {
    Widget cardList = ListView.builder(
      controller: controller,
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(left: 16.h),
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      itemCount: cards.length,
      itemBuilder: (context, i) {
        if (cards[i].label == '北洋维基') {
          return GestureDetector(
            onTap: () async {
              if (await canLaunchUrl(Uri.parse(cards[i].route))) {
                await launchUrl(Uri.parse(cards[i].route),
                    mode: LaunchMode.externalApplication);
              } else {
                ToastProvider.error('请检查网络状态');
              }
            },
            child: generateCard(context, cards[i]),
          );
        } else {
          return GestureDetector(
            onTap: () {
              ///为预热失物招领添加了if条件，上线后去掉即可
              if(cards[i].route==""){
                ToastProvider.error('开发中 敬请期待！');
              }else{
                Navigator.pushNamed(context, cards[i].route);
              }
            },
            child: generateCard(context, cards[i]),
          );
        }
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
      decoration: MapAndCalenderState().cardDecoration,
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
                        ? Color(0xFF2887FF)
                        : Color(0xFF80B7F9),
                  ),
                ),
              ),
              bean.icon
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
                    style: TextUtil.base.w500.black2A.sp(12).w400,
                    overflow: TextOverflow.ellipsis),
              ),
              SizedBox(
                width: 70.w,
                child: Text(bean.label,
                    maxLines: 2,
                    style: TextUtil.base.w400.black2A.sp(12).medium),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class CardBean {
  Widget icon;
  String label;
  String eng;
  String route;

  CardBean(this.icon, this.label, this.eng, this.route);
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
      color: ColorUtil.mainColor,
    );
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return ClampingScrollPhysics();
  }
}

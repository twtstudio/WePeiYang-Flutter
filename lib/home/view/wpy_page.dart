import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart'
    show SystemChrome, SystemUiOverlayStyle, rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:we_pei_yang_flutter/auth/view/privacy/agreement_and_privacy_dialog.dart';

import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/april_fool_dialog.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/gpa/view/gpa_curve_detail.dart';
import 'package:we_pei_yang_flutter/lounge/main_page_widget.dart';

import 'package:we_pei_yang_flutter/message/feedback_message_page.dart';
import 'package:we_pei_yang_flutter/schedule/view/wpy_course_widget.dart';
import 'package:we_pei_yang_flutter/schedule/view/wpy_exam_widget.dart';

const _APRIL_FOOL_LABEL = '愚人节模式？';

class WPYPage extends StatefulWidget {
  @override
  WPYPageState createState() => WPYPageState();
}

class WPYPageState extends State<WPYPage> with SingleTickerProviderStateMixin {
  bool showSchedule = true;
  bool useRound = true;

  ScrollController _sc = ScrollController();
  TabController _tc;

  List<CardBean> cards;
  var md = '';
  dynamic result;

  Future<String> _loadFromAssets() async {
    String filePath = 'privacy/privacy_content.md';
    String fileContents = await rootBundle.loadString(filePath);
    return fileContents;
  }

  void setAsserts() async {
    result = await _loadFromAssets();
    setState(() {
      md = result.toString();
    });
  }

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 3, vsync: this);

    if (CommonPreferences.isFirstUse.value == true) setAsserts();
    cards = [
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
            'assets/svg_pics/lake_butt_icons/wiki.png',
            width: 24.w,
          ),
          '北洋维基',
          'Wiki',
          'https://wiki.tjubot.cn/'),
      CardBean(Icon(Icons.timeline, size: 25), 'GPA', 'GPA', GPARouter.gpa),
      CardBean(
          Image.asset(
            'assets/svg_pics/lake_butt_icons/self_study.png',
            width: 24.w,
          ),
          S.current.lounge,
          'Study',
          LoungeRouter.main),
      CardBean(Icon(Icons.domain, size: 25), '楼宇牌', 'BuildingCard',
          ReportRouter.pass),
      CardBean(Icon(Icons.report, size: 25), S.current.report, 'Health',
          ReportRouter.main),
      CardBean(Icon(Icons.refresh, size: 25), '重开模拟器', 'RestartGame',
          HomeRouter.restartGame),
    ];
    if (DateTime.now().month == 4 && DateTime.now().day == 1) {
      cards.insert(
          0,
          CardBean(
              Image.asset(
                'assets/images/lake_butt_icons/joker_stamp.png',
                width: 30,
              ),
              _APRIL_FOOL_LABEL,
              'fool'));
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (CommonPreferences.isFirstUse.value == true) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AgreementAndPrivacyDialog(md);
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      systemNavigationBarColor: Colors.white,
    ));
    _sc.addListener(() {
      if (_sc.offset > 200 + 24.h && showSchedule == true)
        setState(() {
          showSchedule = false;
        });
      if (_sc.offset < 200 + 20.h && showSchedule == false)
        setState(() {
          showSchedule = true;
        });
    });
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedContainer(
            duration: Duration(milliseconds: 800),
            curve: Curves.easeIn,
            decoration: BoxDecoration(
                gradient: showSchedule
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
        if (CommonPreferences.isSkinUsed.value)
          Image.network(CommonPreferences.skinMain.value, fit: BoxFit.fitWidth),
        SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 70.h),
                child: ClipRRect(
                  borderRadius: useRound
                      ? BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                          topRight: Radius.circular(20.r))
                      : BorderRadius.zero,
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    controller: _sc,
                    children: <Widget>[
                      TodayCoursesWidget(),
                      AnimatedContainer(
                          duration: Duration(milliseconds: 800),
                          curve: Curves.easeIn,
                          height: MediaQuery.of(context).size.height,
                          margin: EdgeInsets.only(top: 30.h),
                          padding: EdgeInsets.only(top: 50.h),
                          decoration: BoxDecoration(
                              color: Color(0xFFF1F4FB),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(40.r),
                                  topRight: Radius.circular(40.r))),
                          child: _functionCardsView()),
                    ],
                  ),
                ),
              ),
              SafeArea(
                  child: Padding(
                padding: EdgeInsets.only(left: 30.w, top: 10.h),
                child: SizedBox(
                  height: 60.h,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedOpacity(
                      opacity: showSchedule ? 1 : 0,
                      duration: Duration(milliseconds: 800),
                      curve: Curves.easeIn,
                      onEnd: () => setState(() => useRound = showSchedule),
                      child: Text('HELLO, ${CommonPreferences.nickname.value}',
                          style: TextUtil.base.white.w900.sp(22)),
                    ),
                  ),
                ),
              )),
              SafeArea(
                  child: Padding(
                padding: EdgeInsets.only(left: 30.w, top: 10.h),
                child: SizedBox(
                  height: 60.h,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedOpacity(
                      opacity: showSchedule ? 0 : 1,
                      duration: Duration(milliseconds: 800),
                      curve: Curves.easeIn,
                      child: Text('HELLO, ${CommonPreferences.nickname.value}',
                          style: TextUtil.base.black00.w900.sp(22)),
                    ),
                  ),
                ),
              ))
            ],
          ),
        ),
      ],
    );
  }

  Widget _functionCardsView() {
    return Column(
      children: [
        /// 功能跳转卡片
        SliverCardsWidget(cards),
        SizedBox(height: 30.w),
        Padding(
          padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, 0),
          child: TabBar(
              controller: _tc,
              labelStyle: TextUtil.base.w900.sp(14),
              labelPadding: EdgeInsets.zero,
              labelColor: Colors.black,
              unselectedLabelColor: ColorUtil.lightTextColor,
              indicator: CustomIndicator(
                  left: true,
                  borderSide: BorderSide(color: ColorUtil.warning, width: 4)),
              tabs: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Tab(text: 'GPA Curve')),
                Align(
                    alignment: Alignment.centerLeft, child: Tab(text: 'Exam')),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Tab(text: 'Study Room'))
              ]),
        ),
        SizedBox(
          height: 0.7.sh,
          child: TabBarView(
              controller: _tc,
              physics: BouncingScrollPhysics(),
              children: [
                Container(
                  width: 1.sw - 70.w,
                  height: 250.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    // border: Border.all(),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 4),
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
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
                  child: MainPageLoungeWidget(),
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
      padding: const EdgeInsets.only(left: 15),
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      itemCount: cards.length,
      itemBuilder: (context, i) {
        if (cards[i].label == 'Wiki') {
          return GestureDetector(
            onTap: () async {
              if (await canLaunch(cards[i].route)) {
                await launch(cards[i].route);
              } else {
                ToastProvider.error('请检查网络状态');
              }
            },
            child: generateCard(context, cards[i]),
          );
        } else {
          return GestureDetector(
            onTap: () async {
              if (cards[i].label == _APRIL_FOOL_LABEL) {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AprilFoolDialog(
                        content: '要体验愚人节模式吗？',
                        confirmText: '好耶',
                        cancelText: '坏耶',
                        confirmFun: () {
                          CommonPreferences.isAprilFool.value = true;
                          CommonPreferences.isAprilFoolLike.value = true;
                          CommonPreferences.isAprilFoolGPA.value = true;
                          CommonPreferences.isAprilFoolClass.value = true;
                          CommonPreferences.isAprilFoolHead.value = true;
                          Navigator.popAndPushNamed(context, HomeRouter.home);
                        },
                      );
                    });
              } else {
                return Navigator.pushNamed(context, cards[i].route);
              }
            },
            child: generateCard(context, cards[i]),
          );
        }
      },
    );

    return SizedBox(
      height: 100,
      width: double.infinity,
      child: cardList,
    );
  }

  Widget generateCard(BuildContext context, CardBean bean, {Color textColor}) {
    return Container(
      width: 150.w,
      height: 80.h,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        // border: Border.all(),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 10,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
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
                    color: Color(0xFF80B7F9),
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
              Text(bean.eng,
                  maxLines: 2, style: TextUtil.base.w500.black2A.sp(12).bold),
              Text(bean.label,
                  maxLines: 2, style: TextUtil.base.w400.black2A.sp(12).medium),
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

  CardBean(this.icon, this.label, this.eng, [this.route]);
}

class WPYScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return GlowingOverscrollIndicator(
      child: child,
      showLeading: false,
      showTrailing: true,
      axisDirection: AxisDirection.down,
      color: ColorUtil.mainColor,
    );
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return ClampingScrollPhysics();
  }
}

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart'
    show SystemChrome, SystemUiOverlayStyle, rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:we_pei_yang_flutter/auth/model/banner_pic.dart';
import 'package:we_pei_yang_flutter/auth/network/theme_service.dart';
import 'package:we_pei_yang_flutter/auth/view/privacy/agreement_and_privacy_dialog.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/april_fool_dialog.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/gpa/view/gpa_curve_detail.dart';
import 'package:we_pei_yang_flutter/home/view/web_views/festival_page.dart';
import 'package:we_pei_yang_flutter/lounge/main_page_widget.dart';
import 'package:we_pei_yang_flutter/message/feedback_message_page.dart';
import 'package:we_pei_yang_flutter/schedule/view/wpy_course_widget.dart';
import 'package:we_pei_yang_flutter/schedule/view/wpy_exam_widget.dart';

import '../../lounge/main_page_widget.dart';

const _APRIL_FOOL_LABEL = '愚人节模式？';

class WPYPage extends StatefulWidget {
  @override
  WPYPageState createState() => WPYPageState();
}

class WPYPageState extends State<WPYPage> with SingleTickerProviderStateMixin {
  bool showSchedule = true;
  bool useRound = true;

  ScrollController _sc = ScrollController();
  SwiperController _swc = SwiperController();
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

  ///此数组是假的 List 应该被删掉
  List<String> waterGod = [
    'https://pic.imgdb.cn/item/630f543316f2c2beb1ce122f.jpg',
    'https://pic.imgdb.cn/item/630f57e016f2c2beb1d01b51.jpg'
  ];

  Widget get activityDialog => FutureBuilder(
        future: ThemeService.getBanner(),
        builder: (context, AsyncSnapshot<List<BannerPic>> snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                Spacer(),
                Swiper(
                  controller: _swc,
                  layout: SwiperLayout.TINDER,
                  loop: true,
                  autoplay: true,
                  autoplayDelay: 4000,
                  itemWidth: 0.81.sw,
                  itemHeight: 1.08.sw,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (snapshot.data.length == 0) return SizedBox();
                    return ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, FeedbackRouter.haitang,
                              arguments:
                                  FestivalArgs(snapshot.data[index].url, '活动'));
                        },
                        child: WpyPic(
                          snapshot.data[index].picUrl,
                          fit: BoxFit.cover,
                          withHolder: true,
                        ),
                      ),
                    );
                  },
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: SizedBox(
                      width: 1.sw,
                      height: 0.55.sh - 0.54.sw,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Image.asset(
                          'assets/images/lake_butt_icons/x.png',
                          width: 50.w,
                          height: 100.w,
                          color: Colors.white70,
                        ),
                      ),
                    ))
              ],
            );
          } else {
            return Loading();
          }
        },
      );

  void showHomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => activityDialog,
    );
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
      int showYearMonthDay = int.parse(
          '${DateTime.now().toLocal().toIso8601String().substring(0, 4)}${DateTime.now().toLocal().toIso8601String().substring(5, 7)}${DateTime.now().toLocal().toIso8601String().substring(8, 10)}');
      if (CommonPreferences.lastShownYearMonthDay.value < showYearMonthDay) {
        showHomeDialog();
        CommonPreferences.lastShownYearMonthDay.value = showYearMonthDay;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      systemNavigationBarColor: Colors.white,
    ));
    _sc.addListener(() {
      if (_sc.position.maxScrollExtent - _sc.offset < 30.h &&
          showSchedule == true)
        setState(() {
          showSchedule = false;
        });
      if (_sc.position.maxScrollExtent - _sc.offset > 30.1.h &&
          showSchedule == false)
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
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeIn,
                            height: MediaQuery.of(context).size.height - 160.h,
                            margin: EdgeInsets.only(top: 20.h),
                            padding: EdgeInsets.only(top: 40.h),
                            decoration: BoxDecoration(
                                color: Color(0xEAFFFFFF),
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
                  style: showSchedule
                      ? TextUtil.base.white.w400.sp(22)
                      : TextUtil.base.black00.w400.sp(22),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeIn,
                  onEnd: () => setState(() => useRound = showSchedule),
                  child: SizedBox(
                    width: 1.sw - 60.w,
                    child: Text(
                      'HELLO, ${CommonPreferences.lakeNickname.value}',
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
      children: [
        /// 功能跳转卡片
        SliverCardsWidget(cards),
        SizedBox(height: 10.w),
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
                    child: Tab(text: 'Study Room')),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Tab(text: 'Exam Detail')),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Tab(text: 'GPA Curves')),
              ]),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height - 362.h,
          child: TabBarView(
              controller: _tc,
              physics: BouncingScrollPhysics(),
              children: [
                Container(
                  width: 1.sw - 60.w,
                  height: 300.h,
                  child: MainPageLoungeWidget(),
                ),
                Container(
                  width: 1.sw - 60.w,
                  height: 300.h,
                  child: WpyExamWidget(),
                ),
                Container(
                  width: 1.sw - 60.w,
                  height: 300.h,
                  child: GPAPreview(),
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
        if (cards[i].label == '北洋维基') {
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
      height: 100.h,
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

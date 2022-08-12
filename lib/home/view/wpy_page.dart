import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show SystemChrome, SystemUiOverlayStyle, rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:we_pei_yang_flutter/auth/view/privacy/agreement_and_privacy_dialog.dart';

import 'package:we_pei_yang_flutter/auth/view/user/user_avatar_image.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/april_fool_dialog.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/gpa/view/gpa_curve_detail.dart';
import 'package:we_pei_yang_flutter/home/poster_girl/poster_girl_based_widget.dart';

import 'package:we_pei_yang_flutter/lounge/main_page_widget.dart';
import 'package:we_pei_yang_flutter/schedule/view/wpy_course_widget.dart';
import 'package:we_pei_yang_flutter/schedule/view/wpy_exam_widget.dart';

import '../../commons/util/text_util.dart';
import '../../message/feedback_message_page.dart';

final hintStyle = const TextStyle(
    fontSize: 16,
    color: Color.fromRGBO(53, 59, 84, 1),
    fontWeight: FontWeight.bold);

class WPYPage extends StatefulWidget {
  @override
  WPYPageState createState() => WPYPageState();
}

class WPYPageState extends State<WPYPage> with SingleTickerProviderStateMixin {
  GlobalKey<ErCiYuanWidgetState> erCiYuanKey = GlobalKey();
  GlobalKey majorColumnHeightKey = GlobalKey();
  bool showSchedule = true;
  bool useRound = true;

  ScrollController _sc = ScrollController();
  TabController _tc;

  List<CardBean> cards;
  var md = "";
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

    if (CommonPreferences().isFirstUse.value == true) setAsserts();
    cards = []
      ..add(DateTime.now().month == 4 && DateTime.now().day == 1
          ? CardBean(
              Image.asset(
                'assets/images/lake_butt_icons/joker_stamp.png',
                width: 30,
              ),
              '愚人节模式？',
              "fool")
          : null)
      ..add(CardBean(
          Image.asset(
            "assets/svg_pics/lake_butt_icons/daily.png",
            width: 24.w,
          ),
          '课程表',
          "Exam",
          ScheduleRouter.schedule))
      ..add(CardBean(
          Image.asset(
            "assets/svg_pics/lake_butt_icons/wiki.png",
            width: 24.w,
          ),
          "北洋维基",
          'Wiki',
          'https://wiki.tjubot.cn/'))
      ..add(
          CardBean(Icon(Icons.timeline, size: 25), 'GPA', "GPA", GPARouter.gpa))
      ..add(CardBean(
          Image.asset(
            "assets/svg_pics/lake_butt_icons/self_study.png",
            width: 24.w,
          ),
          S.current.lounge,
          "Study",
          LoungeRouter.main))
      ..add(CardBean(Icon(Icons.domain, size: 25), '楼宇牌', "BuildingCard",
          ReportRouter.pass))
      ..add(CardBean(Icon(Icons.report, size: 25), S.current.report, "Health",
          ReportRouter.main))
      ..add(CardBean(Icon(Icons.refresh, size: 25), "重开模拟器", "RestartGame",
          HomeRouter.restartGame));

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (CommonPreferences().isFirstUse.value == true) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AgreementAndPrivacyDialog(md);
            });
      }
    });
  }

  double _getWidgetHeight(context) {
    final listHeight = majorColumnHeightKey.currentContext
        .findRenderObject()
        .semanticBounds
        .size
        .height;
    return listHeight;
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
        if (CommonPreferences().isSkinUsed.value)
          Image.network(CommonPreferences().skinMain.value,
              fit: BoxFit.fitWidth),
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
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    controller: _sc,
                    children: <Widget>[
                      /// 上半部分，把课表装进去
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 30.w),
                          height: 200,
                          color: Colors.black12,
                          child: Text('课表')),

                      AnimatedContainer(
                          duration: Duration(milliseconds: 800),
                          curve: Curves.easeIn,
                          height: MediaQuery.of(context).size.height,
                          margin: EdgeInsets.only(top: 30.h),
                          padding: EdgeInsets.only(top: 50.h),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(40.r),
                                  topRight: Radius.circular(40.r))),
                          child: FunctionCardsView()),
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
                      child: Text(
                          'HELLO, ${CommonPreferences().nickname.value}',
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
                      child: Text(
                          'HELLO, ${CommonPreferences().nickname.value}',
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

  Widget FunctionCardsView() {
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
          height: 0.6.sh,
          width: 1.sw - 60.w,
          child: TabBarView(controller: _tc, children: [
            Container(
              width: 1.sw - 60.w,
              height: 300.h,
              child: GPAPreview(),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, 0),
              width: 1.sw - 60.w,
              height: 300.h,
              child: WpyExamWidget(),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(8.w, 0, 0, 0),
              width: 1.sw - 60.w,
              height: 300.h,
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.all(Radius.circular(30.sp)),
                  image: DecorationImage(
                      image: AssetImage('assets/images/chouniuzi.jpg'), fit: BoxFit.cover)),
              child: Text('臭牛子快点给我写完写不完我要鲨了你啊啊啊啊啊啊啊啊啊啊啊啊啊', style: TextUtil.base.white.w900.sp(60)),
            ),
          ]),
        ),
      ],
    );
  }

  List<Widget> toolCards = [
    TodayCoursesWidget(),
    WpyExamWidget(),
    GPAPreview(),
    MainPageLoungeWidget(),
  ];
}

///替代appbar使用
class _WPYHeader extends SliverPersistentHeaderDelegate {
  /// 让WPYPage进行重绘的回调
  final ValueChanged<void> onChanged;

  const _WPYHeader({this.onChanged});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    DateTime now = DateTime.now();
    double distance = maxExtent - minExtent;
    if (shrinkOffset > distance) shrinkOffset = distance;
    return Container(
      // 比其他区域rgb均高了一些,遮挡后方滚动区域
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.fromLTRB(30, 0, 10, 0),
      child: Column(
        children: [
          Row(
            children: <Widget>[
              Text(_getGreetText,
                  style: FontManager.YaQiHei.copyWith(
                      fontSize: 24,
                      color: MyColors.deepBlue,
                      fontWeight: FontWeight.bold)),
              SizedBox(width: 5),
              Expanded(
                  child: Text(
                CommonPreferences().nickname.value,
                style: hintStyle,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              )),
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, AuthRouter.userInfo).then((_) {
                  onChanged(null);
                }),
                child: Container(
                  margin: const EdgeInsets.only(left: 7, right: 10),
                  decoration: CommonPreferences().isAprilFoolHead.value
                      ? BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/images/lake_butt_icons/jokers.png'),
                            fit: BoxFit.cover,
                          ),
                        )
                      : BoxDecoration(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: UserAvatarImage(size: 30),
                  ),
                ),
              )
            ],
          ),
          if (distance - shrinkOffset > 10)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  "${now.month}月${now.day}日 ${_chineseWeekDay(now.weekday)}",
                  style: FontManager.YaQiHei.copyWith(
                      color: Color.fromRGBO(114, 119, 138, 1),
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            )
        ],
      ),
    );
  }

  @override
  double get maxExtent => 66;

  @override
  double get minExtent => 49;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  String get _getGreetText {
    int hour = DateTime.now().hour;
    if (hour < 5)
      return '晚上好!';
    else if (hour >= 5 && hour < 12)
      return '早上好';
    else if (hour >= 12 && hour < 14)
      return '中午好';
    else if (hour >= 12 && hour < 17)
      return '下午好';
    else if (hour >= 17 && hour < 19)
      return '傍晚好';
    else
      return '晚上好';
  }

  String _chineseWeekDay(int weekday) {
    switch (weekday) {
      case 1:
        return "周一";
      case 2:
        return "周二";
      case 3:
        return "周三";
      case 4:
        return "周四";
      case 5:
        return "周五";
      case 6:
        return "周六";
      default:
        return "周日";
    }
  }
}

class SliverCardsWidget extends StatelessWidget {
  final List<CardBean> cards;
  final ScrollController controller = ScrollController();
  int itemCount = 0;

  SliverCardsWidget(this.cards);

  @override
  Widget build(BuildContext context) {
    Widget cardList = ListView.builder(
      controller: controller,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 15, top: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: cards.length,
      itemBuilder: (context, i) {
        if (itemCount < i) itemCount = i;
        if (cards[i] == null) {
          return SizedBox();
        } else if (cards[i].label == 'Wiki') {
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
        } else if (cards[i].label == '愚人节模式？') {
          return GestureDetector(
            onTap: () async {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AprilFoolDialog(
                      content: "要体验愚人节模式吗？",
                      confirmText: "好耶",
                      cancelText: "坏耶",
                      confirmFun: () {
                        CommonPreferences().isAprilFool.value = true;
                        CommonPreferences().isAprilFoolLike.value = true;
                        CommonPreferences().isAprilFoolGPA.value = true;
                        CommonPreferences().isAprilFoolClass.value = true;
                        CommonPreferences().isAprilFoolHead.value = true;
                        Navigator.popAndPushNamed(context, HomeRouter.home);
                      },
                    );
                  });
            },
            child: generateCard(context, cards[i]),
          );
        } else {
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, cards[i].route),
            child: generateCard(context, cards[i]),
          );
        }
      },
    );

    return SizedBox(
      height: 90,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          cardList,
          Align(
            alignment: Alignment.centerRight,
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.center,
                  colors: [Colors.transparent, Colors.white],
                ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
              },
              blendMode: BlendMode.dstIn,
              child: InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {
                  controller.offset <= 130 * (itemCount - 1)
                      ? controller.animateTo(controller.offset + 130,
                          duration: Duration(milliseconds: 400),
                          curve: Curves.fastOutSlowIn)
                      : controller.animateTo(140 * (itemCount - 1).toDouble(),
                          duration: Duration(milliseconds: 800),
                          curve: Curves.slowMiddle);
                },
                child: Container(
                  height: 90,
                  width: 70,
                  child: SizedBox(),
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget generateCard(BuildContext context, CardBean bean, {Color textColor}) {
    return SizedBox(
      width: 150.w,
      height: 80.h,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
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
                    maxLines: 2,
                    style: TextUtil.base.w400.black2A.sp(12).medium),
              ],
            )
          ],
        ),
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

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, SystemUiOverlayStyle;
import 'package:url_launcher/url_launcher.dart';
import 'package:we_pei_yang_flutter/auth/view/settings/setting_page.dart';
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
import 'package:we_pei_yang_flutter/lounge/util/image_util.dart';
import 'package:we_pei_yang_flutter/lounge/main_page_widget.dart';
import 'package:we_pei_yang_flutter/schedule/view/wpy_course_widget.dart';
import 'package:we_pei_yang_flutter/schedule/view/wpy_exam_widget.dart';

final hintStyle = const TextStyle(
    fontSize: 16,
    color: Color.fromRGBO(53, 59, 84, 1),
    fontWeight: FontWeight.bold);

class WPYPage extends StatefulWidget {
  @override
  WPYPageState createState() => WPYPageState();
}

class WPYPageState extends State<WPYPage> {
  GlobalKey<ErCiYuanWidgetState> erCiYuanKey = GlobalKey();
  GlobalKey majorColumnHeightKey = GlobalKey();

  ScrollController customScrollViewController = ScrollController();
  List<CardBean> cards;

  @override
  void initState() {
    super.initState();
    cards = []
      ..add(DateTime.now().month == 4 && DateTime.now().day == 1
          ? CardBean(Image.asset('assets/images/lake_butt_icons/joker_stamp.png',width: 30,),
             '愚人节模式？')
          : null)
      ..add(CardBean(Icon(Icons.report, color: MyColors.darkGrey, size: 25),
          S.current.report, ReportRouter.main))
      ..add(CardBean(Icon(Icons.timeline, color: MyColors.darkGrey, size: 25),
          'GPA', GPARouter.gpa))
      ..add(CardBean(
          ImageIcon(AssetImage('assets/images/wiki.png'),
              color: MyColors.darkGrey, size: 25),
          'Wiki',
          'https://wiki.tjubot.cn/'))
      ..add(CardBean(
          ImageIcon(AssetImage('assets/images/exam.png'),
              color: MyColors.darkGrey, size: 25),
          '考表',
          ScheduleRouter.exam))
      ..add(CardBean(
          ImageIcon(AssetImage(Images.building),
              color: Color(0xffcecfd4), size: 20),
          S.current.lounge,
          LoungeRouter.main))
      ..add(CardBean(Icon(Icons.refresh, color: MyColors.darkGrey, size: 25),
          "重开模拟器", HomeRouter.restartGame));
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
    customScrollViewController.addListener(() {
      if (customScrollViewController.offset > _getWidgetHeight(context) + 100)
        erCiYuanKey.currentState.onStaged(false);
      else
        erCiYuanKey.currentState.onStaged(true);
    });
    return SafeArea(
      child: Stack(
        children: [
          Container(
            decoration: CommonPreferences().isBegonia.value?BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/images/begonia/haitang_background.png'),fit: BoxFit.cover),
            ):BoxDecoration(),
            child: ScrollConfiguration(
              behavior: WPYScrollBehavior(),
              child: CustomScrollView(
                controller: customScrollViewController,
                slivers: <Widget>[
                  /// 自定义标题栏
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 12),
                    sliver: SliverPersistentHeader(
                        delegate: _WPYHeader(onChanged: (_) {
                          setState(() {});
                        }),
                        pinned: true),
                  ),

                  /// 功能跳转卡片
                  SliverCardsWidget(cards),

                  /// 当天课程
                  SliverToBoxAdapter(
                      child: GestureDetector(
                    onLongPress: () => Navigator.pushNamed(
                        context, AuthRouter.setting,
                        arguments: SettingPageArgs(true)),
                    child: Column(
                      key: majorColumnHeightKey,
                      children: [
                        toolCards[0],
                        toolCards[1],
                        toolCards[2],
                        toolCards[3],
                      ], //以后可以写排序
                    ),
                  )),

                  !CommonPreferences().showPosterGirl.value
                      ? SliverToBoxAdapter()
                      : SliverToBoxAdapter(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height,
                            width: 1,
                          ),
                        )
                ],
              ),
            ),
          ),
          ErCiYuanWidget(erCiYuanKey),
        ],
      ),
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
    return Container(// 比其他区域rgb均高了一些,遮挡后方滚动区域
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
        if(cards[i]==null){
          return SizedBox();
        }else if (cards[i].label == 'Wiki') {
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
        } 
        else if(cards[i].label == '愚人节模式？'){
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
                      confirmFun: (){
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
        }
        else {
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, cards[i].route),
            child: generateCard(context, cards[i]),
          );
        }
      },
    );

    return SliverToBoxAdapter(
      child: SizedBox(
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
                    colors: [Colors.transparent, ColorUtil.backgroundColor],
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
                    child: Icon(Icons.arrow_forward_ios_sharp,
                        color: Color.fromRGBO(98, 103, 124, 1.0), size: 25),
                    color: ColorUtil.backgroundColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget generateCard(BuildContext context, CardBean bean, {Color textColor}) {
    return SizedBox(
      width: 125,
      height: 90,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            bean.icon,
            SizedBox(height: 5),
            Center(
              child: Text(bean.label,
                  style: FontManager.YaQiHei.copyWith(
                      color: textColor ?? MyColors.darkGrey,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
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
  String route;

  CardBean(
    this.icon,
    this.label,
    [this.route]
  );
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

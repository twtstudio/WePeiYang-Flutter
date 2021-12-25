import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, SystemUiOverlayStyle;

import 'package:we_pei_yang_flutter/auth/view/user/user_avatar_image.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/gpa/view/gpa_curve_detail.dart';
import 'package:we_pei_yang_flutter/home/poster_girl/poster_girl_based_widget.dart';
import 'package:we_pei_yang_flutter/lounge/service/images.dart';
import 'package:we_pei_yang_flutter/lounge/ui/widget/favour_list.dart';
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
  ValueNotifier<bool> canNotGoIntoLounge = ValueNotifier<bool>(false);
  GlobalKey<ErCiYuanWidgetState> erCiYuanKey = GlobalKey();
  GlobalKey majorColumnHeightKey = GlobalKey();

  ScrollController customScrollViewController = ScrollController();
  List<CardBean> cards;

  @override
  void initState() {
    super.initState();
    cards = []
      ..add(CardBean(Icon(Icons.report, color: MyColors.darkGrey, size: 25),
          S.current.report, ReportRouter.main))
      ..add(CardBean(Icon(Icons.timeline, color: MyColors.darkGrey, size: 25),
          'GPA', GPARouter.gpa))
      ..add(CardBean(
          ImageIcon(AssetImage('assets/images/wiki.png'),
              color: MyColors.darkGrey, size: 25),
          'Wiki',
          HomeRouter.wiki))
      ..add(CardBean(Icon(Icons.event, color: MyColors.darkGrey, size: 25),
          S.current.schedule, ScheduleRouter.schedule))
      ..add(CardBean(
          ImageIcon(AssetImage('assets/images/exam.png'),
              color: MyColors.darkGrey, size: 25),
          '考表',
          ScheduleRouter.exam))
      /// 别改变自习室的位置，确定下标为5，不然请去wpy_page最下面改一下index
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
            child: ScrollConfiguration(
              behavior: WPYScrollBehavior(),
              child: CustomScrollView(
                controller: customScrollViewController,
                slivers: <Widget>[
                  /// 自定义标题栏
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 8),
                    sliver: SliverPersistentHeader(
                        delegate: _WPYHeader(onChanged: (_) {
                          setState(() {});
                        }),
                        pinned: true
                        ),
                  ),

                  /// 功能跳转卡片
                  SliverCardsWidget(cards),

                  /// 当天课程
                  SliverToBoxAdapter(
                      child: Column(
                    key: majorColumnHeightKey,
                    children: [
                      TodayCoursesWidget(),
                      WpyExamWidget(),
                      GPAPreview(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 12),
                        child: LoungeFavourWidget(
                            title: S.current.lounge, init: true),
                      ),
                    ],
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
      color: Color.fromRGBO(247, 247, 248, 1), // 比其他区域rgb均高了一些,遮挡后方滚动区域
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
                  child: UserAvatarImage(size: 40),
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
  double get maxExtent => 65;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  String get _getGreetText {
    int hour = DateTime.now().hour;
    if (hour >= 0 && hour < 5)
      return '夜深了，早点睡';
    else if (hour >= 5 && hour < 8)
      return '起得好早';
    else if (hour >= 8 && hour < 12)
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
      padding: const EdgeInsets.only(left: 15),
      physics: const BouncingScrollPhysics(),
      itemCount: cards.length,
      itemBuilder: (context, i) {
        if (itemCount < i) itemCount = i;

        /// 这里是自习室在cards中的下标
        if (i != 5) {
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, cards[i].route),
            child: generateCard(context, cards[i]),
          );
        } else {
          return ValueListenableBuilder(
            valueListenable: context
                .findAncestorStateOfType<WPYPageState>()
                .canNotGoIntoLounge,
            builder: (_, bool absorbing, __) => GestureDetector(
              onTap: () {
                if (absorbing) {
                  ToastProvider.running("正在加载数据，请稍后");
                } else {
                  Navigator.pushNamed(context, cards[i].route);
                }
              },
              child: generateCard(context, cards[i]),
            ),
          );
        }
      },
    );

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 90,
        width: double.infinity,
        child: Row(
          children: [
            Expanded(child: cardList),
            SizedBox(
              height: 90,
              width: 45,
              child: Center(
                child: IconButton(
                    icon: Icon(Icons.arrow_forward_ios_sharp,
                        color: Color.fromRGBO(98, 103, 124, 1.0), size: 25),
                    onPressed: () {
                      controller.offset <= 130 * (itemCount - 1)
                          ? controller.animateTo(controller.offset + 130,
                              duration: Duration(milliseconds: 400),
                              curve: Curves.fastOutSlowIn)
                          : controller.animateTo(
                              140 * (itemCount - 1).toDouble(),
                              duration: Duration(milliseconds: 800),
                              curve: Curves.slowMiddle);
                    }),
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

  CardBean(this.icon, this.label, this.route);
}

class WPYScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return GlowingOverscrollIndicator(
      child: child,
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


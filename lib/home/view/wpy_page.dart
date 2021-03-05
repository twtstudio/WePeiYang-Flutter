import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/schedule/view/wpy_course_display.dart';
import 'package:wei_pei_yang_demo/lounge/ui/widget/favour_list.dart';
import '../model/home_model.dart';
import 'drawer_page.dart';
import '../../gpa/view/gpa_curve_detail.dart';
import 'package:wei_pei_yang_demo/commons/res/color.dart';

final hintStyle = const TextStyle(
    fontSize: 17,
    color: Color.fromRGBO(53, 59, 84, 1.0),
    fontWeight: FontWeight.bold);

class WPYPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Theme(
        data: ThemeData(accentColor: Colors.white),
        child: CustomScrollView(
          slivers: <Widget>[
            /// 自定义标题栏
            SliverPadding(
              padding: const EdgeInsets.only(top: 30.0),
              sliver:
                  SliverPersistentHeader(delegate: _WPYHeader(), pinned: true),
            ),

            /// 功能跳转卡片
            SliverCardsWidget(GlobalModel().cards),

            /// 当天课程
            SliverToBoxAdapter(child: TodayCoursesWidget()),

            /// GPA曲线及信息展示
            SliverToBoxAdapter(child: GPAPreview()),
            SliverToBoxAdapter(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 12),
              child: SRFavourWidget(title: '自习室'),
            ))
          ],
        ),
      ),
    );
  }
}

///替代appbar使用
class _WPYHeader extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Color.fromRGBO(247, 247, 248, 1), // 比其他区域rgb均高了一些,遮挡后方滚动区域
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(30.0, 15.0, 10.0, 0.0),
      child: Row(
        children: <Widget>[
          Text("Hello",
              style: TextStyle(
                  fontSize: 35,
                  color: MyColors.deepBlue,
                  fontWeight: FontWeight.bold)),
          Expanded(child: Text('')), // 起填充作用
          Text(CommonPreferences().nickname.value, style: hintStyle),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/user_info'),
            child: Container(
              margin: EdgeInsets.only(left: 7, right: 10),
              child: Icon(Icons.account_circle_rounded,
                  size: 40, color: MyColors.deepBlue),
            ),
          )
        ],
      ),
    );
  }

  @override
  double get maxExtent => 120.0;

  @override
  double get minExtent => 65.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}

class SliverCardsWidget extends StatelessWidget {
  final List<CardBean> cards;

  SliverCardsWidget(this.cards);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 90.0,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            itemCount: cards.length,
            itemBuilder: (context, i) {
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, cards[i].route),
                child: Container(
                  height: 90.0,
                  width: 125.0,
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: generateCard(context, cards[i]),
                ),
              );
            }),
      ),
    );
  }
}

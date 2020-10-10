import 'package:flutter/material.dart';

import 'model/home_model.dart';
import 'more_page.dart';
import '../gpa/gpa_curve_detail.dart';
import 'package:wei_pei_yang_demo/commons/color.dart';

class WPYPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<CardBean> cards = [];
    List<CourseBean> courses = [];
    List<LibraryBean> libraries = [];
    cards.add(CardBean(Icons.event, 'Schedule', '/schedule'));
    cards.add(CardBean(Icons.timeline, 'GPA', '/gpa'));
    cards.add(CardBean(Icons.import_contacts, 'Learning', '/learning'));
    cards.add(CardBean(Icons.call, 'Tel Num', '/telNum'));
    cards.add(CardBean(Icons.clear_all, 'Library', '/library'));
    cards.add(CardBean(Icons.card_giftcard, 'Cards', '/cards'));
    cards.add(CardBean(Icons.business, 'Classroom', '/classroom'));
    cards.add(CardBean(Icons.free_breakfast, 'Coffee', '/coffee'));
    cards.add(CardBean(Icons.directions_bus, 'By bus', '/byBus'));
    courses.add(CourseBean('SoftWare Engineering', '08:30-10:10', '45-B311'));
    courses.add(CourseBean('Computer Network', '10:20-11:50', '46-A108'));
    courses.add(CourseBean('College Japanese', '13:30-15:00', '47-B228'));
    courses.add(CourseBean('Free Time', null, null));
    courses.add(CourseBean('College English', '18:30-20:30', '45-B117'));
    libraries.add(LibraryBean('Design Psychology1', '2018-08-08'));
    libraries.add(LibraryBean('User Experience', '2018-07-29'));
    libraries.add(LibraryBean('The visual design', '2018-07-26'));
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
            // TODO listview 替换顺序
            SliverCardsWidget(cards),
            SliverCoursesWidget(courses),
            SliverLibraryWidget(libraries),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 25.0, 0.0, 30.0),
                child: Text('GPA',
                    style: TextStyle(
                        fontSize: 17.0,
                        color: MyColors.deepBlue,
                        fontWeight: FontWeight.w600)),
              ),
            ),

            /// 自定义GPA曲线
            SliverToBoxAdapter(child: GPAPreview()),
            SliverToBoxAdapter(
              child: Container(
                height: 180.0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 30.0, vertical: 30.0),
                child: Card(
                  color: MyColors.myGrey,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  child: Center(
                    child: GestureDetector(
                      child: Text(
                        'MORE >>',
                        style: TextStyle(
                            fontSize: 25.0,
                            color: MyColors.darkGrey2,
                            fontWeight: FontWeight.w600),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/more',
                            arguments: CardArguments(cards));
                      },
                    ),
                  ),
                ),
              ),
            ),
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
    var now = DateTime.now();
    String date = '${now.year}.${now.month}.${now.day}';
    return Container(
      color: Colors.white, // 比其他区域rgb均高了5,遮挡后方滚动区域
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(30.0, 15.0, 10.0, 0.0),
      child: Row(
        children: <Widget>[
          Text(date,
              style: TextStyle(
                  fontSize: 25.0,
                  color: MyColors.deepBlue,
                  fontWeight: FontWeight.bold)),
          Expanded(child: Text('')), // 起填充作用
          Text('BOTillya',
              style: TextStyle(color: MyColors.deepBlue, fontSize: 17.0)),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/user'),
            child: Container(
              height: 40.0,
              width: 40.0,
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              child: ClipOval(
                  child:
                      Image(image: AssetImage('assets/images/user_image.jpg'))),
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
            itemCount: cards.length + 1,
            itemBuilder: (context, i) {
              return GestureDetector(
                onTap: () {
                  if (i == cards.length) {
                    Navigator.pushNamed(context, '/more',
                        arguments: CardArguments(cards));
                  } else
                    Navigator.pushNamed(context, cards[i].route);
                },
                child: Container(
                  height: 90.0,
                  width: 130.0,
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: _getCard(cards, i, context),
                ),
              );
            }),
      ),
    );
  }

  /// 显示“More”的卡片，其余卡片详见[generateCard]
  Widget _getCard(List<CardBean> cards, int index, BuildContext context) {
    if (index == cards.length) {
      const startColor = Color.fromRGBO(142, 147, 171, 1.0);
      const endColor = Color.fromRGBO(166, 170, 185, 1.0);
      return GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/more',
            arguments: CardArguments(cards)),
        child: Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  gradient: LinearGradient(colors: [startColor, endColor])),
              child: Center(
                  child: Text('More',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold))),
            )),
      );
    } else
      return generateCard(context, cards[index]);
  }
}

class SliverCoursesWidget extends StatelessWidget {
  final List<CourseBean> courses;

  SliverCoursesWidget(this.courses);

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var week = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(30.0, 20.0, 0.0, 12.0),
            alignment: Alignment.centerLeft,
            child: Text('NO.${now.day} ${week[now.weekday - 1]}',
                style: TextStyle(
                    fontSize: 17.0,
                    color: MyColors.deepBlue,
                    fontWeight: FontWeight.w600)),
          ),
          Container(
            height: 180.0,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: courses.length,
                itemBuilder: (context, i) {
                  return GestureDetector(
                    onTap: () {
//                        Navigator.push(context, MaterialPageRoute(builder: (context) => Text('123')));
                    },
                    child: Container(
                      height: 180.0,
                      width: 150.0,
                      padding: const EdgeInsets.symmetric(horizontal: 7.0),
                      child: Card(
                        color: MyColors.colorList[i % 5],
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 95.0,
                                alignment: Alignment.centerLeft,
                                child: Text(courses[i].course,
                                    style: TextStyle(
                                        fontSize: 17.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Text(
                                    courses[i].duration ?? 'Your own time',
                                    style: TextStyle(
                                        fontSize: 13.0, color: Colors.white)),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(top: 15.0),
                                child: Text(courses[i].classroom ?? '',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

class SliverLibraryWidget extends StatelessWidget {
  final List<LibraryBean> libraries;

  SliverLibraryWidget(this.libraries);

  @override
  Widget build(BuildContext context) {
    var libraryCount = libraries.length >= 10
        ? libraries.length.toString()
        : '0${libraries.length}';
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(30.0, 20.0, 0.0, 15.0),
            alignment: Alignment.centerLeft,
            child: Text('Library $libraryCount',
                style: TextStyle(
                    fontSize: 17.0,
                    color: MyColors.deepBlue,
                    fontWeight: FontWeight.w600)),
          ),
          Container(
            height: 170.0,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: libraries.length,
                itemBuilder: (context, i) => GestureDetector(
                      onTap: () {
//                        Navigator.push(context, MaterialPageRoute(builder: (context) => Text('123')));
                      },
                      child: Container(
                        height: 170.0,
                        width: 150.0,
                        padding: const EdgeInsets.symmetric(horizontal: 7.0),
                        child: Card(
                          color: Colors.white,
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          child: Row(
                            children: <Widget>[
                              Container(
                                  margin: EdgeInsets.symmetric(vertical: 2.0),
                                  decoration: BoxDecoration(
                                      color: MyColors.colorList[(i + 3) % 5],
                                      borderRadius: BorderRadius.only(
                                          topLeft:
                                              Radius.elliptical(60.0, 120.0),
                                          bottomLeft:
                                              Radius.elliptical(60.0, 120.0))),
                                  width: 6.0),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 11.0),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        height: 95.0,
                                        alignment: Alignment.centerLeft,
                                        child: Text(libraries[i].book,
                                            style: TextStyle(
                                                fontSize: 17.0,
                                                color: MyColors.deepBlue,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        padding:
                                            const EdgeInsets.only(top: 15.0),
                                        child: Text('Time:',
                                            style: TextStyle(
                                              fontSize: 13.0,
                                              color: MyColors.deepBlue,
                                            )),
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(libraries[i].time,
                                            style: TextStyle(
                                                fontSize: 14.0,
                                                color: MyColors.deepBlue)),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )),
          )
        ],
      ),
    );
  }
}

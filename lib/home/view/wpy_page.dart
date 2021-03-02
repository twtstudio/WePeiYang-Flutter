import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/schedule/view/wpy_course_display.dart';
import 'package:wei_pei_yang_demo/lounge/ui/widget/favour_list.dart';
import '../model/home_model.dart';
import 'more_page.dart';
import '../../gpa/view/gpa_curve_detail.dart';
import 'package:wei_pei_yang_demo/commons/res/color.dart';

final hintStyle = const TextStyle(
    fontSize: 17.0,
    color: Color.fromRGBO(53, 59, 84, 1.0),
    fontWeight: FontWeight.bold);

class WPYPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<LibraryBean> libraries = [];
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

            /// 功能跳转卡片
            SliverCardsWidget(GlobalModel().cards),

            /// 当天课程
            SliverToBoxAdapter(child: TodayCoursesWidget()),

            /// 废弃的library罢了
            // SliverLibraryWidget(libraries),

            /// GPA曲线及信息展示
            SliverToBoxAdapter(child: GPAPreview()),
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(0,20,0,12),
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
          Text('BOTillya', style: hintStyle),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/user_info'),
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
            child: Text('Library $libraryCount', style: hintStyle),
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
                                            style: hintStyle),
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

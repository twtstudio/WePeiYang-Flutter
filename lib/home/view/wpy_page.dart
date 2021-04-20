import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/lounge/service/repository.dart';
import 'package:wei_pei_yang_demo/schedule/view/wpy_course_display.dart';
import '../model/home_model.dart';
import 'drawer_page.dart';
import '../../gpa/view/gpa_curve_detail.dart';
import 'package:wei_pei_yang_demo/commons/res/color.dart';
import 'package:wei_pei_yang_demo/lounge/ui/widget/favour_list.dart';
import 'package:flutter/services.dart';
import 'package:wei_pei_yang_demo/commons/util/router_manager.dart';

final hintStyle = const TextStyle(
    fontSize: 17,
    color: Color.fromRGBO(53, 59, 84, 1.0),
    fontWeight: FontWeight.bold);

class WPYPage extends StatefulWidget {
  @override
  WPYPageState createState() => WPYPageState();
}

class WPYPageState extends State<WPYPage> {
  ValueNotifier<bool> canNotGoIntoLounge = ValueNotifier<bool>(false);

  FToast _fToast;

  @override
  void initState() {
    super.initState();
    _fToast = FToast();
    _fToast.init(context);
  }

  showToast({Widget custom}) {
    Widget toast = custom ??
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: Colors.greenAccent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon(Icons.check),
              // SizedBox(
              //   width: 12.0,
              // ),
              Text("正在加载数据，请稍后"),
            ],
          ),
        );

    _fToast.removeQueuedCustomToasts();

    _fToast.showToast(
      child: toast,
      gravity: ToastGravity.CENTER,
      toastDuration: Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Material(
      child: Theme(
        data: ThemeData(accentColor: Colors.white),
        child: CustomScrollView(
          slivers: <Widget>[
            /// 自定义标题栏
            SliverPadding(
              padding: const EdgeInsets.only(top: 30.0),
              sliver: SliverPersistentHeader(
                  delegate: _WPYHeader(onChanged: (_) {
                    setState(() {});
                  }),
                  pinned: true),
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
              child: LoungeFavourWidget(title: '自习室', init: true),
            ))
          ],
        ),
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
            onTap: () =>
                Navigator.pushNamed(context, AuthRouter.userInfo).then((_) {
              onChanged(null);
            }),
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
  double get maxExtent => 120;

  @override
  double get minExtent => 65.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}

class SliverCardsWidget extends StatelessWidget {
  final List<CardBean> cards;

  SliverCardsWidget(this.cards);

  @override
  Widget build(BuildContext context) {
    Widget cardList = ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      itemCount: cards.length,
      itemBuilder: (context, i) {
        if (i != 2) {
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, cards[i].route),
            child: Container(
              height: 90.0,
              width: 125.0,
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: generateCard(context, cards[i]),
            ),
          );
        } else {
          return ValueListenableBuilder(
            valueListenable: context
                .findAncestorStateOfType<WPYPageState>()
                .canNotGoIntoLounge,
            builder: (_, bool absorbing, __) => GestureDetector(
              onTap: () {
                print("absorbing : $absorbing");
                if (absorbing) {
                  context.findAncestorStateOfType<WPYPageState>().showToast(
                        custom: null,
                      );
                } else {
                  Navigator.pushNamed(context, cards[i].route);
                }
              },
              child: Container(
                height: 90.0,
                width: 125.0,
                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                child: generateCard(context, cards[i]),
              ),
            ),
          );
        }
      },
    );

    return SliverToBoxAdapter(
      child: Container(
        height: 90.0,
        child: cardList,
      ),
    );
  }
}

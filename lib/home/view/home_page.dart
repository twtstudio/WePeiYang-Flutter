import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/auth/view/user_page.dart';
import 'package:wei_pei_yang_demo/commons/res/color.dart';
import 'package:wei_pei_yang_demo/home/view/more_page.dart';
import '../model/home_model.dart';
import 'wpy_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// bottomNavigationBar对应的分页
  List<Widget> pages = List<Widget>();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    pages..add(WPYPage())..add(MorePage())..add(MorePage())..add(UserPage());
  }

  @override
  Widget build(BuildContext context) {
    double width = GlobalModel().screenWidth / 4;
    var currentStyle = TextStyle(
        fontSize: 12, color: MyColors.deepBlue, fontWeight: FontWeight.w800);
    var otherStyle = TextStyle(
        fontSize: 12, color: MyColors.deepDust, fontWeight: FontWeight.w800);
    return Scaffold(
        bottomNavigationBar: BottomAppBar(
          child: Row(
            children: <Widget>[
              Container(
                  height: 70,
                  width: width,
                  child: RaisedButton(
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(),
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 25,
                            height: 25,
                            child: Image(
                                image:
                                    AssetImage('assets/images/icon_home.png'),
                                color: _currentIndex == 0
                                    ? MyColors.deepBlue
                                    : MyColors.deepDust),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text('主页',
                                style: _currentIndex == 0
                                    ? currentStyle
                                    : otherStyle),
                          ),
                        ],
                      ),
                      onPressed: () => setState(() => _currentIndex = 0))),
              Container(
                  height: 70,
                  width: width,
                  child: RaisedButton(
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(),
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 25,
                            height: 25,
                            child: Image(
                                image:
                                    AssetImage('assets/images/icon_action.png'),
                                color: _currentIndex == 1
                                    ? MyColors.deepBlue
                                    : MyColors.deepDust),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text('抽屉',
                                style: _currentIndex == 1
                                    ? currentStyle
                                    : otherStyle),
                          ),
                        ],
                      ),
                      onPressed: () => setState(() => _currentIndex = 1))),
              Container(
                  height: 70,
                  width: width,
                  child: RaisedButton(
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(),
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 25,
                            height: 25,
                            child: Image(
                                image: AssetImage(
                                    'assets/images/icon_feedback.png'),
                                color: _currentIndex == 2
                                    ? MyColors.deepBlue
                                    : MyColors.deepDust),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text('校务',
                                style: _currentIndex == 2
                                    ? currentStyle
                                    : otherStyle),
                          ),
                        ],
                      ),
                      onPressed: () => setState(() => _currentIndex = 2))),
              Container(
                  height: 70,
                  width: width,
                  child: RaisedButton(
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(),
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 25,
                            height: 25,
                            child: Image(
                                image:
                                    AssetImage('assets/images/icon_user.png'),
                                color: _currentIndex == 3
                                    ? MyColors.deepBlue
                                    : MyColors.deepDust),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text('个人中心',
                                style: _currentIndex == 3
                                    ? currentStyle
                                    : otherStyle),
                          ),
                        ],
                      ),
                      onPressed: () => setState(() => _currentIndex = 3))),
            ],
          ),
        ),
        body: pages[_currentIndex]);
  }
}

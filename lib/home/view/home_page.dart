import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wei_pei_yang_demo/auth/view/user/user_page.dart';
import 'package:wei_pei_yang_demo/commons/update/update.dart';
import 'package:wei_pei_yang_demo/message/feedback_badge_widget.dart';
import 'package:wei_pei_yang_demo/commons/res/color.dart';
import 'package:wei_pei_yang_demo/feedback/view/home_page.dart';
import 'package:wei_pei_yang_demo/home/view/drawer_page.dart';
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
    pages
      ..add(WPYPage())
      ..add(FeedbackHomePage())
      // ..add(DrawerPage())
      ..add(UserPage());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      UpdateManager.checkUpdate();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = GlobalModel().screenWidth / 3;
    var currentStyle = TextStyle(
        fontSize: 12, color: MyColors.deepBlue, fontWeight: FontWeight.w800);
    var otherStyle = TextStyle(
        fontSize: 12, color: MyColors.deepDust, fontWeight: FontWeight.w800);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _currentIndex == 2
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        bottomNavigationBar: BottomAppBar(
          child: Row(
            children: <Widget>[
              Container(
                  height: 70,
                  width: width,
                  child: RaisedButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      highlightElevation: 0,
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(),
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            child: Image(
                                image: _currentIndex == 0
                                    ? AssetImage(
                                        'assets/images/icon_home_active.png')
                                    : AssetImage(
                                        'assets/images/icon_home.png')),
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
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      highlightElevation: 0,
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FeedbackBadgeWidget(
                            type: FeedbackMessageType.home,
                            child: Container(
                              width: 20,
                              height: 20,
                              child: Image(
                                  image: _currentIndex == 1
                                      ? AssetImage(
                                          'assets/images/icon_feedback_active.png')
                                      : AssetImage(
                                          'assets/images/icon_feedback.png')),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text('校务',
                                style: _currentIndex == 1
                                    ? currentStyle
                                    : otherStyle),
                          ),
                        ],
                      ),
                      onPressed: () => setState(() => _currentIndex = 1))),
              // Container(
              //     height: 70,
              //     width: width,
              //     child: RaisedButton(
              //         elevation: 0.0,
              //         shape: RoundedRectangleBorder(),
              //         color: Colors.white,
              //         splashColor: Colors.transparent,
              //         highlightColor: Colors.transparent,
              //         highlightElevation: 0,
              //         child: Column(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             Container(
              //               width: 20,
              //               height: 20,
              //               child: Image(
              //                   image: _currentIndex == 2
              //                       ? AssetImage(
              //                           'assets/images/icon_action_active.png')
              //                       : AssetImage(
              //                           'assets/images/icon_action.png')),
              //             ),
              //             Padding(
              //               padding: const EdgeInsets.only(top: 3),
              //               child: Text('抽屉',
              //                   style: _currentIndex == 2
              //                       ? currentStyle
              //                       : otherStyle),
              //             ),
              //           ],
              //         ),
              //         onPressed: () => setState(() => _currentIndex = 2))),
              Container(
                  height: 70,
                  width: width,
                  child: RaisedButton(
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(),
                      color: Colors.white,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      highlightElevation: 0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            child: Image(
                                image: _currentIndex == 2
                                    ? AssetImage(
                                        'assets/images/icon_user_active.png')
                                    : AssetImage(
                                        'assets/images/icon_user.png')),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text('个人中心',
                                style: _currentIndex == 2
                                    ? currentStyle
                                    : otherStyle),
                          ),
                        ],
                      ),
                      onPressed: () => setState(() => _currentIndex = 2))),
            ],
          ),
        ),
        body: AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: pages[_currentIndex],
        ),
      ),
    );
  }
}

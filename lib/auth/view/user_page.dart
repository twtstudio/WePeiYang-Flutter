import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wei_pei_yang_demo/commons/res/color.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';

import '../../main.dart';

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 246, 247, 1.0),
      body: Theme(
        data: ThemeData(accentColor: Colors.white),
        child: Stack(
          children: <Widget>[
            Container(height: 380, color: MyColors.darkGrey),
            ListView(
              children: <Widget>[
                Container(
                    margin: EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 0),
                    height: 50.0,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        GestureDetector(
                            child: Icon(Icons.arrow_back,
                                color: Colors.white, size: 30.0),
                            onTap: () => Navigator.pop(context)),
                        Expanded(child: Text('')),

                        ///填充
                        GestureDetector(
                            child: Icon(Icons.settings,
                                color: Colors.white, size: 28.0),

                            //TODO: setting page
                            onTap: () => Navigator.pop(context))
                      ],
                    )),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: 15.0),
                  child: ClipOval(
                      child: Image.asset(
                    'assets/images/user_image.jpg',
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  )),
                ),
                Text('BOTillya',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    )),
                Container(
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                    child: Text('3019244334',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: MyColors.deepDust, fontSize: 13.0))),
                NavigationWidget(),
                Column(
                  children: [
                    _getAccountCard(context, 0),
                    _getAccountCard(context, 1),
                    _getAccountCard(context, 2)
                  ],
                ),
                Container(
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(30, 20, 30, 50),
                  child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: Color.fromRGBO(85, 89, 106, 1.0),
                      onPressed: () {
                        // TODO 其他退出逻辑
                        Fluttertoast.showToast(
                            msg: "   退出登录成功   ",
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                            fontSize: 18);
                        CommonPreferences.create().clearPrefs();
                        Navigator.pushNamedAndRemoveUntil(
                            WeiPeiYangApp.navigatorState.currentContext,
                            '/login',
                            (route) => false);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.exit_to_app,
                            color: Colors.white,
                            size: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "SIGN ME OUT",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  final iconList = [Icons.event_note, Icons.credit_card, Icons.class_];
  final textList = ["Tju account", "E-card account", "Library account"];
  final routeList = ['/bind', '/gpa', '/gpa'];

  Widget _getAccountCard(BuildContext context, int index) {
    const textStyle =
        TextStyle(fontSize: 18.0, color: Color.fromRGBO(99, 101, 115, 1));
    const hint = Text('Bound',
        style: TextStyle(fontSize: 12.0, color: Colors.grey),
        textAlign: TextAlign.left);
    const arrow = Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 22);
    // TODO 点击逻辑
    return Container(
      height: 90,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, routeList[index]),
          splashFactory: InkRipple.splashFactory,
          borderRadius: BorderRadius.circular(9),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 22, right: 10),
                child: Icon(iconList[index], color: Colors.grey),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 150,
                      child: Text(textList[index], style: textStyle)),
                  Container(
                      child: hint,
                      width: 150,
                      padding: const EdgeInsets.only(top: 3))
                ],
              ),
              Expanded(child: Text('')),
              Padding(padding: const EdgeInsets.only(right: 22), child: arrow)
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationWidget extends StatefulWidget {
  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<NavigationWidget> {
  static const statStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16.0,
      color: Color.fromRGBO(99, 101, 115, 1));

  static const pressOnMaskColor = Color.fromRGBO(250, 250, 250, 0.6);
  static const pressOffMaskColor = Color.fromRGBO(250, 250, 250, 0);

  List<bool> currentList = [false, false, false];

  List<String> assetList = [
    "assets/images/gradicon1.png",
    "assets/images/gradicon2.png",
    "assets/images/gradicon3.png"
  ];

  List<String> textList = ['GPA', 'Library', 'E-card'];

  // TODO route补充
  List<String> routeList = ['/gpa', '/gpa', '/gpa'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140.0,
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Card(
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[_getStack(0), _getStack(1), _getStack(2)],
          ),
        ),
      ),
    );
  }

  Widget _getStack(int index) => GestureDetector(
        onTapDown: (_) => setState(() {
          currentList[index] = true;
        }),
        onTapUp: (_) => setState(() {
          currentList[index] = false;
        }),
        onTapCancel: () => setState(() {
          currentList[index] = false;
        }),
        onTap: () {
          Navigator.pushNamed(context, routeList[index]);
        },
        child: Stack(children: [
          Column(
            children: <Widget>[
              Image.asset(
                assetList[index],
                width: 50,
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(textList[index], style: statStyle),
              )
            ],
          ),
          Container(
              height: 100,
              width: 50,
              color: currentList[index] ? pressOnMaskColor : pressOffMaskColor)
        ]),
      );
}

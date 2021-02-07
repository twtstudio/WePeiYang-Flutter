import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/auth/view/logout_dialog.dart';
import 'package:wei_pei_yang_demo/commons/res/color.dart';

class UserPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color.fromRGBO(98, 103, 122, 1));
    const arrow = Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 22);
    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 246, 247, 1.0),
      body: Theme(
        data: ThemeData(accentColor: Colors.white),
        child: Stack(
          children: <Widget>[
            Container(height: 360, color: MyColors.darkGrey),
            ListView(
              children: <Widget>[
                Container(
                    margin: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0),
                    height: 50.0,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Text('')),
                        GestureDetector(
                            child: Icon(Icons.settings,
                                color: Colors.white, size: 28.0),
                            onTap: () =>
                                Navigator.pushNamed(context, '/setting'))
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
                Container(
                  height: 90,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9)),
                    child: InkWell(
                      onTap: () {
                        // TODO 关于twt页面
                      },
                      splashFactory: InkRipple.splashFactory,
                      borderRadius: BorderRadius.circular(9),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 20,
                            margin: const EdgeInsets.only(left: 20, right: 10),
                            child: Image.asset('assets/images/twt.png',
                                color: Colors.grey),
                          ),
                          Container(
                              width: 150,
                              child: Text('关于天外天', style: textStyle)),
                          Expanded(child: Text('')),
                          Padding(
                              padding: const EdgeInsets.only(right: 22),
                              child: arrow)
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 90,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9)),
                    child: InkWell(
                      onTap: () => showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) => LogoutDialog()),
                      splashFactory: InkRipple.splashFactory,
                      borderRadius: BorderRadius.circular(9),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 20,
                            margin: const EdgeInsets.only(left: 20, right: 10),
                            child: Image.asset('assets/images/logout.png',
                                color: Colors.grey),
                          ),
                          Container(
                              width: 150, child: Text('登出', style: textStyle)),
                          Expanded(child: Text('')),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// TODO 以后可能会在里面加小游戏？
class NavigationWidget extends StatefulWidget {
  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<NavigationWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140.0,
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Card(
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      ),
    );
  }
}

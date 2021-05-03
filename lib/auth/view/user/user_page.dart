import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/auth/view/user/logout_dialog.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/commons/res/color.dart';
import 'package:wei_pei_yang_demo/commons/update/common.dart';
import 'package:wei_pei_yang_demo/commons/update/update.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:flutter/services.dart';
import 'package:wei_pei_yang_demo/home/model/home_model.dart';
import 'package:wei_pei_yang_demo/commons/util/router_manager.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
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
            Image.asset('assets/images/user_back.png',
                height: 350, alignment: Alignment.topCenter, fit: BoxFit.fill),
            ListView(
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                Container(
                    margin: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0),
                    height: 50.0,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Text('')),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, AuthRouter.mailbox),
                          child: Icon(
                            Icons.email_outlined,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 15),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, AuthRouter.setting),
                          child: Image.asset('assets/images/setting.png',
                              width: 24, height: 24),
                        )
                      ],
                    )),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: 15.0),
                  child: GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, AuthRouter.userInfo)
                              .then((_) => setState(() {})),
                      child: Icon(Icons.account_circle_rounded,
                          size: 90, color: Colors.white)),
                ),
                Text(CommonPreferences().nickname.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    )),
                Container(
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(CommonPreferences().userNumber.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: MyColors.deepDust, fontSize: 13.0))),
                NavigationWidget(),
                Container(
                  height: 80,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9)),
                    child: InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, AuthRouter.userInfo),
                      splashFactory: InkRipple.splashFactory,
                      borderRadius: BorderRadius.circular(9),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 20,
                            margin: const EdgeInsets.only(left: 20, right: 10),
                            child: Image.asset(
                                'assets/images/modify_info_icon.png'),
                          ),
                          Container(
                              width: 150,
                              child: Text('个人信息更改', style: textStyle)),
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
                  height: 80,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9)),
                    child: InkWell(
                      onTap: () {
                        // TODO 关于twt页面
                        ToastProvider.error('还没做呢，悲');
                      },
                      splashFactory: InkRipple.splashFactory,
                      borderRadius: BorderRadius.circular(9),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 20,
                            margin: const EdgeInsets.only(left: 20, right: 10),
                            child: Image.asset('assets/images/twt.png'),
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
                  height: 80,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9)),
                    child: InkWell(
                      onTap: () {
                        WidgetsBinding.instance
                            .addPostFrameCallback((timeStamp) {
                          UpdateManager.checkUpdate();
                        });
                      },
                      splashFactory: InkRipple.splashFactory,
                      borderRadius: BorderRadius.circular(9),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 20,
                            margin: const EdgeInsets.only(left: 20, right: 10),
                            child: Icon(Icons.update),
                          ),
                          Container(
                              width: 100,
                              child: Text('检查更新', style: textStyle)),
                          FutureBuilder(
                            future: CommonUtils.getVersion(),
                            builder: (_, AsyncSnapshot<String> snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  "当前版本：${snapshot.data}",
                                  style: TextStyle(
                                    color: Color(0xffcfd0d5),
                                    fontSize: 12,
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 80,
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
                            child: Image.asset('assets/images/logout.png'),
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

class NavigationWidget extends StatefulWidget {
  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<NavigationWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: GlobalModel().screenWidth - 40,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        elevation: 1.8,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Center(
          child: Image.asset(
            'assets/images/to_be_continue.png',
            height: 80,
          ),
        ),
      ),
    );
  }
}

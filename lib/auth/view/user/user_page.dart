import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, SystemUiOverlayStyle;
import 'package:we_pei_yang_flutter/auth/view/login/privacy_dialog.dart';

import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/auth/view/user/debug_dialog.dart';
import 'package:we_pei_yang_flutter/auth/view/user/logout_dialog.dart';
import 'package:we_pei_yang_flutter/auth/view/user/user_avatar_image.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/update/common.dart';
import 'package:we_pei_yang_flutter/commons/update/update_service.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.white));
    final textStyle = FontManager.YaHeiRegular.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color.fromRGBO(98, 103, 122, 1));
    const arrow = Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 22);
    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 246, 247, 1),
      body: Theme(
        data: ThemeData(accentColor: Colors.white),
        child: Stack(
          children: <Widget>[
            Image.asset('assets/images/user_back.png',
                height: 350, alignment: Alignment.topCenter, fit: BoxFit.fill),
            ListView(
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                SizedBox(height: 15),
                Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        Spacer(),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, AuthRouter.mailbox),
                          child: Icon(
                            Icons.email_outlined,
                            size: 28,
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
                Center(
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AuthRouter.userInfo)
                            .then((_) => setState(() {})),
                    child: UserAvatarImage(size: 90, iconColor: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(CommonPreferences().nickname.value,
                      textAlign: TextAlign.center,
                      style: FontManager.YaHeiRegular.copyWith(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                GestureDetector(
                    onLongPress: () => showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) => DebugDialog()),
                    child: Text(CommonPreferences().userNumber.value,
                        textAlign: TextAlign.center,
                        style: FontManager.Texta.copyWith(
                            color: MyColors.deepDust, fontSize: 15))),
                SizedBox(height: 5),
                NavigationWidget(),
                Container(
                  height: 80,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
                          SizedBox(width: 20),
                          Image.asset('assets/images/modify_info_icon.png',
                              width: 20),
                          SizedBox(width: 10),
                          SizedBox(
                              width: 150,
                              child: Text(S.current.reset_user_info,
                                  style: textStyle)),
                          Spacer(),
                          arrow,
                          SizedBox(width: 22)
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 80,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9)),
                    child: InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, AuthRouter.aboutTwt),
                      splashFactory: InkRipple.splashFactory,
                      borderRadius: BorderRadius.circular(9),
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 20),
                          Image.asset('assets/images/twt.png', width: 20),
                          SizedBox(width: 10),
                          SizedBox(
                              width: 150,
                              child:
                                  Text(S.current.about_twt, style: textStyle)),
                          Spacer(),
                          arrow,
                          SizedBox(width: 22),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 80,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9)),
                    child: InkWell(
                      onTap: () {
                        WidgetsBinding.instance
                            .addPostFrameCallback((timeStamp) {
                          UpdateManager.checkUpdate(showDialog: true);
                        });
                      },
                      splashFactory: InkRipple.splashFactory,
                      borderRadius: BorderRadius.circular(9),
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 20),
                          Icon(Icons.update,
                              color: Color.fromRGBO(98, 103, 122, 1), size: 20),
                          SizedBox(width: 10),
                          Text(S.current.check_new, style: textStyle),
                          Spacer(),
                          FutureBuilder(
                            future: CommonUtils.getVersion(),
                            builder: (_, AsyncSnapshot<String> snapshot) {
                              if (snapshot.hasData) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 26),
                                  child: Text(
                                    "${S.current.current_version}: ${snapshot.data}",
                                    style: FontManager.YaHeiLight.copyWith(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9)),
                    child: InkWell(
                      onTap: () => showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) => PrivacyDialog()),
                      splashFactory: InkRipple.splashFactory,
                      borderRadius: BorderRadius.circular(9),
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 20),
                          Icon(Icons.lock_outline,
                              color: Color.fromRGBO(98, 103, 122, 1), size: 20),
                          SizedBox(width: 10),
                          Text('查看隐私政策', style: textStyle),
                          Spacer(),
                          arrow,
                          SizedBox(width: 22),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 80,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
                          SizedBox(width: 20),
                          Image.asset('assets/images/logout.png', width: 20),
                          SizedBox(width: 10),
                          SizedBox(
                              width: 150,
                              child: Text(S.current.logout, style: textStyle)),
                          Spacer()
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
      width: WePeiYangApp.screenWidth - 40,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        elevation: 1.8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Center(
          child: Image.asset('assets/images/to_be_continue.png', height: 80),
        ),
      ),
    );
  }
}

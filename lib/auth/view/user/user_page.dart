import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, SystemUiOverlayStyle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/auth/view/privacy/privacy_dialog.dart';
import 'package:we_pei_yang_flutter/auth/view/privacy/user_agreement_dialog.dart';
import 'package:we_pei_yang_flutter/auth/view/settings/setting_page.dart';
import 'package:we_pei_yang_flutter/auth/view/user/debug_dialog.dart';
import 'package:we_pei_yang_flutter/auth/view/user/logout_dialog.dart';
import 'package:we_pei_yang_flutter/auth/view/user/user_avatar_image.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/test/test_router.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/april_fool_dialog.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  var pref = CommonPreferences();

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
            CommonPreferences().isSkinUsed.value
                ? Image.network(CommonPreferences().skinProfile.value,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2,
                    alignment: Alignment.topCenter,
                    fit: BoxFit.fill)
                : Image.asset('assets/images/user_back.png',
                    height: 350,
                    alignment: Alignment.topCenter,
                    fit: BoxFit.fill),
            ListView(
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                SizedBox(height: 15),
                if (!CommonPreferences().isSkinUsed.value)
                  Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: <Widget>[
                          Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, AuthRouter.mailbox),
                            child: Icon(
                              Icons.email_outlined,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 15),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                    context, AuthRouter.setting,
                                    arguments: SettingPageArgs(false))
                                .then((value) => this.setState(() {})),
                            child: Image.asset('assets/images/setting.png',
                                width: 24, height: 24),
                          )
                        ],
                      )),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () {
                      if (CommonPreferences().isAprilFoolHead.value) {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AprilFoolDialog(
                                content: "今天，我们都是小丑！\n 不是你没办法修改头像框了，是我小丑还想玩呢！",
                                confirmText: "去掉小丑帽",
                                cancelText: "再玩玩？",
                                confirmFun: () {
                                  CommonPreferences().isAprilFoolHead.value =
                                      false;
                                  Navigator.popAndPushNamed(
                                      context, HomeRouter.home);
                                },
                              );
                            });
                      } else
                        Navigator.pushNamed(context, AuthRouter.userInfo)
                            .then((_) => setState(() {}));
                    },
                    child: Container(
                        decoration: CommonPreferences().isAprilFoolHead.value
                            ? BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/lake_butt_icons/jokers.png'),
                                    fit: BoxFit.cover),
                              )
                            : BoxDecoration(),
                        child: Padding(
                          padding: const EdgeInsets.all(48.0),
                          child: UserAvatarImage(
                              size: 90, iconColor: Colors.white),
                        )),
                  ),
                ),
                Text(pref.nickname.value,
                    textAlign: TextAlign.center,
                    style: FontManager.YaHeiRegular.copyWith(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    )),
                SizedBox(height: 6),
                GestureDetector(
                    onLongPress: () => showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) => DebugDialog()),
                    child: Text(CommonPreferences().userNumber.value,
                        textAlign: TextAlign.center,
                        style: FontManager.Texta.copyWith(
                            color: CommonPreferences().isSkinUsed.value
                                ? Colors.white
                                : MyColors.deepDust,
                            fontSize: 15))),
                if (CommonPreferences().isSkinUsed.value)
                  Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.bottomRight,
                      child: Row(
                        children: <Widget>[
                          Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, AuthRouter.mailbox),
                            child: Icon(
                              Icons.email_outlined,
                              size: 28,
                              color: Color.fromRGBO(255, 251, 240, 0.5),
                            ),
                          ),
                          SizedBox(width: 15),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                    context, AuthRouter.setting,
                                    arguments: SettingPageArgs(false))
                                .then((value) => this.setState(() {})),
                            child: Image.asset(
                              'assets/images/setting.png',
                              width: 24,
                              height: 24,
                              color: Color.fromRGBO(255, 251, 240, 0.5),
                            ),
                          ),
                          SizedBox(
                            width: 30.w,
                          )
                        ],
                      )),
                SizedBox(height: 40),
                //NavigationWidget(),
                Container(
                  height: 80,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, AuthRouter.userInfo)
                              .then((value) => this.setState(() {})),
                      splashFactory: InkRipple.splashFactory,
                      borderRadius: BorderRadius.circular(12),
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
                        borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onLongPress: () {
                        if (EnvConfig.isDevelop) {
                          Navigator.pushNamed(context, TestRouter.mainPage);
                        }
                      },
                      onTap: () =>
                          Navigator.pushNamed(context, AuthRouter.aboutTwt),
                      splashFactory: InkRipple.splashFactory,
                      borderRadius: BorderRadius.circular(12),
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
                        borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: () {
                        context.read<UpdateManager>().checkUpdate(auto: false);
                      },
                      splashFactory: InkRipple.splashFactory,
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 20),
                          Icon(Icons.update,
                              color: Color.fromRGBO(98, 103, 122, 1), size: 20),
                          SizedBox(width: 10),
                          Text(S.current.check_new, style: textStyle),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(right: 26),
                            child: Text(
                              "${S.current.current_version}: ${EnvConfig.VERSION}",
                              style: FontManager.YaHeiLight.copyWith(
                                color: CommonPreferences().isSkinUsed.value
                                    ? Color(
                                        CommonPreferences().skinColorC.value)
                                    : Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ),
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
                        borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: () => showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) => LogoutDialog()),
                      splashFactory: InkRipple.splashFactory,
                      borderRadius: BorderRadius.circular(12),
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
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) => UserAgreementDialog()),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(),
                        child: Text('《用户协议》',
                            style: FontManager.YaHeiRegular.copyWith(
                                fontSize: 11,
                                color: Color.fromRGBO(98, 103, 122, 1))),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) => PrivacyDialog()),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(),
                        child: Text('《隐私政策》',
                            style: FontManager.YaHeiRegular.copyWith(
                                fontSize: 11,
                                color: Color.fromRGBO(98, 103, 122, 1))),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

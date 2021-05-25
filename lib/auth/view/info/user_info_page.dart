import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/commons/util/router_manager.dart';
import 'package:wei_pei_yang_demo/generated/l10n.dart';
import 'package:wei_pei_yang_demo/commons/util/font_manager.dart';

class UserInfoPage extends StatefulWidget {
  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  var pref = CommonPreferences();

  @override
  Widget build(BuildContext context) {
    final mainTextStyle = FontManager.YaHeiRegular.copyWith(
        fontSize: 14,
        color: Color.fromRGBO(98, 103, 122, 1),
        fontWeight: FontWeight.bold);
    final hintTextStyle = FontManager.YaHeiRegular.copyWith(
        fontSize: 11,
        color: Color.fromRGBO(205, 206, 212, 1),
        fontWeight: FontWeight.w600);
    const arrow = Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 22);
    return Scaffold(
      appBar: AppBar(
          title: Text(S.current.reset_user_info,
              style: FontManager.YaHeiRegular.copyWith(
                  fontSize: 16,
                  color: Color.fromRGBO(36, 43, 69, 1),
                  fontWeight: FontWeight.bold)),
          elevation: 0,
          brightness: Brightness.light,
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(53, 59, 84, 1.0), size: 32),
                onTap: () => Navigator.pop(context)),
          )),
      body: Column(
        children: <Widget>[
          Card(
              margin: EdgeInsets.fromLTRB(20, 30, 20, 5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9)),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 70,
                    child: InkWell(
                      onTap: () {
                        // TODO 修改头像
                        ToastProvider.error('敬请期待');
                      },
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(9)),
                      splashFactory: InkRipple.splashFactory,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: Row(
                          children: <Widget>[
                            Container(
                                width: 150,
                                child: Text(S.current.avatar,
                                    style: mainTextStyle)),
                            Expanded(child: Text('')),
                            Container(
                              height: 45,
                              padding: const EdgeInsets.only(right: 6),
                              child: ClipOval(
                                  child: Image(
                                      image: AssetImage(
                                          'assets/images/user_image.jpg'))),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    height: 1.0,
                    color: Color.fromRGBO(212, 214, 226, 1),
                  ),
                  Container(
                    height: 70,
                    child: InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, AuthRouter.resetName)
                              .then((_) => this.setState(() {})),
                      borderRadius: BorderRadius.zero,
                      splashFactory: InkRipple.splashFactory,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: Row(
                          children: <Widget>[
                            Container(
                                width: 150,
                                child: Text(S.current.user_name,
                                    style: mainTextStyle)),
                            Expanded(child: Text('')),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Text(pref.nickname.value,
                                  style: hintTextStyle),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(right: 11),
                                child: arrow)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    height: 1.0,
                    color: Color.fromRGBO(212, 214, 226, 1),
                  ),
                  Container(
                    height: 70,
                    child: InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, AuthRouter.tjuBind)
                              .then((_) => this.setState(() {})),
                      borderRadius: BorderRadius.zero,
                      splashFactory: InkRipple.splashFactory,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: Row(
                          children: <Widget>[
                            Container(
                                width: 150,
                                child: Text(S.current.office_network,
                                    style: mainTextStyle)),
                            Expanded(child: Text('')),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Text(
                                  pref.isBindTju.value
                                      ? S.current.is_bind
                                      : S.current.not_bind,
                                  style: hintTextStyle),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(right: 11),
                                child: arrow)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    height: 1.0,
                    color: Color.fromRGBO(212, 214, 226, 1),
                  ),
                  Container(
                    height: 70,
                    child: InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, AuthRouter.resetPassword)
                              .then((_) => this.setState(() {})),
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(9)),
                      splashFactory: InkRipple.splashFactory,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: Row(
                          children: <Widget>[
                            Container(
                                width: 150,
                                child: Text(S.current.reset_password,
                                    style: mainTextStyle)),
                            Expanded(child: Text('')),
                            Padding(
                                padding: const EdgeInsets.only(right: 11),
                                child: arrow)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )),
          Card(
              margin: EdgeInsets.fromLTRB(20, 15, 20, 5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9)),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 70,
                    child: InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, AuthRouter.phoneBind)
                              .then((_) => this.setState(() {})),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(9)),
                      splashFactory: InkRipple.splashFactory,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 20,
                              margin: const EdgeInsets.only(right: 15),
                              child: Image.asset('assets/images/telephone.png'),
                            ),
                            Container(
                                width: 150,
                                child: Text(S.current.phone2,
                                    style: mainTextStyle)),
                            Expanded(child: Text('')),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Text(
                                  (pref.phone.value != "")
                                      ? S.current.is_bind
                                      : S.current.not_bind,
                                  style: hintTextStyle),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(right: 11),
                                child: arrow)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    height: 1.0,
                    color: Color.fromRGBO(212, 214, 226, 1),
                  ),
                  Container(
                    height: 70,
                    child: InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, AuthRouter.emailBind)
                              .then((_) => this.setState(() {})),
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(9)),
                      splashFactory: InkRipple.splashFactory,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 20,
                              margin: const EdgeInsets.only(right: 15),
                              child: Image.asset('assets/images/email.png'),
                            ),
                            Container(
                                width: 150,
                                child: Text(S.current.email2,
                                    style: mainTextStyle)),
                            Expanded(child: Text('')),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Text(
                                  (pref.email.value != "")
                                      ? S.current.is_bind
                                      : S.current.not_bind,
                                  style: hintTextStyle),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(right: 11),
                                child: arrow)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

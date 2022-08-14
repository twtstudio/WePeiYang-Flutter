import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/auth/view/info/unbind_dialogs.dart';
import 'package:we_pei_yang_flutter/auth/view/user/user_avatar_image.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class UserInfoPage extends StatefulWidget {
  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
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
                    color: Color.fromRGBO(53, 59, 84, 1), size: 32),
                onTap: () => Navigator.pop(context)),
          )),
      body: Column(
        children: <Widget>[
          Card(
              margin: const EdgeInsets.fromLTRB(20, 30, 20, 5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9)),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 70,
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                    child: InkWell(
                      onTap: () async {
                        Navigator.pushNamed(context, AuthRouter.avatarCrop)
                            .then((_) => this.setState(() {}));
                      },
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(9)),
                      splashFactory: InkRipple.splashFactory,
                      child: Row(
                        children: <Widget>[
                          Text(S.current.avatar, style: mainTextStyle),
                          Spacer(),
                          Hero(
                            tag: 'avatar',
                            child: UserAvatarImage(size: 45),
                          ),
                          SizedBox(width: 6),
                          arrow,
                          SizedBox(width: 11)
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    height: 1,
                    color: Color.fromRGBO(212, 214, 226, 1),
                  ),
                  SizedBox(
                    height: 70,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AuthRouter.resetName)
                            .then((_) => this.setState(() {}));
                      },
                      borderRadius: BorderRadius.zero,
                      splashFactory: InkRipple.splashFactory,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: <Widget>[
                            Text(S.current.user_name, style: mainTextStyle),
                            Expanded(
                              child: Text(
                                CommonPreferences.nickname.value,
                                style: hintTextStyle,
                                textAlign: TextAlign.end,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 10),
                            arrow,
                            SizedBox(width: 11)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    height: 1,
                    color: Color.fromRGBO(212, 214, 226, 1),
                  ),
                  SizedBox(
                    height: 70,
                    child: InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, AuthRouter.tjuBind)
                              .then((_) => this.setState(() {})),
                      borderRadius: BorderRadius.zero,
                      splashFactory: InkRipple.splashFactory,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: <Widget>[
                            Text(S.current.office_network,
                                style: mainTextStyle),
                            Spacer(),
                            Text(
                                CommonPreferences.isBindTju.value
                                    ? S.current.is_bind
                                    : S.current.not_bind,
                                style: hintTextStyle),
                            SizedBox(width: 10),
                            arrow,
                            SizedBox(width: 11)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    height: 1,
                    color: Color.fromRGBO(212, 214, 226, 1),
                  ),
                  SizedBox(
                    height: 70,
                    child: InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, AuthRouter.resetPassword)
                              .then((_) => this.setState(() {})),
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(9)),
                      splashFactory: InkRipple.splashFactory,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: <Widget>[
                            Text(S.current.reset_password,
                                style: mainTextStyle),
                            Spacer(),
                            arrow,
                            SizedBox(width: 11)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )),
          Card(
            margin: const EdgeInsets.fromLTRB(20, 15, 20, 5),
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
            child: SizedBox(
              height: 70,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, FeedbackRouter.profile)
                        .then((_) => this.setState(() {}));
                },
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(9)),
                splashFactory: InkRipple.splashFactory,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: <Widget>[
                      Text('更改求实论坛相关', style: mainTextStyle),
                      Spacer(),
                      arrow,
                      SizedBox(width: 11)
                    ],
                  ),
                ),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.fromLTRB(20, 15, 20, 5),
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 70,
                  child: InkWell(
                    onTap: () =>
                        Navigator.pushNamed(context, AuthRouter.phoneBind)
                            .then((_) => this.setState(() {})),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(9)),
                    splashFactory: InkRipple.splashFactory,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: <Widget>[
                          Image.asset('assets/images/telephone.png', width: 20),
                          SizedBox(width: 15),
                          Text(S.current.phone2, style: mainTextStyle),
                          Spacer(),
                          Text(
                              (CommonPreferences.phone.value != "")
                                  ? S.current.is_bind
                                  : S.current.not_bind,
                              style: hintTextStyle),
                          SizedBox(width: 10),
                          arrow,
                          SizedBox(width: 11)
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  height: 1,
                  color: Color.fromRGBO(212, 214, 226, 1),
                ),
                SizedBox(
                  height: 70,
                  child: InkWell(
                    onTap: () =>
                        Navigator.pushNamed(context, AuthRouter.emailBind)
                            .then((_) => this.setState(() {})),
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(9)),
                    splashFactory: InkRipple.splashFactory,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: <Widget>[
                          Image.asset('assets/images/email.png', width: 20),
                          SizedBox(width: 15),
                          Text(S.current.email2, style: mainTextStyle),
                          Spacer(),
                          Text(
                              (CommonPreferences.email.value != "")
                                  ? S.current.is_bind
                                  : S.current.not_bind,
                              style: hintTextStyle),
                          SizedBox(width: 10),
                          arrow,
                          SizedBox(width: 11)
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Card(
              margin: const EdgeInsets.fromLTRB(20, 15, 20, 5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9)),
              child: SizedBox(
                height: 65,
                child: InkWell(
                  onTap: () => showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) => LogoffDialog()),
                  borderRadius: BorderRadius.circular(9),
                  splashFactory: InkRipple.splashFactory,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: <Widget>[
                        Text('注销账号', style: mainTextStyle),
                        Spacer(),
                        arrow,
                        SizedBox(width: 11)
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';

class UserInfoPage extends StatefulWidget {
  final _state = _UserInfoPageState();

  @override
  _UserInfoPageState createState() => _state;
}

class _UserInfoPageState extends State<UserInfoPage> {
  var pref = CommonPreferences();

  @override
  Widget build(BuildContext context) {
    const mainTextStyle = TextStyle(
        fontSize: 15,
        color: Color.fromRGBO(98, 103, 122, 1),
        fontWeight: FontWeight.bold);
    const hintTextStyle = TextStyle(
        fontSize: 11,
        color: Color.fromRGBO(205, 206, 212, 1),
        fontWeight: FontWeight.w600);
    const arrow = Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 22);
    return Scaffold(
      appBar: AppBar(
          title: Text('个人信息更改',
              style: TextStyle(
                  fontSize: 18,
                  color: Color.fromRGBO(36, 43, 69, 1),
                  fontWeight: FontWeight.bold)),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(left: 5),
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
                        ToastProvider.error('还没做呢，悲');
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
                                child: Text('头像', style: mainTextStyle)),
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
                    color: Color.fromRGBO(172, 174, 186, 1),
                  ),
                  Container(
                    height: 70,
                    child: InkWell(
                      onTap: () {
                        // TODO 修改用户名
                        ToastProvider.error('还没做呢，悲');
                      },
                      borderRadius: BorderRadius.zero,
                      splashFactory: InkRipple.splashFactory,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: Row(
                          children: <Widget>[
                            Container(
                                width: 150,
                                child: Text('用户名', style: mainTextStyle)),
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
                    color: Color.fromRGBO(172, 174, 186, 1),
                  ),
                  Container(
                    height: 70,
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, '/tjuBind')
                          .then((_) => widget._state.setState(() {})),
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
                                child: Text('办公网', style: mainTextStyle)),
                            Expanded(child: Text('')),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Text(pref.isBindTju.value ? "已绑定" : "未绑定",
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
                      onTap: () => Navigator.pushNamed(context, '/phoneBind')
                          .then((_) => widget._state.setState(() {})),
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
                              margin: const EdgeInsets.only(right: 10),
                              child: Image.asset('assets/images/telephone.png',
                                  color: Colors.grey),
                            ),
                            Container(
                                width: 150,
                                child: Text('电话', style: mainTextStyle)),
                            Expanded(child: Text('')),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Text(
                                  (pref.phone.value != "") ? "已绑定" : "未绑定",
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
                    color: Color.fromRGBO(172, 174, 186, 1),
                  ),
                  Container(
                    height: 70,
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, '/emailBind')
                          .then((_) => widget._state.setState(() {})),
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
                              margin: const EdgeInsets.only(right: 10),
                              child: Image.asset('assets/images/email.png',
                                  color: Colors.grey),
                            ),
                            Container(
                                width: 150,
                                child: Text('邮箱', style: mainTextStyle)),
                            Expanded(child: Text('')),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Text(
                                  (pref.email.value != "") ? "已绑定" : "未绑定",
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

import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/auth/network/auth_service.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/home/model/home_model.dart';
import 'find_pw_dialog.dart';
import 'package:wei_pei_yang_demo/commons/util/router_manager.dart';
import 'package:wei_pei_yang_demo/generated/l10n.dart';
import 'package:wei_pei_yang_demo/commons/util/font_manager.dart';

class FindPwWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          elevation: 0,
          brightness: Brightness.light,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(98, 103, 123, 1), size: 35),
                onTap: () => Navigator.pop(context)),
          )),
      body: Column(
        children: [
          Expanded(child: Text(""), flex: 1),
          Container(
            alignment: Alignment.center,
            child: Text(S.current.find_password_title,
                style: FontManager.YaHeiRegular.copyWith(
                    color: Color.fromRGBO(98, 103, 123, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          Container(
            height: 50,
            width: 200,
            margin: const EdgeInsets.only(top: 40),
            child: RaisedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AuthRouter.findPhone),
              color: Color.fromRGBO(53, 59, 84, 1.0),
              splashColor: Color.fromRGBO(103, 110, 150, 1.0),
              child: Text(S.current.has_bind_phone,
                  style: FontManager.YaHeiRegular.copyWith(
                      color: Colors.white, fontSize: 13)),
              elevation: 3.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
            ),
          ),
          Container(
            height: 50,
            width: 200,
            margin: const EdgeInsets.only(top: 25),
            child: RaisedButton(
              onPressed: () => showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) => FindPwDialog()),
              color: Color.fromRGBO(53, 59, 84, 1.0),
              splashColor: Color.fromRGBO(103, 110, 150, 1.0),
              child: Text(S.current.has_not_bind_phone,
                  style: FontManager.YaHeiRegular.copyWith(
                      color: Colors.white, fontSize: 13)),
              elevation: 3.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
            ),
          ),
          Expanded(child: Text(""), flex: 2),
        ],
      ),
    );
  }
}

class FindPwByPhoneWidget extends StatefulWidget {
  @override
  _FindPwByPhoneWidgetState createState() => _FindPwByPhoneWidgetState();
}

class _FindPwByPhoneWidgetState extends State<FindPwByPhoneWidget> {
  String phone = "";
  String code = "";
  bool isPress = false;

  _fetchCaptcha() async {
    if (phone == "") {
      ToastProvider.error("手机号码不能为空");
      return;
    }
    getCaptchaOnReset(phone,
        onSuccess: () {
          setState(() => isPress = true);
        },
        onFailure: (e) => ToastProvider.error(e.error));
  }

  _verifyCaptcha() async {
    if (phone == "") {
      ToastProvider.error("手机号码不能为空");
      return;
    } else if (code == "") {
      ToastProvider.error("短信验证码不能为空");
      return;
    }
    verifyOnReset(phone, code,
        onSuccess: () =>
            Navigator.pushNamed(context, AuthRouter.resetPw, arguments: phone),
        onFailure: (e) => ToastProvider.error(e.error));
  }

  static final TextStyle _hintStyle = FontManager.YaHeiRegular.copyWith(
      color: Color.fromRGBO(201, 204, 209, 1), fontSize: 13);

  @override
  Widget build(BuildContext context) {
    double width = GlobalModel().screenWidth - 80;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          elevation: 0,
          brightness: Brightness.light,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(98, 103, 123, 1), size: 35),
                onTap: () => Navigator.pop(context)),
          )),
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: Text(S.current.find_password_title,
                style: FontManager.YaHeiRegular.copyWith(
                    color: Color.fromRGBO(98, 103, 123, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 40, 30, 0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 55,
              ),
              child: TextField(
                decoration: InputDecoration(
                    hintText: S.current.phone,
                    hintStyle: _hintStyle,
                    filled: true,
                    fillColor: Color.fromRGBO(235, 238, 243, 1),
                    isCollapsed: true,
                    contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 22),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none)),
                onChanged: (input) => setState(() => phone = input),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
            child: Row(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 55,
                    maxWidth: width / 2 + 20,
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: S.current.text_captcha,
                        hintStyle: _hintStyle,
                        filled: true,
                        fillColor: Color.fromRGBO(235, 238, 243, 1),
                        isCollapsed: true,
                        contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 22),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none)),
                    onChanged: (input) => setState(() => code = input),
                  ),
                ),
                Container(
                    height: 55,
                    width: width / 2 - 20,
                    margin: const EdgeInsets.only(left: 20),
                    child: isPress
                        ? StreamBuilder<int>(
                            stream: Stream.periodic(
                                    Duration(seconds: 1), (time) => time + 1)
                                .take(60),
                            builder: (context, snap) {
                              var time = 60 - (snap.data ?? 0);
                              if (time == 0)
                                WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => setState(() => isPress = false));
                              return RaisedButton(
                                onPressed: () {},
                                color: Colors.grey[300],
                                splashColor: Colors.grey[300],
                                child: Text('$time秒后重试',
                                    style: FontManager.YaHeiRegular.copyWith(
                                        color: Color.fromRGBO(98, 103, 123, 1),
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              );
                            })
                        : RaisedButton(
                            onPressed: _fetchCaptcha,
                            color: Color.fromRGBO(53, 59, 84, 1.0),
                            splashColor: Color.fromRGBO(103, 110, 150, 1.0),
                            child: Text(S.current.fetch_captcha,
                                style: FontManager.YaHeiRegular.copyWith(
                                    color: Colors.white, fontSize: 13)),
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          )),
              ],
            ),
          ),
          Expanded(child: Text("")),
          Container(
            height: 50,
            alignment: Alignment.bottomRight,
            margin: const EdgeInsets.all(30),
            child: GestureDetector(
              onTap: _verifyCaptcha,
              child: Image(image: AssetImage('assets/images/arrow_round.png')),
            ),
          ),
        ],
      ),
    );
  }

  Stream<int> timerStream() async* {
    yield 1;
  }
}

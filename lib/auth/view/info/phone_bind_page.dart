import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/auth/network/auth_service.dart';
import 'package:wei_pei_yang_demo/auth/view/info/unbind_dialogs.dart';
import 'package:wei_pei_yang_demo/commons/res/color.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/home/model/home_model.dart';
import 'package:wei_pei_yang_demo/generated/l10n.dart';
import 'package:wei_pei_yang_demo/commons/util/font_manager.dart';

class PhoneBindPage extends StatefulWidget {
  @override
  _PhoneBindPageState createState() => _PhoneBindPageState();
}

class _PhoneBindPageState extends State<PhoneBindPage> {
  var pref = CommonPreferences();
  String phone = "";
  String code = "";
  bool isPress = false;

  void _fetchCaptcha() async {
    if (phone == "") {
      ToastProvider.error("手机号码不能为空");
      return;
    }
    getCaptchaOnInfo(phone,
        onSuccess: () {
          setState(() => isPress = true);
        },
        onFailure: (e) => ToastProvider.error(e.error));
  }

  _bind() async {
    if (phone == "") {
      ToastProvider.error("手机号码不能为空");
      return;
    } else if (code == "") {
      ToastProvider.error("短信验证码不能为空");
      return;
    }
    changePhone(phone, code,
        onSuccess: () {
          ToastProvider.success("手机号码绑定成功");
          setState(() {});
        },
        onFailure: (e) => ToastProvider.error(e.error));
  }

  Widget _detail(BuildContext context) {
    var hintStyle = FontManager.YaHeiRegular.copyWith(
        color: Color.fromRGBO(201, 204, 209, 1), fontSize: 13);
    double width = GlobalModel().screenWidth - 80;
    if (pref.phone.value != "")
      return Column(children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(0, 70, 0, 95),
          child: Text("${S.current.bind_phone}: ${pref.phone.value}",
              style: FontManager.YaHeiRegular.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color.fromRGBO(79, 88, 107, 1))),
        ),
        Container(
          height: 50,
          width: 120,
          child: RaisedButton(
            onPressed: () => showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) => PhoneUnbindDialog())
                .then((_) => this.setState(() {})),
            color: Color.fromRGBO(79, 88, 107, 1),
            splashColor: MyColors.brightBlue,
            child: Text(S.current.unbind,
                style: FontManager.YaHeiRegular.copyWith(
                    color: Colors.white, fontSize: 13)),
            elevation: 3.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
          ),
        ),
      ]);
    else {
      return Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 55,
            ),
            child: TextField(
              decoration: InputDecoration(
                  hintText: S.current.phone,
                  hintStyle: hintStyle,
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
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                      hintText: S.current.text_captcha,
                      hintStyle: hintStyle,
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
        Container(
            height: 50.0,
            width: 400.0,
            margin: EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0.0),
            child: RaisedButton(
              onPressed: _bind,
              color: Color.fromRGBO(53, 59, 84, 1.0),
              splashColor: Color.fromRGBO(103, 110, 150, 1.0),
              child: Text(S.current.bind,
                  style: FontManager.YaHeiRegular.copyWith(
                      color: Colors.white, fontSize: 13)),
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
            )),
      ]);
    }
  }

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
                    color: Color.fromRGBO(53, 59, 84, 1.0), size: 32),
                onTap: () => Navigator.pop(context)),
          )),
      body: Column(
        children: [
          Row(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.fromLTRB(35, 20, 20, 20),
                child: Text(S.current.phone_bind,
                    style: FontManager.YaQiHei.copyWith(
                        color: Color.fromRGBO(48, 60, 102, 1),
                        fontWeight: FontWeight.bold,
                        fontSize: 28)),
              ),
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 32, 0, 20),
                    child: Text(
                        (pref.phone.value != "")
                            ? S.current.is_bind
                            : S.current.not_bind,
                        style: FontManager.YaHeiRegular.copyWith(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          _detail(context)
        ],
      ),
    );
  }
}

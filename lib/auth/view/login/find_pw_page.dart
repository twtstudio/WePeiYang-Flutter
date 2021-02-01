import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/auth/network/auth_service.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'find_pw_dialog.dart';

class FindPwWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 5),
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
            child: Text("天外天账号密码找回",
                style: TextStyle(
                    color: Color.fromRGBO(98, 103, 123, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          Container(
            height: 50,
            width: 200,
            margin: const EdgeInsets.only(top: 25),
            child: RaisedButton(
              onPressed: () => Navigator.pushNamed(context, '/find_phone'),
              color: Color.fromRGBO(53, 59, 84, 1.0),
              splashColor: Color.fromRGBO(103, 110, 150, 1.0),
              child: Text('账号已绑定手机号',
                  style: TextStyle(color: Colors.white, fontSize: 15)),
              elevation: 3.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
            ),
          ),
          Container(
            height: 50,
            width: 200,
            margin: const EdgeInsets.only(top: 30),
            child: RaisedButton(
              onPressed: () => showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) => FindPwDialog()),
              color: Color.fromRGBO(53, 59, 84, 1.0),
              splashColor: Color.fromRGBO(103, 110, 150, 1.0),
              child: Text('账号未绑定手机号',
                  style: TextStyle(color: Colors.white, fontSize: 15)),
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
        onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  _verifyCaptcha() async {
    setState(() => isPress = false);
    if (phone == "") {
      ToastProvider.error("手机号码不能为空");
      return;
    } else if (code == "") {
      ToastProvider.error("短信验证码不能为空");
      return;
    }
    Navigator.pushNamed(context, '/reset', arguments: phone);
    // verifyOnReset(phone, code,
    //     onSuccess: () => Navigator.pushNamed(context, '/reset', arguments: phone),
    //     onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(98, 103, 123, 1), size: 35),
                onTap: () => Navigator.pop(context)),
          )),
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: Text("天外天账号密码找回",
                style: TextStyle(
                    color: Color.fromRGBO(98, 103, 123, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
            child: Theme(
              data: ThemeData(hintColor: Color.fromRGBO(98, 103, 123, 1)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 100,
                ),
                child: TextField(
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                      labelText: '手机号',
                      filled: true,
                      fillColor: Color.fromRGBO(235, 238, 243, 1),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.fromLTRB(15, 20, 0, 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onChanged: (input) => setState(() => phone = input),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 40, 30, 0),
            child: Row(
              children: [
                Theme(
                  data: ThemeData(hintColor: Color.fromRGBO(98, 103, 123, 1)),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 100,
                      maxWidth: 150,
                    ),
                    child: TextField(
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                          labelText: '短信验证码',
                          filled: true,
                          fillColor: Color.fromRGBO(235, 238, 243, 1),
                          isCollapsed: true,
                          contentPadding: EdgeInsets.fromLTRB(15, 20, 0, 20),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onChanged: (input) => setState(() => code = input),
                    ),
                  ),
                ),
                Expanded(child: Text("")),
                Container(
                    height: 55,
                    width: 120,
                    margin: const EdgeInsets.only(left: 20),
                    child: RaisedButton(
                      onPressed: _fetchCaptcha,
                      color: isPress
                          ? Color.fromRGBO(235, 238, 243, 1)
                          : Color.fromRGBO(53, 59, 84, 1.0),
                      splashColor: Color.fromRGBO(103, 110, 150, 1.0),
                      child: Text('获取验证码',
                          style: TextStyle(
                              color: isPress
                                  ? Color.fromRGBO(201, 204, 209, 1)
                                  : Colors.white,
                              fontSize: 16)),
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
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
}

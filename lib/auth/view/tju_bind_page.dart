import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart' show Fluttertoast;
import 'package:wei_pei_yang_demo/commons/color.dart';
import 'package:wei_pei_yang_demo/commons/network/spider_service.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';

class TjuBindWidget extends StatefulWidget {
  @override
  _TjuBindWidgetState createState() => _TjuBindWidgetState();
}

class _TjuBindWidgetState extends State<TjuBindWidget> {
  var tjuuname = "";
  var tjupasswd = "";
  var captcha = "";

  TextEditingController nameController;
  TextEditingController pwController;
  Map<String, String> params = Map();
  Widget imageWidget = Container(width: 140, height: 60);

  @override
  void initState() {
    var prefs = CommonPreferences.create();
    tjuuname = prefs.tjuuname;
    tjupasswd = prefs.tjupasswd;
    nameController =
        TextEditingController.fromValue(TextEditingValue(text: tjuuname));
    pwController =
        TextEditingController.fromValue(TextEditingValue(text: tjupasswd));
    getExecAndSession(onSuccess: (map) {
      params = map;

      /// TODO 这里会报错 DioError [DioErrorType.RESPONSE]: Http status error [302]
      setState(() {
        imageWidget = Image.network(
            "https://sso.tju.edu.cn/cas/images/kaptcha.jpg",
            headers: {"Cookie": map['session']},
            width: 140,
            height: 80,
            fit: BoxFit.fill);
      });
    });
    super.initState();
  }

  //TODO 输入框action icon
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Image.asset('assets/images/ic_tju_icon.png',
                  fit: BoxFit.cover, width: 160, height: 160),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text('办公网绑定',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 25, 25, 15),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                    labelText: '输入办公网账号',
                    contentPadding: EdgeInsets.only(top: 5.0)),
                onChanged: (input) => setState(() => tjuuname = input),
                onTap: () => nameController.clear(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 20),
              child: TextField(
                obscureText: true,
                controller: pwController,
                decoration: InputDecoration(
                    labelText: '输入办公网密码',
                    contentPadding: EdgeInsets.only(top: 5.0)),
                onChanged: (input) => setState(() => tjupasswd = input),
                onTap: () => pwController.clear(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                children: [
                  Container(
                    width: 200,
                    child: TextField(
                      decoration: InputDecoration(
                          labelText: '输入验证码',
                          contentPadding: EdgeInsets.only(top: 5.0)),
                      onChanged: (input) => setState(() => captcha = input),
                    ),
                  ),
                  imageWidget,
                ],
              ),
            ),
            Container(
              height: 50,
              width: 250,
              margin: const EdgeInsets.only(top: 30),
              child: RaisedButton(
                onPressed: () {
                  if (tjuuname == "" || tjupasswd == "" || captcha == "") {
                    var message = "";
                    if (tjuuname == "")
                      message = "用户名不能为空";
                    else if (tjupasswd == "")
                      message = "密码不能为空";
                    else
                      message = "验证码不能为空";
                    Fluttertoast.showToast(
                        msg: message,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    return;
                  }
                  ssoLogin(context, tjuuname, tjupasswd, captcha, params,onSuccess: (){
                    Fluttertoast.showToast(
                        msg: "办公网绑定成功",
                        textColor: Colors.white,
                        backgroundColor: Colors.green,
                        timeInSecForIosWeb: 1,
                        fontSize: 16);
                  },onFailure: (e){
                    Fluttertoast.showToast(
                        msg: e.error.toString(),
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  });
                  captcha = "";
                },
                color: MyColors.deepBlue,
                child: Text('绑定', style: TextStyle(color: Colors.white)),
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

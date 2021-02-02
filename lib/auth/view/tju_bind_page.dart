import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/commons/res/color.dart';
import 'package:wei_pei_yang_demo/commons/network/spider_service.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/gpa/model/gpa_notifier.dart';
import 'package:wei_pei_yang_demo/home/model/home_model.dart';
import 'package:wei_pei_yang_demo/main.dart';
import 'package:wei_pei_yang_demo/schedule/model/schedule_notifier.dart';

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
  Widget imageWidget;
  int index;

  @override
  void initState() {
    var prefs = CommonPreferences();
    tjuuname = prefs.tjuuname.value;
    tjupasswd = prefs.tjupasswd.value;
    nameController =
        TextEditingController.fromValue(TextEditingValue(text: tjuuname));
    pwController =
        TextEditingController.fromValue(TextEditingValue(text: tjupasswd));
    index = GlobalModel().captchaIndex;
    GlobalModel().increase();
    getExecAndSession(onSuccess: (map) {
      params = map;
      setState(() {
        imageWidget = GestureDetector(
          // TODO 点击图片刷新index
          onTap: () {
            setState(() => index++);
            GlobalModel().increase();
          },
          child: Image.network(
              "https://sso.tju.edu.cn/cas/images/kaptcha.jpg?$index",
              headers: {"Cookie": map['session']},
              fit: BoxFit.fill),
        );
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    nameController?.dispose();
    pwController?.dispose();
    super.dispose();
  }

  FocusNode _nameFocus = FocusNode();
  FocusNode _pwFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    var width = GlobalModel().screenWidth;
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
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.next,
                controller: nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(
                    labelText: '输入办公网账号',
                    contentPadding: EdgeInsets.only(top: 5.0)),
                onChanged: (input) => setState(() => tjuuname = input),
                onTap: () {
                  nameController?.clear();
                  nameController = null;
                },
                onEditingComplete: () {
                  _nameFocus.unfocus();
                  FocusScope.of(context).requestFocus(_pwFocus);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 20),
              child: TextField(
                obscureText: true,
                controller: pwController,
                focusNode: _pwFocus,
                decoration: InputDecoration(
                    labelText: '输入办公网密码',
                    contentPadding: EdgeInsets.only(top: 5.0)),
                onChanged: (input) => setState(() => tjupasswd = input),
                onTap: () {
                  pwController?.clear();
                  pwController = null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                children: [
                  Container(
                    width: width / 3,
                    child: TextField(
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                          labelText: '输入验证码',
                          contentPadding: EdgeInsets.only(top: 5.0)),
                      onChanged: (input) => setState(() => captcha = input),
                    ),
                  ),
                  Expanded(child: Text("")),
                  Container(
                      child: imageWidget,
                      width: 140,
                      height: 80,
                      alignment: Alignment.centerRight),
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
                    ToastProvider.error(message);
                    return;
                  }
                  login(context, tjuuname, tjupasswd, captcha, params,
                      onSuccess: () {
                        ToastProvider.success("办公网绑定成功");
                        Provider.of<GPANotifier>(context)
                            .refreshGPA(hint: false)
                            .call();
                        Provider.of<ScheduleNotifier>(context)
                            .refreshSchedule(hint: false)
                            .call();
                        Navigator.pop(context);
                      },
                      onFailure: (e) =>
                          ToastProvider.error(e.error.toString()));
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/auth/view/info/unbind_dialogs.dart';
import 'package:wei_pei_yang_demo/commons/res/color.dart';
import 'package:wei_pei_yang_demo/commons/new_network/spider_service.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/gpa/model/gpa_notifier.dart';
import 'package:wei_pei_yang_demo/schedule/model/schedule_notifier.dart';
import 'package:wei_pei_yang_demo/home/model/home_model.dart';

class TjuBindPage extends StatefulWidget {
  @override
  _TjuBindPageState createState() => _TjuBindPageState();
}

class _TjuBindPageState extends State<TjuBindPage> {
  var pref = CommonPreferences();
  String tjuuname = "";
  String tjupasswd = "";
  String captcha = "";

  TextEditingController nameController;
  TextEditingController pwController;
  TextEditingController codeController = TextEditingController();
  GlobalKey<CaptchaWidgetState> captchaKey = GlobalKey();
  CaptchaWidget captchaWidget;

  @override
  void initState() {
    captchaWidget = CaptchaWidget(captchaKey);
    if (pref.isBindTju.value) {
      super.initState();
      return;
    }
    print("name: ${pref.tjuuname.value}");
    print("pw: ${pref.tjupasswd.value}");
    tjuuname = pref.tjuuname.value;
    tjupasswd = pref.tjupasswd.value;
    nameController =
        TextEditingController.fromValue(TextEditingValue(text: tjuuname));
    pwController =
        TextEditingController.fromValue(TextEditingValue(text: tjupasswd));
    super.initState();
  }

  @override
  void dispose() {
    nameController?.dispose();
    pwController?.dispose();
    codeController?.dispose();
    super.dispose();
  }

  void _bind() {
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
    login(context, tjuuname, tjupasswd, captcha, captchaWidget.params,
        onSuccess: () {
      ToastProvider.success("办公网绑定成功");
      Provider.of<GPANotifier>(context, listen: false)
          .refreshGPA(hint: false)
          .call();
      Provider.of<ScheduleNotifier>(context, listen: false)
          .refreshSchedule(hint: false)
          .call();
      setState(() {});
    }, onFailure: (e) {
      ToastProvider.error(e.error);
      captchaKey.currentState.refresh();
    });
    codeController.clear();
  }

  FocusNode _accountFocus = FocusNode();
  FocusNode _passwordFocus = FocusNode();

  Widget _detail(BuildContext context) {
    var hintStyle =
        TextStyle(color: Color.fromRGBO(201, 204, 209, 1), fontSize: 13);
    double width = GlobalModel().screenWidth - 80;
    if (pref.isBindTju.value)
      return Column(children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(0, 50, 0, 60),
          child: Text('绑定账号：${pref.tjuuname.value}',
              style: TextStyle(
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
                    builder: (BuildContext context) => TjuUnbindDialog())
                .then((_) => this.setState(() {})),
            color: Color.fromRGBO(79, 88, 107, 1),
            splashColor: MyColors.brightBlue,
            child: Text('解除绑定',
                style: TextStyle(color: Colors.white, fontSize: 14)),
            elevation: 3.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
          ),
        ),
      ]);
    else {
      return Column(children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(60, 20, 60, 10),
          child: Text(
            '只有绑定了办公网后才能正常使用课表、GPA、校务专区功能。 若忘记密码请前往办公网找回。',
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 10, color: Color.fromRGBO(98, 103, 124, 1)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 55,
            ),
            child: TextField(
              textInputAction: TextInputAction.next,
              controller: nameController,
              focusNode: _accountFocus,
              decoration: InputDecoration(
                  hintText: '办公网账号',
                  hintStyle: hintStyle,
                  filled: true,
                  fillColor: Color.fromRGBO(235, 238, 243, 1),
                  isCollapsed: true,
                  contentPadding: EdgeInsets.fromLTRB(15, 20, 0, 20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none)),
              onChanged: (input) => setState(() => tjuuname = input),
              onTap: () {
                nameController?.clear();
                nameController = null;
              },
              onEditingComplete: () {
                _accountFocus.unfocus();
                FocusScope.of(context).requestFocus(_passwordFocus);
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 55,
            ),
            child: TextField(
              keyboardType: TextInputType.visiblePassword,
              controller: pwController,
              focusNode: _passwordFocus,
              decoration: InputDecoration(
                  hintText: '密码',
                  hintStyle: hintStyle,
                  filled: true,
                  fillColor: Color.fromRGBO(235, 238, 243, 1),
                  isCollapsed: true,
                  contentPadding: EdgeInsets.fromLTRB(15, 20, 0, 20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none)),
              obscureText: true,
              onChanged: (input) => setState(() => tjupasswd = input),
              onTap: () {
                pwController?.clear();
                pwController = null;
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 20, 30, 35),
          child: Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 55,
                  maxWidth: width - 120,
                ),
                child: TextField(
                  controller: codeController,
                  decoration: InputDecoration(
                      hintText: '验证码',
                      hintStyle: hintStyle,
                      filled: true,
                      fillColor: Color.fromRGBO(235, 238, 243, 1),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.fromLTRB(15, 20, 0, 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none)),
                  onChanged: (input) => setState(() => captcha = input),
                ),
              ),
              Container(
                  height: 55,
                  width: 120,
                  margin: const EdgeInsets.only(left: 20),
                  alignment: Alignment.centerRight,
                  child: captchaWidget)
            ],
          ),
        ),
        Container(
            height: 50.0,
            width: 400.0,
            padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
            child: RaisedButton(
              onPressed: _bind,
              color: Color.fromRGBO(53, 59, 84, 1.0),
              splashColor: Color.fromRGBO(103, 110, 150, 1.0),
              child: Text('绑定',
                  style: TextStyle(color: Colors.white, fontSize: 14)),
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
            )),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    var pref = CommonPreferences();
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          elevation: 0,
          brightness: Brightness.light,
          leading: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(53, 59, 84, 1.0), size: 32),
                onTap: () => Navigator.pop(context)),
          )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.fromLTRB(35, 20, 20, 50),
                  child: Text("办公网账号绑定",
                      style: TextStyle(
                          color: Color.fromRGBO(48, 60, 102, 1),
                          fontWeight: FontWeight.bold,
                          fontSize: 28)),
                ),
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 32, 0, 50),
                      child: Text(pref.isBindTju.value ? "已绑定" : "未绑定",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),

            /// 已绑定/未绑定时三个图标的高度不一样，所以加个container控制一下
            Container(height: pref.isBindTju.value ? 20 : 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 50,
                    width: 50,
                    child: Image.asset('assets/images/tju_work.png')),
                Container(
                    height: 25,
                    width: 25,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Image.asset('assets/images/bind.png')),
                Container(
                    height: 50,
                    width: 50,
                    child: Image.asset('assets/images/twt_round.png')),
              ],
            ),
            _detail(context)
          ],
        ),
      ),
    );
  }
}

class CaptchaWidget extends StatefulWidget {
  final Map<String, String> params = Map();

  CaptchaWidget(Key key) : super(key: key);

  @override
  CaptchaWidgetState createState() => CaptchaWidgetState();
}

class CaptchaWidgetState extends State<CaptchaWidget> {
  int index;

  void refresh() {
    setState(() => index++);
    GlobalModel().increase();
  }

  @override
  void initState() {
    index = GlobalModel().captchaIndex;
    GlobalModel().increase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getExecAndSession(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            Map map = snapshot.data;
            widget.params.clear();
            widget.params.addAll(map);
            return InkWell(
              onTap: refresh,
              child: Image.network(
                  "https://sso.tju.edu.cn/cas/images/kaptcha.jpg?$index",
                  key: ValueKey(index),
                  headers: {"Cookie": map['session']},
                  fit: BoxFit.fill),
            );
          } else
            return Container();
        });
  }
}

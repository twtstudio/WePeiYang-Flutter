import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:we_pei_yang_flutter/auth/view/info/unbind_dialogs.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/network/spider_service.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/gpa/model/gpa_notifier.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';

class TjuBindPage extends StatefulWidget {
  @override
  _TjuBindPageState createState() => _TjuBindPageState();
}

class _TjuBindPageState extends State<TjuBindPage> {
  String tjuuname = "";
  String tjupasswd = "";
  String captcha = "";

  TextEditingController nameController;
  TextEditingController pwController;
  TextEditingController codeController;
  GlobalKey<CaptchaWidgetState> captchaKey;
  CaptchaWidget captchaWidget;

  @override
  void initState() {
    captchaKey = GlobalKey();
    captchaWidget = CaptchaWidget(captchaKey);
    codeController = TextEditingController();
    if (CommonPreferences.isBindTju.value) {
      super.initState();
      return;
    }
    tjuuname = CommonPreferences.tjuuname.value;
    tjupasswd = CommonPreferences.tjupasswd.value;
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
          .refreshGPA(
            onFailure: (e) => ToastProvider.error(e.error.toString()),
          );
      Provider.of<CourseProvider>(context, listen: false).refreshCourse(
        onFailure: (e) => ToastProvider.error(e.error.toString()),
      );
      Provider.of<ExamProvider>(context, listen: false).refreshExam(
        onFailure: (e) => ToastProvider.error(e.error.toString()),
      );
      setState(() {
        tjuuname = "";
        tjupasswd = "";
        nameController = null;
        pwController = null;
      });
    }, onFailure: (e) {
      if (e.error.toString() == '网络连接超时') e.error = '请连接校园网后再次尝试';
      ToastProvider.error(e.error.toString());
      captchaKey.currentState.refresh();
    });
    codeController.clear();
  }

  final FocusNode _accountFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _notRobotFocus = FocusNode();

  final visNotifier = ValueNotifier<bool>(true); // 是否隐藏密码

  Widget _detail(BuildContext context) {
    var hintStyle = FontManager.YaHeiRegular.copyWith(
        color: Color.fromRGBO(201, 204, 209, 1), fontSize: 13);
    if (CommonPreferences.isBindTju.value)
      return Column(children: [
        SizedBox(height: 30),
        Text("${S.current.bind_account}: ${CommonPreferences.tjuuname.value}",
            style: FontManager.YaHeiRegular.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color.fromRGBO(79, 88, 107, 1))),
        SizedBox(height: 60),
        SizedBox(
          height: 50,
          width: 120,
          child: ElevatedButton(
            onPressed: () => showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) => TjuUnbindDialog())
                .then((_) => this.setState(() {})),
            child: Text(S.current.unbind,
                style: FontManager.YaHeiRegular.copyWith(
                    color: Colors.white, fontSize: 13)),
            style: ButtonStyle(
              elevation: MaterialStateProperty.all(3),
              overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.pressed))
                  return MyColors.brightBlue;
                return Color.fromRGBO(79, 88, 107, 1);
              }),
              backgroundColor:
                  MaterialStateProperty.all(Color.fromRGBO(79, 88, 107, 1)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
            ),
          ),
        ),
      ]);
    else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(children: [
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              S.current.tju_bind_hint,
              textAlign: TextAlign.center,
              style: FontManager.YaHeiRegular.copyWith(
                  fontSize: 10, color: Color.fromRGBO(98, 103, 124, 1)),
            ),
          ),
          SizedBox(height: 20),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 55),
            child: TextField(
              textInputAction: TextInputAction.next,
              controller: nameController,
              focusNode: _accountFocus,
              cursorColor: ColorUtil.mainColor,
              decoration: InputDecoration(
                  hintText: S.current.tju_account,
                  hintStyle: hintStyle,
                  filled: true,
                  fillColor: Color.fromRGBO(235, 238, 243, 1),
                  isCollapsed: true,
                  contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 18),
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
          SizedBox(height: 20),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 55),
            child: ValueListenableBuilder(
              valueListenable: visNotifier,
              builder: (context, value, _) {
                return Theme(
                  data: Theme.of(context)
                      .copyWith(primaryColor: Color.fromRGBO(53, 59, 84, 1)),
                  child: TextField(
                    keyboardType: TextInputType.visiblePassword,
                    controller: pwController,
                    focusNode: _passwordFocus,
                    cursorColor: ColorUtil.mainColor,
                    decoration: InputDecoration(
                      hintText: S.current.password,
                      hintStyle: hintStyle,
                      filled: true,
                      fillColor: Color.fromRGBO(235, 238, 243, 1),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 18),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                      suffixIcon: GestureDetector(
                        child: Icon(
                            value ? Icons.visibility_off : Icons.visibility),
                        onTap: () {
                          visNotifier.value = !visNotifier.value;
                        },
                      ),
                    ),
                    obscureText: value,
                    onChanged: (input) => setState(() => tjupasswd = input),
                    onTap: () {
                      pwController?.clear();
                      pwController = null;
                    },
                    onEditingComplete: () {
                      _accountFocus.unfocus();
                      FocusScope.of(context).requestFocus(_notRobotFocus);
                    },
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 55,
                  width: 120,
                  child: TextField(
                    controller: codeController,
                    focusNode: _notRobotFocus,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        hintText: S.current.captcha,
                        hintStyle: hintStyle,
                        filled: true,
                        fillColor: Color.fromRGBO(235, 238, 243, 1),
                        isCollapsed: true,
                        contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 18),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none)),
                    onChanged: (input) => setState(() => captcha = input),
                    onEditingComplete: () {
                      _notRobotFocus.unfocus();
                    },
                  ),
                ),
              ),
              SizedBox(width: 20),
              SizedBox(height: 55, width: 120, child: captchaWidget)
            ],
          ),
          SizedBox(height: 25),
          SizedBox(
            height: 50,
            width: 400,
            child: ElevatedButton(
              onPressed: _bind,
              child: Text(S.current.bind,
                  style: FontManager.YaHeiRegular.copyWith(
                      color: Colors.white, fontSize: 13)),
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(5),
                overlayColor:
                    MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.pressed))
                    return Color.fromRGBO(103, 110, 150, 1);
                  return Color.fromRGBO(53, 59, 84, 1);
                }),
                backgroundColor:
                    MaterialStateProperty.all(Color.fromRGBO(53, 59, 84, 1)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
              ),
            ),
          ),
          SizedBox(height: 35),
          Text(
            '应学校要求，校外使用教育教学信息管理系统需先登录天津大学VPN，'
            '故在校外访问微北洋课表、GPA功能也需登录VPN绑定办公网账号后使用。',
            style: FontManager.YaHeiRegular.copyWith(
                fontSize: 10, color: Color.fromRGBO(98, 103, 124, 1)),
          ),
          Row(
            children: [
              Text(
                '办公网网址为 ',
                style: FontManager.YaHeiRegular.copyWith(
                    fontSize: 10, color: Color.fromRGBO(98, 103, 124, 1)),
              ),
              GestureDetector(
                onTap: () async {
                  String url = 'http://classes.tju.edu.cn/';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    ToastProvider.error('请检查网络状态');
                  }
                },
                child: Text(
                  'classes.tju.edu.cn',
                  style: FontManager.YaHeiRegular.copyWith(
                      fontSize: 10,
                      color: Colors.blue,
                      decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
          SizedBox(height: 35),
        ]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          elevation: 0,
          brightness: Brightness.light,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(53, 59, 84, 1), size: 32),
                onTap: () => Navigator.pop(context)),
          )),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.fromLTRB(35, 10, 20, 50),
                  child: Text(S.current.tju_bind,
                      style: FontManager.YaQiHei.copyWith(
                          color: Color.fromRGBO(48, 60, 102, 1),
                          fontWeight: FontWeight.bold,
                          fontSize: 28)),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 22, 0, 50),
                  child: Text(
                      CommonPreferences.isBindTju.value
                          ? S.current.is_bind
                          : S.current.not_bind,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            /// 已绑定/未绑定时三个图标的高度不一样，所以加个间隔控制一下
            SizedBox(height: CommonPreferences.isBindTju.value ? 20 : 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/tju_work.png',
                    height: 50, width: 50),
                SizedBox(width: 20),
                Image.asset('assets/images/bind.png', height: 25, width: 25),
                SizedBox(width: 20),
                Image.asset('assets/images/twt_round.png',
                    height: 50, width: 50),
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

var _index = 0;

class CaptchaWidgetState extends State<CaptchaWidget> {
  refresh() {
    setState(() => _index++);
  }

  @override
  void dispose() {
    _index++;
    super.dispose();
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
                "https://sso.tju.edu.cn/cas/images/kaptcha.jpg?$_index",
                key: ValueKey(_index),
                headers: {"Cookie": map['session']},
                fit: BoxFit.fill),
          );
        } else {
          return Container();
        }
      },
    );
  }
}

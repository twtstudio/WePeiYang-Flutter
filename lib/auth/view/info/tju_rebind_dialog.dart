import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:we_pei_yang_flutter/auth/view/info/tju_bind_page.dart'
    show CaptchaWidget, CaptchaWidgetState;
import 'package:we_pei_yang_flutter/commons/network/spider_service.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/gpa/model/gpa_notifier.dart';
import 'package:we_pei_yang_flutter/schedule/model/schedule_notifier.dart';

class TjuRebindDialog extends Dialog {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 35),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.white),
        child: Material(
          color: Colors.white,
          child: _TjuRebindWidget(),
        ),
      ),
    );
  }
}

class _TjuRebindWidget extends StatefulWidget {
  @override
  _TjuRebindWidgetState createState() => _TjuRebindWidgetState();
}

class _TjuRebindWidgetState extends State<_TjuRebindWidget> {
  String tjuuname = "";
  String tjupasswd = "";
  String captcha = "";

  TextEditingController nameController;
  TextEditingController pwController;
  TextEditingController codeController = TextEditingController();
  final GlobalKey<CaptchaWidgetState> captchaKey = GlobalKey();
  CaptchaWidget captchaWidget;

  @override
  void initState() {
    super.initState();
    captchaWidget = CaptchaWidget(captchaKey);
    var pref = CommonPreferences();
    tjuuname = pref.tjuuname.value;
    tjupasswd = pref.tjupasswd.value;
    nameController =
        TextEditingController.fromValue(TextEditingValue(text: tjuuname));
    pwController =
        TextEditingController.fromValue(TextEditingValue(text: tjupasswd));
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
      ToastProvider.success("办公网重新绑定成功");
      Provider.of<GPANotifier>(context, listen: false)
          .refreshGPA(hint: false)
          .call();
      Provider.of<ScheduleNotifier>(context, listen: false)
          .refreshSchedule(hint: false)
          .call();
      Navigator.pop(context);
    }, onFailure: (e) {
      ToastProvider.error(e.error.toString());
      captchaKey.currentState.refresh();
    });
    codeController.clear();
  }

  final FocusNode _accountFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    var hintStyle = FontManager.YaHeiRegular.copyWith(
        color: Color.fromRGBO(201, 204, 209, 1), fontSize: 13);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset('assets/images/tju_error.png', height: 25),
          SizedBox(width: 5),
          Text(S.current.wrong + "！",
              style: FontManager.YaQiHei.copyWith(
                  color: Color.fromRGBO(79, 88, 107, 1),
                  fontWeight: FontWeight.bold,
                  fontSize: 17))
        ]),
        SizedBox(height: 8),
        Text(S.current.re_login_text,
            style: FontManager.YaHeiRegular.copyWith(
                color: Color.fromRGBO(79, 88, 107, 1), fontSize: 12)),
        SizedBox(height: 18),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 55,
          ),
          child: TextField(
            textInputAction: TextInputAction.next,
            controller: nameController,
            focusNode: _accountFocus,
            decoration: InputDecoration(
                hintText: S.current.user_name,
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
        SizedBox(height: 22),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 55,
          ),
          child: TextField(
            keyboardType: TextInputType.visiblePassword,
            controller: pwController,
            focusNode: _passwordFocus,
            decoration: InputDecoration(
                hintText: S.current.password,
                hintStyle: hintStyle,
                filled: true,
                fillColor: Color.fromRGBO(235, 238, 243, 1),
                isCollapsed: true,
                contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 18),
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
        SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 55,
                width: 120,
                child: TextField(
                  controller: codeController,
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
                ),
              ),
            ),
            SizedBox(width: 20),
            SizedBox(height: 55, width: 100, child: captchaWidget)
          ],
        ),
        Container(
            height: 50,
            width: 400,
            margin: const EdgeInsets.fromLTRB(25, 30, 25, 10),
            child: ElevatedButton(
              onPressed: _bind,
              child: Text(S.current.login,
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
            )),
      ],
    );
  }
}

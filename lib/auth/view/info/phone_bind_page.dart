import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/auth/view/info/unbind_dialogs.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/main.dart';

import '../../../commons/widgets/w_button.dart';

class PhoneBindPage extends StatefulWidget {
  @override
  _PhoneBindPageState createState() => _PhoneBindPageState();
}

class _PhoneBindPageState extends State<PhoneBindPage> {
  String phone = "";
  String code = "";
  bool isPress = false;

  void _fetchCaptcha() async {
    if (phone == "") {
      ToastProvider.error("手机号码不能为空");
      return;
    }
    AuthService.getCaptchaOnInfo(phone,
        onSuccess: () {
          setState(() => isPress = true);
        },
        onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  _bind() async {
    if (phone == "") {
      ToastProvider.error("手机号码不能为空");
      return;
    } else if (code == "") {
      ToastProvider.error("短信验证码不能为空");
      return;
    }
    AuthService.changePhone(phone, code,
        onSuccess: () {
          ToastProvider.success("手机号码绑定成功");
          setState(() {});
        },
        onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  Widget _detail(BuildContext context) {
    var hintStyle = TextUtil.base.regular
        .sp(13)
        .oldHintDarker;
    double width = WePeiYangApp.screenWidth - 80;
    if (CommonPreferences.phone.value != "")
      return Column(children: [
        SizedBox(height: 70),
        Center(
          child: Text(
              "${S.current.bind_phone}: ${CommonPreferences.phone.value}",
              style: TextUtil.base.bold
                  .sp(15)
                  .oldSecondaryAction),
        ),
        SizedBox(height: 95),
        SizedBox(
          height: 50,
          width: 120,
          child: ElevatedButton(
            onPressed: () => showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) => PhoneUnbindDialog())
                .then((_) => this.setState(() {})),
            child: Text(S.current.unbind,
                style: TextUtil.base.regular.reverse.sp(13)),
            style: ButtonStyle(
              elevation: MaterialStateProperty.all(3),
              overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.pressed))
                  return ColorUtil.oldActionRippleColor;
                return ColorUtil.oldSecondaryActionColor;
              }),
              backgroundColor:
                  MaterialStateProperty.resolveWith<Color>((states) {
                return ColorUtil.oldSecondaryActionColor;
              }),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
            ),
          ),
        ),
      ]);
    else {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 55),
              child: TextField(
                decoration: InputDecoration(
                    hintText: S.current.phone,
                    hintStyle: hintStyle,
                    filled: true,
                    fillColor: ColorUtil.reverseTextColor,
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.fromLTRB(15, 18, 0, 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none)),
                onChanged: (input) => setState(() => phone = input),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              children: [
                ConstrainedBox(
                  constraints:
                      BoxConstraints(maxHeight: 55, maxWidth: width / 2 + 20),
                  child: TextField(
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                        hintText: S.current.text_captcha,
                        hintStyle: hintStyle,
                        filled: true,
                        fillColor: ColorUtil.white235,
                        isCollapsed: true,
                        contentPadding:
                            const EdgeInsets.fromLTRB(15, 18, 0, 18),
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
                            return ElevatedButton(
                              onPressed: () {},
                              child: Text('$time秒后重试',
                                  style: TextUtil.base.bold.sp(13).oldThirdAction),
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all(5),
                                overlayColor:
                                    MaterialStateProperty.all(ColorUtil.greyShade300),
                                backgroundColor:
                                    MaterialStateProperty.all(ColorUtil.greyShade300),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                              ),
                            );
                          })
                      : ElevatedButton(
                          onPressed: _fetchCaptcha,
                          child: Text(S.current.fetch_captcha,
                              style: TextUtil.base.regular.reverse.sp(13)),
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(5),
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color>(
                                    (states) {
                              if (states.contains(MaterialState.pressed))
                                return ColorUtil.oldActionRippleColor;
                              return ColorUtil.oldActionColor;
                            }),
                            backgroundColor: MaterialStateProperty.all(
                                ColorUtil.oldActionColor),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 50,
            width: 400,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButton(
              onPressed: _bind,
              child: Text(S.current.bind,
                  style: TextUtil.base.regular.reverse.sp(13)),
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(5),
                overlayColor:
                    MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.pressed))
                    return ColorUtil.oldActionRippleColor;
                  return ColorUtil.oldActionColor;
                }),
                backgroundColor:
                    MaterialStateProperty.all(ColorUtil.oldActionColor),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: ColorUtil.reverseTextColor,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: WButton(
                child: Icon(Icons.arrow_back,
                    color: ColorUtil.oldActionColor, size: 32),
                onPressed: () => Navigator.pop(context)),
          )),
      body: Column(
        children: [
          Row(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.fromLTRB(35, 20, 20, 20),
                child: Text(S.current.phone_bind,
                    style: TextUtil.base.bold
                        .sp(28)
                        .oldFurthAction),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 32, 0, 20),
                child: Text(
                    (CommonPreferences.phone.value != "")
                        ? S.current.is_bind
                        : S.current.not_bind,
                    style: TextUtil.base.bold.greyA6.sp(12)),
              ),
            ],
          ),
          _detail(context)
        ],
      ),
    );
  }
}

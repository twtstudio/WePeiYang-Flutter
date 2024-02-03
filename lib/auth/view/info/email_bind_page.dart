import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/auth/view/info/unbind_dialogs.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class EmailBindPage extends StatefulWidget {
  @override
  _EmailBindPageState createState() => _EmailBindPageState();
}

class _EmailBindPageState extends State<EmailBindPage> {
  String email = "";

  _bind() async {
    if (email == "") {
      ToastProvider.error("邮箱不能为空");
      return;
    }
    AuthService.changeEmail(email,
        onSuccess: () {
          ToastProvider.success("邮箱绑定成功");
          setState(() {});
        },
        onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  Widget _detail(BuildContext context) {
    var hintStyle = TextUtil.base.regular.sp(13).whiteHint201;
    if (CommonPreferences.email.value != "")
      return Column(children: [
        SizedBox(height: 60),
        Text(
          "${S.current.bind_email}: ",
          textAlign: TextAlign.center,
          style: TextUtil.base.bold.sp(15).blue79,
        ),
        SizedBox(height: 5),
        Text(
          CommonPreferences.email.value,
          textAlign: TextAlign.center,
          style: TextUtil.base.bold.sp(15).blue79,
        ),
        SizedBox(height: 95),
        SizedBox(
          height: 50,
          width: 120,
          child: ElevatedButton(
            onPressed: () => showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) => EmailUnbindDialog())
                .then((_) => this.setState(() {})),
            child: Text(S.current.unbind,
                style: TextUtil.base.regular.reverse.sp(13)),
            style: ButtonStyle(
              elevation: MaterialStateProperty.all(3),
              overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.pressed))
                  return ColorUtil.blue103;
                return ColorUtil.blue79;
              }),
              backgroundColor: MaterialStateProperty.all(ColorUtil.blue79),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        ),
      ]);
    else {
      return Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 55),
            child: TextField(
              decoration: InputDecoration(
                  hintText: S.current.email2,
                  hintStyle: hintStyle,
                  filled: true,
                  fillColor: ColorUtil.white235,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.fromLTRB(15, 18, 0, 18),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none)),
              onChanged: (input) => setState(() => email = input),
            ),
          ),
        ),
        SizedBox(height: 30),
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
                    return ColorUtil.blue103;
                  return ColorUtil.blue53;
                }),
                backgroundColor:
                    MaterialStateProperty.resolveWith<Color>((states) {
                  return ColorUtil.blue53;
                }),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
              ),
            )),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: ColorUtil.white250,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: WButton(
                child:
                    Icon(Icons.arrow_back, color: ColorUtil.blue53, size: 32),
                onPressed: () => Navigator.pop(context)),
          )),
      body: Column(
        children: [
          Row(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.fromLTRB(35, 20, 20, 30),
                child: Text(S.current.email_bind,
                    style: TextUtil.base.bold.sp(28).blue48),
              ),
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 32, 0, 30),
                    child: Text(
                        (CommonPreferences.email.value != "")
                            ? S.current.is_bind
                            : S.current.not_bind,
                        style: TextUtil.base.bold.greyA6.sp(12)),
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

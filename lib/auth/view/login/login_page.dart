import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';

import '../../../commons/preferences/common_prefs.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../privacy/privacy_dialog.dart';

class LoginHomeWidget extends StatefulWidget{

  @override
  _LoginHomeWidgetState createState()=>_LoginHomeWidgetState();

}

class _LoginHomeWidgetState extends State<LoginHomeWidget> {

  String md = '';
  @override
  void initState(){
    super.initState();
    if (CommonPreferences.firstPrivacy.value == true) {
      rootBundle.loadString('privacy/privacy_content.md').then((str) {
        setState(() {
          md = str;
        });
      });
    }

    ///首次打开APP弹出隐私协议
    ///修改为拒绝后再次打开APP仍弹出隐私协议
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
      if (CommonPreferences.firstPrivacy.value == true ) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return PrivacyDialog(md);
            });
        CommonPreferences.firstPrivacy.value = false;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: WpyTheme.of(context).brightness.uiOverlay.copyWith(
          systemNavigationBarColor:
              WpyTheme.of(context).get(WpyColorKey.primaryLightActionColor)),
      child: Scaffold(
        body: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: WpyTheme.of(context)
                .getGradient(WpyColorSetKey.primaryGradientAllScreen),
          ),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.fromLTRB(30, 70, 0, 0),
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                      text: "Welcome\n\n",
                      style: TextUtil.base.normal.NotoSansSC
                          .sp(40)
                          .w700
                          .bright(context)),
                  TextSpan(
                      text: "微北洋",
                      style: TextUtil.base.normal.NotoSansSC
                          .sp(40)
                          .w400
                          .bright(context)),
                ])),
              ),
              Spacer(
                flex: 6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 48,
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AuthRouter.loginPw),
                      child: Text.rich(TextSpan(
                          text: "登录",
                          style: TextUtil.base.bold.NotoSansSC
                              .sp(16)
                              .w400
                              .primaryAction(context))),
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(0),
                        //水波纹颜色暂时没确定
                        overlayColor:
                            WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.pressed))
                            return WpyTheme.of(context)
                                .get(WpyColorKey.oldActionRippleColor);
                          return WpyTheme.of(context)
                              .get(WpyColorKey.oldThirdActionColor);
                        }),
                        //暂时把Mycolors.deepblue改成默认白色
                        backgroundColor: WidgetStateProperty.all(
                            WpyTheme.of(context)
                                .get(WpyColorKey.primaryBackgroundColor)),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24))),
                      ),
                    ),
                  ),
                  SizedBox(width: 30),
                  SizedBox(
                    height: 48,
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AuthRouter.register1),
                      child: Text.rich(TextSpan(
                          text: "注册",
                          style: TextUtil.base.bold.NotoSansSC
                              .sp(16)
                              .w400
                              .primaryAction(context))),
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(0),
                        overlayColor:
                            WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.pressed))
                            return WpyTheme.of(context)
                                .get(WpyColorKey.oldActionRippleColor);
                          return WpyTheme.of(context)
                              .get(WpyColorKey.oldThirdActionColor);
                        }),
                        backgroundColor: WidgetStateProperty.all(
                            WpyTheme.of(context)
                                .get(WpyColorKey.primaryBackgroundColor)),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: "首次登录微北洋请使用天外天账号密码登录\n在登陆后绑定手机号码即可手机验证登录",
                      style: TextUtil.base.normal.NotoSansSC
                          .sp(12)
                          .w400
                          .bright(context))),
              Spacer(flex: 9),
            ],
          ),
        ),
      ),
    );
  }
}

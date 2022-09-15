import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';

class LoginHomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return Scaffold(
      body: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 44, 126, 223),
                Color.fromARGB(255, 166, 207, 255),
              ]),
        ),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(30, 70, 0, 0),
              child: Text.rich(TextSpan(children: [
                TextSpan(
                    text: "Welcome\n\n",
                    style: TextUtil.base.normal.NotoSansSC.sp(40).w700.white),
                TextSpan(
                    text: "微北洋",
                    style: TextUtil.base.normal.NotoSansSC.sp(40).w400.white),
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
                        style:
                            TextUtil.base.bold.NotoSansSC.sp(16).w400.blue2C)),
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(0),
                      //水波纹颜色暂时没确定
                      overlayColor:
                          MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.pressed))
                          return Color.fromRGBO(103, 110, 150, 1.0);
                        return Color.fromRGBO(98, 103, 124, 1.0);
                      }),
                      //暂时把Mycolors.deepblue改成默认白色
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
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
                        style:
                            TextUtil.base.bold.NotoSansSC.sp(16).w400.blue2C)),
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(0),
                      overlayColor:
                          MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.pressed))
                          return Color.fromRGBO(103, 110, 150, 1.0);
                        return Color.fromRGBO(98, 103, 124, 1.0);
                      }),
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
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
                    style: TextUtil.base.normal.NotoSansSC.sp(12).w400.white)),
            Spacer(flex: 9),
          ],
        ),
      ),
    );
  }
}

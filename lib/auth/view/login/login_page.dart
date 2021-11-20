import 'package:flutter/material.dart';

import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/update/update_service.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class LoginHomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      UpdateManager.checkUpdate();
    });
    return Scaffold(
      body: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(30, 50, 0, 0),
            child: Text("Hello,\n${S.current.WBY}4.0",
                style: FontManager.YaHeiLight.copyWith(
                    color: Color.fromRGBO(98, 103, 124, 1),
                    fontSize: 50,
                    fontWeight: FontWeight.w300)),
          ),
          Spacer(flex: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
                width: 100,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AuthRouter.loginPw),
                  child: Text(S.current.login,
                      style: FontManager.YaHeiRegular.copyWith(
                          color: Colors.white, fontSize: 13)),
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(3),
                    overlayColor:
                        MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.pressed))
                        return MyColors.brightBlue;
                      return MyColors.deepBlue;
                    }),
                    backgroundColor:
                        MaterialStateProperty.all(MyColors.deepBlue),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                  ),
                ),
              ),
              SizedBox(width: 50),
              SizedBox(
                height: 50,
                width: 100,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AuthRouter.register1),
                  child: Text(S.current.register,
                      style: FontManager.YaHeiRegular.copyWith(
                          color: Colors.white, fontSize: 13)),
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(3),
                    overlayColor:
                        MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.pressed))
                        return MyColors.brightBlue;
                      return MyColors.deepBlue;
                    }),
                    backgroundColor:
                        MaterialStateProperty.all(MyColors.deepBlue),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Text(S.current.first_login_hint,
              textAlign: TextAlign.center,
              style: FontManager.YaHeiRegular.copyWith(
                  fontSize: 11, color: Color.fromRGBO(98, 103, 124, 1))),
          Spacer(flex: 2)
        ],
      ),
    );
  }
}

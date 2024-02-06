import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

import '../../../commons/themes/wpy_theme.dart';

class ResetDoneWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: WpyTheme.of(context).get(WpyThemeKeys.primaryBackgroundColor),
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: WButton(
                child: Icon(Icons.arrow_back,
                    color: WpyTheme.of(context).get(WpyThemeKeys.oldThirdActionColor), size: 35),
                onPressed: () => Navigator.pop(context)),
          )),
      body: Column(
        children: [
          SizedBox(height: 180),
          Center(
            child: Text(S.current.reset_password_done,
                style: TextUtil.base.bold.sp(16).oldThirdAction(context)),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 55,
            width: 140,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, AuthRouter.login, (route) => false),
              child: Text(S.current.login3,
                  style: TextUtil.base.regular.reverse(context).sp(13)),
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(5),
                overlayColor:
                    MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.pressed))
                    return WpyTheme.of(context).get(WpyThemeKeys.oldActionRippleColor);
                  return WpyTheme.of(context).get(WpyThemeKeys.oldActionColor);
                }),
                backgroundColor:
                    MaterialStateProperty.all(WpyTheme.of(context).get(WpyThemeKeys.oldActionColor)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

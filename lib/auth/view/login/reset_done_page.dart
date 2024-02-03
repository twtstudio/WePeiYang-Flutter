import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class ResetDoneWidget extends StatelessWidget {
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
                child:
                    Icon(Icons.arrow_back, color: ColorUtil.oldThirdActionColor, size: 35),
                onPressed: () => Navigator.pop(context)),
          )),
      body: Column(
        children: [
          SizedBox(height: 180),
          Center(
            child: Text(S.current.reset_password_done,
                style: TextUtil.base.bold.sp(16).oldThirdAction),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 55,
            width: 140,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, AuthRouter.login, (route) => false),
              child: Text(S.current.login3,
                  style: TextUtil.base.regular.reverse.sp(13)),
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(5),
                overlayColor:
                    MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.pressed))
                    return ColorUtil.oldActionRippleColor;
                  return ColorUtil.oldActionColor;
                }),
                backgroundColor: MaterialStateProperty.all(ColorUtil.oldActionColor),
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

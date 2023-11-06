import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class ResetDoneWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: ColorUtil.white250,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
                child:
                    Icon(Icons.arrow_back, color: ColorUtil.blue98, size: 35),
                onTap: () => Navigator.pop(context)),
          )),
      body: Column(
        children: [
          SizedBox(height: 180),
          Center(
            child: Text(S.current.reset_password_done,
                style: TextUtil.base.bold.sp(16).blue98),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 55,
            width: 140,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, AuthRouter.login, (route) => false),
              child: Text(S.current.login3,
                  style: TextUtil.base.regular.white.sp(13)),
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(5),
                overlayColor:
                    MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.pressed))
                    return ColorUtil.blue103;
                  return ColorUtil.blue53;
                }),
                backgroundColor: MaterialStateProperty.all(ColorUtil.blue53),
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

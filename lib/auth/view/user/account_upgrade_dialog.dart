import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';

class AccountUpgradeDialog extends Dialog {
  static final _hintStyle = TextUtil.base.bold.noLine
      .sp(15)
      .customColor(Color.fromRGBO(98, 103, 123, 1));

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Container(
          height: 120,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color.fromRGBO(237, 240, 244, 1)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Text("点击下方按钮进行账号升级",
                  style: TextUtil.base.normal.noLine
                      .sp(13)
                      .customColor(Color.fromRGBO(79, 88, 107, 1))),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      var rsp = await AuthService.accountUpgrade();
                      if(rsp) Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: Text('账号升级', style: _hintStyle),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

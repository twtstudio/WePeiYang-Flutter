import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

import '../../../commons/channel/statistics/umeng_statistics.dart';
import '../../../commons/widgets/w_button.dart';
import '../../../feedback/view/lake_home_page/lake_notifier.dart';
import '../../../main.dart';
import '../../auth_router.dart';

class AccountUpgradeDialog extends Dialog {
  static final _hintStyle = TextUtil.base.bold.noLine.sp(15).blue98;

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
              color: ColorUtil.white237),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Text("点击下方按钮进行账号升级",
                  style: TextUtil.base.normal.noLine.sp(13).blue79),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WButton(
                    onPressed: () {
                      UmengCommonSdk.onProfileSignOff();
                      CommonPreferences.clearAllPrefs();
                      if (CommonPreferences.lakeToken.value != '')
                        context.read<LakeModel>().clearAll();
                      Navigator.pushNamedAndRemoveUntil(
                          WePeiYangApp.navigatorState.currentContext!,
                          AuthRouter.login,
                          (route) => false);
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: Text('重新登录', style: _hintStyle),
                    ),
                  ),
                  SizedBox(
                    width: 50.w,
                  ),
                  WButton(
                    onPressed: () async {
                      var rsp = await AuthService.accountUpgrade();
                      if (rsp) {
                        // Navigator.pop(context);
                        ToastProvider.success("升级成功，请使用新学号登录~");
                        UmengCommonSdk.onProfileSignOff();
                        CommonPreferences.clearAllPrefs();
                        if (CommonPreferences.lakeToken.value != '')
                          context.read<LakeModel>().clearAll();
                        Navigator.pushNamedAndRemoveUntil(
                            WePeiYangApp.navigatorState.currentContext!,
                            AuthRouter.login,
                            (route) => false);
                      } else {
                        ToastProvider.error("升级失败，请联系开发人员!");
                      }
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

// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:we_pei_yang_flutter/auth/view/privacy/privacy_dialog.dart';
import 'package:we_pei_yang_flutter/auth/view/privacy/user_agreement_dialog.dart';
import 'package:we_pei_yang_flutter/auth/view/user/debug_dialog.dart';
import 'package:we_pei_yang_flutter/auth/view/user/logout_dialog.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/test/test_router.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  static final mainTextStyle =
      TextUtil.base.bold.sp(14).customColor(Color.fromRGBO(98, 103, 122, 1));
  static final hintTextStyle =
      TextUtil.base.bold.sp(12).customColor(Color.fromRGBO(177, 180, 186, 1));
  static const arrow =
      Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 22);
  String md = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      rootBundle.loadString('privacy/privacy_content.md').then((str) {
        setState(() {
          md = str;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.setting,
            style: TextUtil.base.bold
                .sp(16)
                .customColor(Color.fromRGBO(36, 43, 69, 1))),
        elevation: 0,
        brightness: Brightness.light,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: GestureDetector(
            child: Icon(Icons.arrow_back,
                color: Color.fromRGBO(53, 59, 84, 1), size: 32),
            onTap: () => Navigator.pop(context),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        children: [
          SizedBox(height: 15.h),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 15.w, 20.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, AuthRouter.userInfo)
                  .then((_) => this.setState(() {})),
              child: Row(
                children: [
                  Image.asset('assets/images/modify_info_icon.png',
                      width: 20.w),
                  SizedBox(width: 12.w),
                  Expanded(
                    child:
                        Text(S.current.reset_user_info, style: mainTextStyle),
                  ),
                  arrow,
                  SizedBox(width: 15.w),
                ],
              ),
            ),
          ),
          SizedBox(height: 15.h),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 15.w, 20.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: InkWell(
              onLongPress: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (_) => DebugDialog(),
                );
              },
              onTap: () =>
                  Navigator.pushNamed(context, AuthRouter.generalSetting)
                      .then((_) => this.setState(() {})),
              child: Row(
                children: [
                  Icon(Icons.widgets_outlined,
                      color: Color.fromRGBO(98, 103, 122, 1), size: 20),
                  SizedBox(width: 12.w),
                  Expanded(child: Text('应用设置', style: mainTextStyle)),
                  arrow,
                  SizedBox(width: 15.w),
                ],
              ),
            ),
          ),
          SizedBox(height: 15.h),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 15.w, 20.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: InkWell(
              onLongPress: () {
                if (EnvConfig.isTest) {
                  Navigator.pushNamed(context, TestRouter.mainPage);
                }
              },
              onTap: () => Navigator.pushNamed(context, AuthRouter.aboutTwt),
              child: Row(
                children: [
                  Image.asset('assets/images/twt.png', width: 20.w),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(S.current.about_twt, style: mainTextStyle),
                  ),
                  arrow,
                  SizedBox(width: 15.w),
                ],
              ),
            ),
          ),
          SizedBox(height: 15.h),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 15.w, 20.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: InkWell(
              onTap: () {
                context.read<UpdateManager>().checkUpdate(auto: false);
              },
              child: Row(
                children: [
                  Icon(Icons.update,
                      color: Color.fromRGBO(98, 103, 122, 1), size: 20),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(S.current.check_new, style: mainTextStyle),
                  ),
                  Text("${S.current.current_version}: ${EnvConfig.VERSION}",
                      style: hintTextStyle),
                  SizedBox(width: 15.w),
                ],
              ),
            ),
          ),
          SizedBox(height: 15.h),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 15.w, 20.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: InkWell(
              onTap: () => showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) => LogoutDialog()),
              child: Row(
                children: [
                  Image.asset('assets/images/logout.png', width: 20.w),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(S.current.logout, style: mainTextStyle),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) => UserAgreementDialog()),
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(),
                  child: Text('《用户协议》', style: hintTextStyle),
                ),
              ),
              GestureDetector(
                onTap: () => showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return PrivacyDialog(md);
                    }),
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(),
                  child: Text('《隐私政策》', style: hintTextStyle),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/auth/view/login/widgets/auth_widgets.dart';
import 'package:we_pei_yang_flutter/commons/channel/statistics/umeng_statistics.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';

import '../../../commons/preferences/common_prefs.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../privacy/privacy_dialog.dart';

class LoginHomeWidget extends StatefulWidget {
  @override
  _LoginHomeWidgetState createState() => _LoginHomeWidgetState();
}

class _LoginHomeWidgetState extends State<LoginHomeWidget> {
  String md = '';

  @override
  void initState() {
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (CommonPreferences.firstPrivacy.value == true) {
        // 如果已经同意了隐私协议， init, 否则弹窗等待， 如果没同意的话就会直接退出APP, 不会运行到这里
        await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return PrivacyDialog(md);
            });
        CommonPreferences.firstPrivacy.value = false;
      }
      if (CommonPreferences.firstPrivacy.value == false) {
        UmengCommonSdk.initCommon();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bright = WpyTheme.of(context).get(WpyColorKey.brightTextColor);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor:
              WpyTheme.of(context).get(WpyColorKey.primaryLightActionColor)),
      child: Scaffold(
        body: AuthBackground(
          child: SafeArea(
            // 窗口足够高时撑满，高度不够时（桌面端缩小窗口、横屏）可滚动，避免溢出
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: AuthLayout.maxContentWidth),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 32),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.18),
                                      blurRadius: 24,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(22),
                                  child: Image.asset('assets/app_icon.png',
                                      width: 84, height: 84),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            Text('Welcome',
                                style: authText(context, 18,
                                    weight: FontWeight.w500,
                                    color: bright.withValues(alpha: 0.8))),
                            const SizedBox(height: 2),
                            Text('微北洋',
                                style: authText(context, 44,
                                        weight: FontWeight.w700, color: bright)
                                    .copyWith(height: 1.2)),
                            const SizedBox(height: 10),
                            Text('天津大学一站式校园服务',
                                style: authText(context, 15,
                                    color: bright.withValues(alpha: 0.85))),
                            const SizedBox(height: 40),
                            AuthOnGradientButton(
                              text: '登录',
                              onPressed: () => Navigator.pushNamed(
                                  context, AuthRouter.loginPw),
                            ),
                            const SizedBox(height: 14),
                            AuthOnGradientButton(
                              text: '注册新账号',
                              filled: false,
                              onPressed: () => Navigator.pushNamed(
                                  context, AuthRouter.register1),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              '首次登录微北洋请使用天外天账号密码登录\n在登录后绑定手机号码即可手机验证登录',
                              textAlign: TextAlign.center,
                              style: authText(context, 12,
                                  color: bright.withValues(alpha: 0.75)),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 登录/注册流程页面的自适应布局回归测试：
// 在手机、平板、桌面、矮窗口、横屏等多种尺寸以及亮/暗主题下渲染每个页面，
// 确保不出现溢出（RenderFlex overflowed）等布局异常。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:we_pei_yang_flutter/auth/view/login/add_info_page.dart';
import 'package:we_pei_yang_flutter/auth/view/login/find_pw_dialog.dart';
import 'package:we_pei_yang_flutter/auth/view/login/find_pw_page.dart';
import 'package:we_pei_yang_flutter/auth/view/login/login_pw_page.dart';
import 'package:we_pei_yang_flutter/auth/view/login/register_page.dart';
import 'package:we_pei_yang_flutter/auth/view/login/reset_done_page.dart';
import 'package:we_pei_yang_flutter/auth/view/login/reset_pw_page.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';

const sizes = <String, Size>{
  'small phone': Size(320, 568),
  'phone': Size(390, 844),
  'tablet': Size(820, 1180),
  'desktop': Size(1600, 900),
  'short window': Size(800, 420),
  'landscape phone': Size(844, 390),
};

final pages = <String, Widget Function()>{
  'login': () => LoginPwWidget(),
  'register1': () => RegisterPageOne(),
  'register2': () => RegisterPageTwo('1', 'n', '1', 'a@b.c'),
  'register3': () => RegisterPageThree('1', 'n', '1', 'a@b.c', '1', '1'),
  'findHome': () => FindPwWidget(),
  'findPhone': () => FindPwByPhoneWidget(),
  'resetPw': () => ResetPwWidget(),
  'resetDone': () => ResetDoneWidget(),
  'addInfo': () => AddInfoWidget(),
  'findDialog': () => Scaffold(body: FindPwDialog()),
};

Widget host(Widget child, WpyThemeData theme) => WpyTheme(
      themeData: theme,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Navigator(
          // 让页面上的返回按钮可见（canPop == true）
          onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => Container()),
          initialRoute: '/',
          onGenerateInitialRoutes: (nav, _) => [
            MaterialPageRoute(builder: (_) => const SizedBox()),
            MaterialPageRoute(builder: (_) => child),
          ],
        ),
      ),
    );

void main() {
  final themes = {
    'light': WpyThemeData.brightThemeList.first,
    'dark': WpyThemeData.darkThemeList.first,
  };

  for (final theme in themes.entries) {
    for (final size in sizes.entries) {
      testWidgets('auth pages fit ${size.key} (${theme.key})', (t) async {
        t.view.physicalSize = size.value;
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);

        for (final page in pages.entries) {
          await t.pumpWidget(host(page.value(), theme.value));
          await t.pumpAndSettle();
          expect(t.takeException(), isNull,
              reason: '${page.key} @ ${size.key} (${theme.key})');
        }

        // 登录页切换到短信登录后也不应溢出
        await t.pumpWidget(host(LoginPwWidget(), theme.value));
        await t.pumpAndSettle();
        await t.tap(find.text('短信登录'));
        for (var i = 0; i < 10; i++) {
          await t.pump(const Duration(milliseconds: 30));
          expect(t.takeException(), isNull,
              reason: 'sms switch @ ${size.key} (${theme.key})');
        }
        await t.pumpAndSettle();
      });
    }
  }
}

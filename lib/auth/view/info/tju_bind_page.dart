import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:we_pei_yang_flutter/auth/view/info/unbind_dialogs.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

import '../../../commons/network/classes_backend_service.dart';
import '../../../commons/network/classes_service.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/widgets/w_button.dart';
import '../../../schedule/model/course_provider.dart';

class TjuBindPage extends StatefulWidget {
  @override
  _TjuBindPageState createState() => _TjuBindPageState();
}

class _TjuBindPageState extends State<TjuBindPage> {
  String tjuuname = '';
  String tjupasswd = '';

  void _bind() async {
    if (tjuuname == '') {
      ToastProvider.error('用户名不能为空');
      return;
    } else if (tjupasswd == '') {
      ToastProvider.error('密码不能为空');
      return;
    }
    checkNetWork(false);
    var res = '';
    while (res.length != 4) {
      res = await ClassesBackendService.ocr();
    }
    await ClassesService.login(tjuuname, tjupasswd, code: res);
    ToastProvider.success('办公网绑定成功!');
    CommonPreferences.tjuuname.value = tjuuname;
    CommonPreferences.tjupasswd.value = tjupasswd;
    CommonPreferences.isBindTju.value = true;
    context.read<CourseProvider>().refreshCourseByBackend(context);
    setState(() {});
  }

  final FocusNode _accountFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  final visNotifier = ValueNotifier<bool>(true); // 是否隐藏密码

  void checkNetWork(bool jump) async {
    var rsp = await ClassesService.check();
    if (!rsp) {
      ToastProvider.error('请连接校园网或连接VPN!');
    } else {
      if (jump) {
        String url = 'http://classes.tju.edu.cn/';
        await launchUrl(Uri.parse(url));
      } else {
        ToastProvider.success('网络检查通过!');
      }
    }
  }

  Widget _detail(BuildContext context) {
    final hintStyle = TextUtil.base.regular.sp(13).oldHintDarker(context);
    if (CommonPreferences.isBindTju.value)
      return Column(children: [
        SizedBox(height: 30),
        Text("${S.current.bind_account}: ${CommonPreferences.tjuuname.value}",
            style: TextUtil.base.bold.sp(15).oldSecondaryAction(context)),
        SizedBox(height: 60),
        SizedBox(
          height: 50,
          width: 120,
          child: ElevatedButton(
            onPressed: () => showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) => TjuUnbindDialog())
                .then((_) => this.setState(() {})),
            child: Text(S.current.unbind,
                style: TextUtil.base.regular.reverse(context).sp(13)),
            style: ButtonStyle(
              elevation: MaterialStateProperty.all(3),
              overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.pressed))
                  return WpyTheme.of(context)
                      .get(WpyColorKey.oldActionRippleColor);
                return WpyTheme.of(context)
                    .get(WpyColorKey.oldSecondaryActionColor);
              }),
              backgroundColor: MaterialStateProperty.all(WpyTheme.of(context)
                  .get(WpyColorKey.oldSecondaryActionColor)),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        ),
      ]);
    else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(children: [
          SizedBox(height: 30),
          Text(
            S.current.tju_bind_hint,
            style: TextUtil.base.regular.sp(10).oldThirdAction(context),
          ),
          SizedBox(height: 20),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 55),
            child: TextField(
              textInputAction: TextInputAction.next,
              focusNode: _accountFocus,
              cursorColor:
                  WpyTheme.of(context).get(WpyColorKey.defaultActionColor),
              decoration: InputDecoration(
                  hintText: S.current.tju_account,
                  hintStyle: hintStyle,
                  filled: true,
                  fillColor: WpyTheme.of(context).get(WpyColorKey.oldSwitchBarColor),
                  isCollapsed: true,
                  contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 18),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none)),
              onChanged: (input) => setState(() => tjuuname = input),
              onEditingComplete: () {
                _accountFocus.unfocus();
                FocusScope.of(context).requestFocus(_passwordFocus);
              },
            ),
          ),
          SizedBox(height: 20),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 55),
            child: ValueListenableBuilder(
              valueListenable: visNotifier,
              builder: (context, bool value, _) {
                return Theme(
                  data: Theme.of(context).copyWith(
                      primaryColor: WpyTheme.of(context)
                          .get(WpyColorKey.oldActionColor)),
                  child: TextField(
                    keyboardType: TextInputType.visiblePassword,
                    focusNode: _passwordFocus,
                    cursorColor: WpyTheme.of(context)
                        .get(WpyColorKey.defaultActionColor),
                    decoration: InputDecoration(
                      hintText: S.current.password,
                      hintStyle: hintStyle,
                      filled: true,
                      fillColor: WpyTheme.of(context).get(WpyColorKey.oldSwitchBarColor),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 18),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                      suffixIcon: WButton(
                        child: Icon(
                          value ? Icons.visibility_off : Icons.visibility,
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.defaultActionColor),
                        ),
                        onPressed: () {
                          visNotifier.value = !visNotifier.value;
                        },
                      ),
                    ),
                    obscureText: value,
                    onChanged: (input) => setState(() => tjupasswd = input),
                    onEditingComplete: () {
                      _passwordFocus.unfocus();
                    },
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 50,
            width: 400,
            child: ElevatedButton(
              onPressed: _bind,
              child: Text(S.current.bind,
                  style: TextUtil.base.regular.reverse(context).sp(13)),
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(5),
                overlayColor:
                    MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.pressed))
                    return WpyTheme.of(context)
                        .get(WpyColorKey.oldActionRippleColor);
                  return WpyTheme.of(context).get(WpyColorKey.oldActionColor);
                }),
                backgroundColor: MaterialStateProperty.all(
                    WpyTheme.of(context).get(WpyColorKey.oldActionColor)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
              ),
            ),
          ),
          SizedBox(height: 35),
          Text(
            '应学校要求，校外使用教育教学信息管理系统需先登录天津大学VPN，'
            '故在校外访问微北洋课表、GPA功能也需登录VPN绑定办公网账号后使用。',
            style: TextUtil.base.regular.sp(10).oldThirdAction(context),
          ),
          Row(
            children: [
              Text(
                '办公网网址为 ',
                style: TextUtil.base.regular.sp(10).oldThirdAction(context),
              ),
              WButton(
                onPressed: () async {
                  checkNetWork(true);
                },
                child: Text('classes.tju.edu.cn',
                    style: TextUtil.base.regular.label(context).underLine.sp(10)),
              ),
            ],
          ),
          SizedBox(height: 35),
        ]),
      );
    }
  }

  @override
  void initState() {
    checkNetWork(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor:
              WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: WButton(
                child: Icon(Icons.arrow_back,
                    color:
                        WpyTheme.of(context).get(WpyColorKey.oldActionColor),
                    size: 32),
                onPressed: () => Navigator.pop(context)),
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.fromLTRB(35, 10, 20, 50),
                  child: Text(S.current.tju_bind,
                      style: TextUtil.base.bold.sp(28).oldFurthAction(context)),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 22, 0, 50),
                  child: Text(
                      CommonPreferences.isBindTju.value
                          ? S.current.is_bind
                          : S.current.not_bind,
                      style: TextUtil.base.bold.oldListAction(context).sp(12)),
                ),
              ],
            ),

            /// 已绑定/未绑定时三个图标的高度不一样，所以加个间隔控制一下
            SizedBox(height: CommonPreferences.isBindTju.value ? 20 : 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/tju_work.png',
                    height: 50, width: 50),
                SizedBox(width: 20),
                Image.asset('assets/images/bind.png', height: 25, width: 25),
                SizedBox(width: 20),
                Image.asset('assets/images/twt_round.png',
                    height: 50, width: 50),
              ],
            ),
            _detail(context)
          ],
        ),
      ),
    );
  }
}

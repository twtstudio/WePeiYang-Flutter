import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:we_pei_yang_flutter/auth/view/info/unbind_dialogs.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class TjuBindPage extends StatefulWidget {
  @override
  _TjuBindPageState createState() => _TjuBindPageState();
}

class _TjuBindPageState extends State<TjuBindPage> {
  String tjuuname = '';
  String tjupasswd = '';

  void _bind() {
    if (tjuuname == '') {
      ToastProvider.error('用户名不能为空');
      return;
    } else if (tjupasswd == '') {
      ToastProvider.error('密码不能为空');
      return;
    }
    CommonPreferences.tjuuname.value = tjuuname;
    CommonPreferences.tjupasswd.value = tjupasswd;
    CommonPreferences.isBindTju.value = true;
    setState(() {});
  }

  final FocusNode _accountFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  final visNotifier = ValueNotifier<bool>(true); // 是否隐藏密码

  Widget _detail(BuildContext context) {
    var hintStyle = TextUtil.base.regular
        .sp(13)
        .customColor(Color.fromRGBO(201, 204, 209, 1));
    if (CommonPreferences.isBindTju.value)
      return Column(children: [
        SizedBox(height: 30),
        Text("${S.current.bind_account}: ${CommonPreferences.tjuuname.value}",
            style: TextUtil.base.bold
                .sp(15)
                .customColor(Color.fromRGBO(79, 88, 107, 1))),
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
                style: TextUtil.base.regular.white.sp(13)),
            style: ButtonStyle(
              elevation: MaterialStateProperty.all(3),
              overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.pressed))
                  return Color.fromRGBO(103, 110, 150, 1.0);
                return Color.fromRGBO(79, 88, 107, 1);
              }),
              backgroundColor:
                  MaterialStateProperty.all(Color.fromRGBO(79, 88, 107, 1)),
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
            style: TextUtil.base.regular
                .sp(10)
                .customColor(Color.fromRGBO(98, 103, 124, 1)),
          ),
          SizedBox(height: 20),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 55),
            child: TextField(
              textInputAction: TextInputAction.next,
              focusNode: _accountFocus,
              cursorColor: ColorUtil.mainColor,
              decoration: InputDecoration(
                  hintText: S.current.tju_account,
                  hintStyle: hintStyle,
                  filled: true,
                  fillColor: Color.fromRGBO(235, 238, 243, 1),
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
                  data: Theme.of(context)
                      .copyWith(primaryColor: Color.fromRGBO(53, 59, 84, 1)),
                  child: TextField(
                    keyboardType: TextInputType.visiblePassword,
                    focusNode: _passwordFocus,
                    cursorColor: ColorUtil.mainColor,
                    decoration: InputDecoration(
                      hintText: S.current.password,
                      hintStyle: hintStyle,
                      filled: true,
                      fillColor: Color.fromRGBO(235, 238, 243, 1),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 18),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                      suffixIcon: GestureDetector(
                        child: Icon(
                          value ? Icons.visibility_off : Icons.visibility,
                          color: ColorUtil.mainColor,
                        ),
                        onTap: () {
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
                  style: TextUtil.base.regular.white.sp(13)),
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(5),
                overlayColor:
                    MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.pressed))
                    return Color.fromRGBO(103, 110, 150, 1);
                  return Color.fromRGBO(53, 59, 84, 1);
                }),
                backgroundColor:
                    MaterialStateProperty.all(Color.fromRGBO(53, 59, 84, 1)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
              ),
            ),
          ),
          SizedBox(height: 35),
          Text(
            '应学校要求，校外使用教育教学信息管理系统需先登录天津大学VPN，'
            '故在校外访问微北洋课表、GPA功能也需登录VPN绑定办公网账号后使用。',
            style: TextUtil.base.regular
                .sp(10)
                .customColor(Color.fromRGBO(98, 103, 124, 1)),
          ),
          Row(
            children: [
              Text(
                '办公网网址为 ',
                style: TextUtil.base.regular
                    .sp(10)
                    .customColor(Color.fromRGBO(98, 103, 124, 1)),
              ),
              GestureDetector(
                onTap: () async {
                  String url = 'http://classes.tju.edu.cn/';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  } else {
                    ToastProvider.error('请检查网络状态');
                  }
                },
                child: Text('classes.tju.edu.cn',
                    style: TextUtil.base.regular.blue363C.underLine.sp(10)),
              ),
            ],
          ),
          SizedBox(height: 35),
        ]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!CommonPreferences.isBindTju.value) {
          ToastProvider.error('请绑定办公网');
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Color.fromRGBO(250, 250, 250, 1),
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: GestureDetector(
                  child: Icon(Icons.arrow_back,
                      color: Color.fromRGBO(53, 59, 84, 1), size: 32),
                  onTap: () => Navigator.pop(context)),
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
                        style: TextUtil.base.bold
                            .sp(28)
                            .customColor(Color.fromRGBO(48, 60, 102, 1))),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 22, 0, 50),
                    child: Text(
                        CommonPreferences.isBindTju.value
                            ? S.current.is_bind
                            : S.current.not_bind,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold)),
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
      ),
    );
  }
}
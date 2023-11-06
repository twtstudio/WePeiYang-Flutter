import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/network/classes_service.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/util/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class TjuRebindDialog extends Dialog {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        // 防止验证码被键盘遮挡
        margin: EdgeInsets.fromLTRB(
            25, 0, 25, 25 + MediaQuery.of(context).viewInsets.bottom / 2),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: ColorUtil.whiteFFColor),
        child: _TjuRebindWidget(),
      ),
    );
  }
}

class _TjuRebindWidget extends StatefulWidget {
  @override
  _TjuRebindWidgetState createState() => _TjuRebindWidgetState();
}

class _TjuRebindWidgetState extends State<_TjuRebindWidget> {
  String captcha = '';

  TextEditingController codeController = TextEditingController();
  final GlobalKey<CaptchaWidgetState> captchaKey = GlobalKey();
  late final CaptchaWidget captchaWidget;

  @override
  void initState() {
    super.initState();
    captchaWidget = CaptchaWidget(captchaKey);
    // 检测办公网
    _checkClasses();
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  void _bind() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (captcha == '') {
      ToastProvider.error('验证码不能为空');
      return;
    }
    try {
      await ClassesService.getClasses(context, code: captcha);
      Navigator.pop(context);
    } on DioException catch (e) {
      var str = e.error.toString();
      if (str == '网络连接超时') str = '请连接校园网后再次尝试';
      ToastProvider.error(str);
    } finally {
      codeController.clear();
      captchaKey.currentState?.refresh();
    }
  }

  /// 能否连接到办公网
  bool _canConnectToClasses = true;

  _checkClasses() async {
    _canConnectToClasses = await ClassesService.check();
    setState(() {});
    if (!_canConnectToClasses) {
      Future.delayed(Duration(seconds: 1)).then((_) {
        _checkClasses();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var hintStyle = TextUtil.base.regular.sp(13).whiteHint201;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset('assets/images/tju_error.png', height: 25),
          SizedBox(width: 5),
          Text(S.current.wrong + "！", style: TextUtil.base.bold.sp(17).blue79)
        ]),
        SizedBox(height: 8),
        Text('请求异常，请手动输入验证码', style: TextUtil.base.regular.sp(12).blue79),
        if (!_canConnectToClasses)
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text('请连接至校园网环境以获取数据，请检查网络',
                style: TextUtil.base.regular.sp(10).redD9),
          ),
        SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 55,
                width: 120,
                child: TextField(
                  controller: codeController,
                  decoration: InputDecoration(
                      hintText: S.current.captcha,
                      hintStyle: hintStyle,
                      filled: true,
                      fillColor: ColorUtil.white235,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 18),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none)),
                  onChanged: (input) => setState(() => captcha = input),
                ),
              ),
            ),
            SizedBox(width: 20),
            SizedBox(height: 55, width: 100, child: captchaWidget)
          ],
        ),
        Container(
            height: 50,
            width: 400,
            margin: const EdgeInsets.fromLTRB(25, 30, 25, 10),
            child: ElevatedButton(
              onPressed: _bind,
              child: Text(S.current.login,
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
            )),
      ],
    );
  }
}

class CaptchaWidget extends StatefulWidget {
  CaptchaWidget(Key key) : super(key: key);

  @override
  State<CaptchaWidget> createState() => CaptchaWidgetState();
}

class CaptchaWidgetState extends State<CaptchaWidget> {
  Uint8List? data;

  void refresh() async {
    await ClassesService.logout();
    var res = await ClassesService.spiderDio.get(
        'https://sso.tju.edu.cn/cas/code',
        options: Options(responseType: ResponseType.bytes));
    setState(() {
      data = res.data;
    });
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: refresh,
        child:
            data == null ? CupertinoActivityIndicator() : Image.memory(data!));
  }
}

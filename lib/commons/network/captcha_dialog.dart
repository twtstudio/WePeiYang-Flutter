import 'package:flutter/material.dart';
import 'spider_service.dart';

class CaptchaDialog extends Dialog {
  final Map<String, String> map;
  final String username;
  final String password;
  static String captcha = "";

  CaptchaDialog(this.map, this.username, this.password);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 400,
        width: 200,
        child: Column(
          children: [
            Material(
              child: TextField(
                  decoration: InputDecoration(
                      labelText: 'Captcha',
                      contentPadding: const EdgeInsets.only(top: 5)),
                  onChanged: (input) => captcha = input),
            ),
            // TODO 这里会报错 DioError [DioErrorType.RESPONSE]: Http status error [302]
            Image.network("https://sso.tju.edu.cn/cas/images/kaptcha.jpg",
                headers: {"Cookie": map['session']}, width: 50, height: 50),
            RaisedButton(
                onPressed: () =>
                    ssoLogin(context, username, password, captcha, map),
                child: Text("确定"))
          ],
        ),
      ),
    );
  }
}

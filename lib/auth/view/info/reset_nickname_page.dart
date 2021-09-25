import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';

class ResetNicknamePage extends StatefulWidget {
  @override
  _ResetNicknamePageState createState() => _ResetNicknamePageState();
}

class _ResetNicknamePageState extends State<ResetNicknamePage> {
  String nickname = "";
  FocusNode node = FocusNode();

  _reset() async {
    if (nickname == "") {
      ToastProvider.error("用户名不能为空");
      return;
    }
    AuthService.changeNickname(nickname,
        onSuccess: () {
          ToastProvider.success("更改用户名成功");
          Navigator.pop(context);
        },
        onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  @override
  void dispose() {
    node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(S.current.reset_username,
                style: FontManager.YaHeiRegular.copyWith(
                    fontSize: 17,
                    color: Color.fromRGBO(36, 43, 69, 1),
                    fontWeight: FontWeight.bold)),
            elevation: 0,
            brightness: Brightness.light,
            centerTitle: true,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: GestureDetector(
                  child: Icon(Icons.arrow_back,
                      color: Color.fromRGBO(53, 59, 84, 1.0), size: 32),
                  onTap: () => Navigator.pop(context)),
            )),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: TextField(
              focusNode: node,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(0, 16, 0, 12),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromRGBO(48, 60, 102, 1), width: 2)),
                  suffixIcon: IconButton(
                      onPressed: _reset,
                      icon: Text(S.current.save,
                          style: FontManager.YaQiHei.copyWith(
                              color: Color.fromRGBO(98, 103, 124, 1),
                              fontWeight: FontWeight.bold,
                              fontSize: 13)))),
              onChanged: (input) => setState(() => nickname = input)),
        ));
  }
}

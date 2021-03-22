import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/auth/network/auth_service.dart';

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
    changeNickname(nickname,
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
            title: Text('更改用户名',
                style: TextStyle(
                    fontSize: 17,
                    color: Color.fromRGBO(36, 43, 69, 1),
                    fontWeight: FontWeight.bold)),
            elevation: 0,
            brightness: Brightness.light,
            centerTitle: true,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.only(left: 5),
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
                      icon: Text("保存",
                          style: TextStyle(
                              color: Color.fromRGBO(98, 103, 124, 1),
                              fontWeight: FontWeight.bold,
                              fontSize: 14)))),
              onChanged: (input) => setState(() => nickname = input)),
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/auth/network/auth_service.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';

class RegisterPageOne extends StatefulWidget {
  @override
  _RegisterPageOneState createState() => _RegisterPageOneState();
}

class _RegisterPageOneState extends State<RegisterPageOne> {
  String userNum = ""; // 学号
  String idNum = ""; // 身份证号
  String email = "";
  String phone = "";
  String code = "";
  bool isPress = false;

  _fetchCaptcha() async {
    if (phone == "") {
      ToastProvider.error("手机号码不能为空");
      return;
    }
    getCaptchaOnRegister(phone,
        onSuccess: () {
          setState(() => isPress = true);
        },
        onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  _submit() async {
    setState(() => isPress = false);
    if (userNum == "")
      ToastProvider.error("学号不能为空");
    else if (idNum == "")
      ToastProvider.error("身份证号不能为空");
    else if (email == "")
      ToastProvider.error("E-mail不能为空");
    else if (phone == "")
      ToastProvider.error("手机号码不能为空");
    else if (code == "")
      ToastProvider.error("短信验证码不能为空");
    else {
      Map arg = ModalRoute.of(context).settings.arguments ??
          {'nickname': "", 'password': ""};
      Navigator.pushReplacementNamed(context, '/register2', arguments: {
        'userNum': userNum,
        'idNum': idNum,
        'email': email,
        'phone': phone,
        'code': code,
        'nickname': arg['nickname'],
        'password': arg['password']
      });
    }
  }

  TextEditingController _userNumCrl;
  TextEditingController _idNumCrl;
  TextEditingController _emailCrl;
  TextEditingController _phoneCrl;
  TextEditingController _codeCrl;

  FocusNode _userNumFocus = FocusNode();
  FocusNode _idNumFocus = FocusNode();
  FocusNode _emailFocus = FocusNode();
  FocusNode _phoneFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    Map arg = ModalRoute.of(context).settings.arguments;
    if (arg != null) {
      userNum = arg['userNum'];
      idNum = arg['idNum'];
      email = arg['email'];
      phone = arg['phone'];
      code = arg['code'];
      _userNumCrl =
          TextEditingController.fromValue(TextEditingValue(text: userNum));
      _idNumCrl =
          TextEditingController.fromValue(TextEditingValue(text: idNum));
      _emailCrl =
          TextEditingController.fromValue(TextEditingValue(text: email));
      _phoneCrl =
          TextEditingController.fromValue(TextEditingValue(text: phone));
      _codeCrl = TextEditingController.fromValue(TextEditingValue(text: code));
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(98, 103, 123, 1), size: 35),
                onTap: () => Navigator.pop(context)),
          )),
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: Text("新用户注册",
                style: TextStyle(
                    color: Color.fromRGBO(98, 103, 123, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
            child: Theme(
              data: ThemeData(hintColor: Color.fromRGBO(98, 103, 123, 1)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 100,
                ),
                child: TextField(
                  controller: _userNumCrl,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  focusNode: _userNumFocus,
                  decoration: InputDecoration(
                      labelText: '学号',
                      filled: true,
                      fillColor: Color.fromRGBO(235, 238, 243, 1),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.fromLTRB(15, 20, 0, 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onChanged: (input) => setState(() => userNum = input),
                  onEditingComplete: () {
                    _userNumFocus.unfocus();
                    FocusScope.of(context).requestFocus(_idNumFocus);
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
            child: Theme(
              data: ThemeData(hintColor: Color.fromRGBO(98, 103, 123, 1)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 100,
                ),
                child: TextField(
                  controller: _idNumCrl,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  focusNode: _idNumFocus,
                  decoration: InputDecoration(
                      labelText: '身份证号',
                      filled: true,
                      fillColor: Color.fromRGBO(235, 238, 243, 1),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.fromLTRB(15, 20, 0, 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onChanged: (input) => setState(() => idNum = input),
                  onEditingComplete: () {
                    _idNumFocus.unfocus();
                    FocusScope.of(context).requestFocus(_emailFocus);
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
            child: Theme(
              data: ThemeData(hintColor: Color.fromRGBO(98, 103, 123, 1)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 100,
                ),
                child: TextField(
                  controller: _emailCrl,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  focusNode: _emailFocus,
                  decoration: InputDecoration(
                      labelText: 'E-mail',
                      filled: true,
                      fillColor: Color.fromRGBO(235, 238, 243, 1),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.fromLTRB(15, 20, 0, 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onChanged: (input) => setState(() => email = input),
                  onEditingComplete: () {
                    _emailFocus.unfocus();
                    FocusScope.of(context).requestFocus(_phoneFocus);
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
            child: Theme(
              data: ThemeData(hintColor: Color.fromRGBO(98, 103, 123, 1)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 100,
                ),
                child: TextField(
                  controller: _phoneCrl,
                  keyboardType: TextInputType.visiblePassword,
                  focusNode: _phoneFocus,
                  decoration: InputDecoration(
                      labelText: '手机号码',
                      filled: true,
                      fillColor: Color.fromRGBO(235, 238, 243, 1),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.fromLTRB(15, 20, 0, 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onChanged: (input) => setState(() => phone = input),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 40, 30, 0),
            child: Row(
              children: [
                Theme(
                  data: ThemeData(hintColor: Color.fromRGBO(98, 103, 123, 1)),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 100,
                      maxWidth: 150,
                    ),
                    child: TextField(
                      controller: _codeCrl,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                          labelText: '短信验证码',
                          filled: true,
                          fillColor: Color.fromRGBO(235, 238, 243, 1),
                          isCollapsed: true,
                          contentPadding: EdgeInsets.fromLTRB(15, 20, 0, 20),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onChanged: (input) => setState(() => code = input),
                    ),
                  ),
                ),
                Expanded(child: Text("")),
                Container(
                    height: 55,
                    width: 120,
                    margin: const EdgeInsets.only(left: 20),
                    child: RaisedButton(
                      onPressed: _fetchCaptcha,
                      color: isPress
                          ? Color.fromRGBO(235, 238, 243, 1)
                          : Color.fromRGBO(53, 59, 84, 1.0),
                      splashColor: Color.fromRGBO(103, 110, 150, 1.0),
                      child: Text('获取验证码',
                          style: TextStyle(
                              color: isPress
                                  ? Color.fromRGBO(201, 204, 209, 1)
                                  : Colors.white,
                              fontSize: 16)),
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                    )),
              ],
            ),
          ),
          Expanded(child: Text("")),
          Container(
            height: 50,
            alignment: Alignment.bottomRight,
            margin: const EdgeInsets.all(30),
            child: GestureDetector(
              onTap: _submit,
              child: Image(image: AssetImage('assets/images/arrow_round.png')),
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterPageTwo extends StatefulWidget {
  @override
  _RegisterPageTwoState createState() => _RegisterPageTwoState();
}

class _RegisterPageTwoState extends State<RegisterPageTwo> {
  String nickname = "";
  String password1 = "";
  String password2 = "";

  _back() async {
    Map arg = ModalRoute.of(context).settings.arguments;
    arg['nickname'] = nickname;
    arg['password'] = password1;
    Navigator.pushReplacementNamed(context, '/register1', arguments: arg);
  }

  _submit() async {
    if (nickname == "")
      ToastProvider.error("用户名不能为空");
    else if (password1 == "")
      ToastProvider.error("请输入密码");
    else if (password2 == "")
      ToastProvider.error("请再次输入密码");
    else if (password1 != password2)
      ToastProvider.error("两次输入密码不一致");
    else {
      Map arg = ModalRoute.of(context).settings.arguments;
      register(arg['userNum'], nickname, arg['phone'], arg['code'], password1,
          arg['email'], arg['idNum'],
          onSuccess: () {
            ToastProvider.success("注册成功");
            Navigator.pushNamedAndRemoveUntil(
                context, '/login', (route) => false);
          },
          onFailure: (e) => ToastProvider.error(e.error.toString()));
    }
  }

  TextEditingController _nameCrl;
  TextEditingController _pw1Crl;
  TextEditingController _pw2Crl;

  FocusNode _nameFocus = FocusNode();
  FocusNode _pw1Focus = FocusNode();
  FocusNode _pw2Focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    Map arg = ModalRoute.of(context).settings.arguments;
    if (arg != null) {
      nickname = arg['nickname'];
      password1 = arg['password'];
      password2 = arg['password'];
      _nameCrl =
          TextEditingController.fromValue(TextEditingValue(text: nickname));
      _pw1Crl =
          TextEditingController.fromValue(TextEditingValue(text: password1));
      _pw2Crl =
          TextEditingController.fromValue(TextEditingValue(text: password2));
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(98, 103, 123, 1), size: 35),
                onTap: () => Navigator.pop(context)),
          )),
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: Text("新用户注册",
                style: TextStyle(
                    color: Color.fromRGBO(98, 103, 123, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
            child: Theme(
              data: ThemeData(hintColor: Color.fromRGBO(98, 103, 123, 1)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 100,
                ),
                child: TextField(
                  controller: _nameCrl,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  focusNode: _nameFocus,
                  decoration: InputDecoration(
                      labelText: '用户名',
                      filled: true,
                      fillColor: Color.fromRGBO(235, 238, 243, 1),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.fromLTRB(15, 20, 0, 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onChanged: (input) => setState(() => nickname = input),
                  onEditingComplete: () {
                    _nameFocus.unfocus();
                    FocusScope.of(context).requestFocus(_pw1Focus);
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
            child: Theme(
              data: ThemeData(hintColor: Color.fromRGBO(98, 103, 123, 1)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 100,
                ),
                child: TextField(
                  controller: _pw1Crl,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  focusNode: _pw1Focus,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: '请输入新密码',
                      filled: true,
                      fillColor: Color.fromRGBO(235, 238, 243, 1),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.fromLTRB(15, 20, 0, 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onChanged: (input) => setState(() => password1 = input),
                  onEditingComplete: () {
                    _pw1Focus.unfocus();
                    FocusScope.of(context).requestFocus(_pw2Focus);
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
            child: Theme(
              data: ThemeData(hintColor: Color.fromRGBO(98, 103, 123, 1)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 100,
                ),
                child: TextField(
                  controller: _pw2Crl,
                  keyboardType: TextInputType.visiblePassword,
                  focusNode: _pw2Focus,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: '再次输入密码',
                      filled: true,
                      fillColor: Color.fromRGBO(235, 238, 243, 1),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.fromLTRB(15, 20, 0, 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onChanged: (input) => setState(() => password2 = input),
                ),
              ),
            ),
          ),
          Expanded(child: Text("")),
          Row(
            children: [
              Container(
                height: 50,
                alignment: Alignment.bottomLeft,
                margin: const EdgeInsets.all(30),
                child: GestureDetector(
                  onTap: _back,
                  child:
                      Image(image: AssetImage('assets/images/arrow_round.png')),
                ),
              ),
              Container(
                height: 50,
                alignment: Alignment.bottomRight,
                margin: const EdgeInsets.all(30),
                child: GestureDetector(
                  onTap: _submit,
                  child:
                      Image(image: AssetImage('assets/images/arrow_round.png')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/test/test_router.dart';
import '../widgets/w_button.dart';

class TestMainPage extends StatelessWidget {
  const TestMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("测试主页"),
      ),
      body: ListView(
        children: [
          WButton(
            onPressed: () {
              Navigator.pushNamed(context, TestRouter.pushTest);
            },
            child: Text("推送测试页面"),
          ),
          WButton(
            onPressed: () {
              Navigator.pushNamed(context, TestRouter.updateTest);
            },
            child: Text("更新测试页面"),
          ),
          WButton(
            onPressed: () {
              Navigator.pushNamed(context, TestRouter.qsltTest);
            },
            child: Text("求实论坛测试页面"),
          ),
          WButton(
            onPressed: () {
              Navigator.pushNamed(context, TestRouter.fontTest);
            },
            child: Text("字体测试页面"),
          ),
        ],
      ),
    );
  }
}

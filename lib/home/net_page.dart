import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/schedule/service/schedule_service.dart';

/// 此篇代码纯测试用
class CPage extends StatefulWidget {
  @override
  CPageState createState() => CPageState();
}

class CPageState extends State<CPage> {
  String _text = "aaaaaaaaa";

  _testFun() async{
    getClassTable(onSuccess: (schedule){
        setState(() {
          _text = schedule.toString();
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 100),
          child: Center(
            child: Column(
              children: <Widget>[
                Container(
                  width: 100,
                  height: 100,
                  child: RaisedButton(
                    child: Text("Test Dio"),
                    onPressed: () {
                      _testFun();
                    },
                  ),
                ),
                Container(child: Text(_text), height: 100)
              ],
            ),
          ),
        ));
  }
}

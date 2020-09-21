import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/network/dio_server.dart';

/// 此篇代码纯测试用
class CPage extends StatefulWidget {
  @override
  CPageState createState() => CPageState();
}

class CPageState extends State<CPage> {
  String _text = "aaaaaaaaa";

  _getGpa() async{
    var dio = await DioService.create();
    await dio.getCall("v1/gpa", onSuccess: (commonBody){
      setState(() {
        _text = commonBody.data.toString();
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
                      _getGpa();
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

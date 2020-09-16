import 'package:flutter/material.dart';

import 'file:///D:/AndroidProject/wei_pei_yang_demo/lib/gpa/gpa_model.dart';
import 'file:///D:/AndroidProject/wei_pei_yang_demo/lib/gpa/gpa_service.dart';

class CPage extends StatefulWidget {
  @override
  CPageState createState() => CPageState();
}

class CPageState extends State<CPage> {
  String _text = "aaaaaaaaa";

  _getGpa() {
    getGPABean(onSuccess: (commonBody) {
      var gpaBean = GPABean.fromJson(commonBody.data);
      var stat = gpaBean.data.toString();
      setState(() {
        _text = stat;
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

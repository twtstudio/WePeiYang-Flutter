import 'package:flutter/material.dart';

import 'package:wei_pei_yang_demo/gpa/model/gpa_model.dart';
import 'package:wei_pei_yang_demo/gpa/network/gpa_service.dart';

class CPage extends StatefulWidget {
  @override
  CPageState createState() => CPageState();
}

class CPageState extends State<CPage> {
  String _text = "aaaaaaaaa";

  _getGpa() {
    getGPABean(onSuccess: (commonBody) {
      var gpaBean = GPABean.fromJson(commonBody.data);
      var stat = gpaBean.stat.toString();
      setState(() {
        _text = stat;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 300),
          child: Center(
            child: Column(
              children: <Widget>[
                RaisedButton(
                  child: Text("Test Dio"),
                  onPressed: () {
                    _getGpa();
                  },
                ),
                Container(child: Text(_text), height: 100)
              ],
            ),
          ),
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/network/dio_server.dart';
import 'package:dio/dio.dart';
import 'package:wei_pei_yang_demo/model.dart';

class CPage extends StatefulWidget {
  @override
  CPageState createState() => CPageState();
}

class CPageState extends State<CPage> {
  String _text = "aaaaaaaaa";

  void _login() async {
    Dio dio = await DioService().create();
    var response = await dio.get("v1/auth/token/get",
        queryParameters: {"twtuname": "3019244334", "twtpasswd": "125418"});
    var a = CommonBody.fromJson(response.data.toString());
    setState(() {
      // _token = response.data.toString();
      _text = Token.fromJson(a.data).token;
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
                _login();
              },
            ),
            Text(_text)
          ],
        ),
      ),
    ));
  }
}

import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/network/dio_server.dart';
import 'package:dio/dio.dart';

class CPage extends StatefulWidget {
  @override
  CPageState createState() => CPageState();
}

class CPageState extends State<CPage> {
  String string = "here is no info";

  void _login() async {
    Dio dio = await DioService().create();
    await dio.getCall("v1/auth/token/get",
        queryParameters: {"twtuname": "3019244334", "twtpasswd": "125418"},
        onSuccess: (commonBody) {
      setState(() {
        string = commonBody.data.toString();
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
                _login();
              },
            ),
            Text(string)
          ],
        ),
      ),
    ));
  }
}

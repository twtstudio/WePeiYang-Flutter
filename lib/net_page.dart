import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/dio_server.dart';
import 'package:dio/dio.dart';
import 'package:wei_pei_yang_demo/model.dart';

class CPage extends StatefulWidget {
  @override
  CPageState createState() => CPageState();
}

class CPageState extends State<CPage> {
  var commonBody = null;

  void _login() async {
    Dio dio = await DioService().getDio();
    var response = await dio.get("v1/auth/token/get",
        queryParameters: {"twtuname": "3019244334", "twtpasswd": "125418"});
    setState(() {
      commonBody = CommonBody.fromJson(response.data.toString());
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
            Text(commonBody.toString())
          ],
        ),
      ),
    ));
  }
}

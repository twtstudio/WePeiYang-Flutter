import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';

class DebugPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<String> list = Logger.logs;
    return Scaffold(
      appBar: AppBar(
          title: Text("日志页面"),
          centerTitle: true,
          backgroundColor: WpyTheme.of(context).get(WpyColorKey.oldSecondaryActionColor)),
      body: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
          itemCount: list.length,
          itemBuilder: (context, index) {
            return Text(list[index], style: TextStyle(fontSize: 10));
          }),
    );
  }
}

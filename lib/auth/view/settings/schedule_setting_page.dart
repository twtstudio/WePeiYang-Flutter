import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';

class ScheduleSettingPage extends StatefulWidget {
  @override
  _ScheduleSettingPageState createState() => _ScheduleSettingPageState();
}

class _ScheduleSettingPageState extends State<ScheduleSettingPage> {
  final upNumberList = ["5天", "6天", "7天"];
  final downNumberList = ["周一至周五", "周一至周六", "周一至周日"];
  int _index = CommonPreferences().dayNumber.value - 5;

  Widget _judgeIndex(int index) {
    if (index != _index)
      return Container();
    else
      return Padding(
        padding: const EdgeInsets.only(right: 22),
        child: Icon(
          Icons.check,
        ),
      );
  }

  BorderRadius _judgeBorder(int index) {
    if (index == 0)
      return BorderRadius.vertical(top: Radius.circular(9));
    else if (index == 1)
      return BorderRadius.zero;
    else
      return BorderRadius.vertical(bottom: Radius.circular(9));
  }

  Widget _getNumberOfDaysCard(BuildContext context, int index) {
    const hintTextStyle =
        TextStyle(fontSize: 13.0, color: Color.fromRGBO(205, 206, 212, 1));
    const mainTextStyle = TextStyle(
      fontSize: 18.0,
      color: Color.fromRGBO(98, 103, 122, 1),
    );
    return InkWell(
      onTap: () {
        setState(() => _index = index);
        CommonPreferences().dayNumber.value = index + 5;
      },
      borderRadius: _judgeBorder(index),
      splashFactory: InkRipple.splashFactory,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Row(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    width: 150,
                    child: Text(upNumberList[index], style: mainTextStyle)),
                Container(
                    width: 150,
                    child: Text(downNumberList[index], style: hintTextStyle),
                    padding: const EdgeInsets.only(top: 3))
              ],
            ),
            Expanded(child: Text('')),
            _judgeIndex(index)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          elevation: 0,
          brightness: Brightness.light,
          leading: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(53, 59, 84, 1.0), size: 32),
                onTap: () => Navigator.pop(context)),
          )),
      body: ListView(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.fromLTRB(35, 20, 35, 0),
            child: Text("课程表-每周展示天数",
                style: TextStyle(
                    color: Color.fromRGBO(48, 60, 102, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 28)),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(35, 20, 35, 20),
            alignment: Alignment.centerLeft,
            child: Text("课程表页面将会根据选择调整展示的天数。",
                style: TextStyle(
                    color: Color.fromRGBO(98, 103, 124, 1), fontSize: 12)),
          ),
          Container(
              child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9)),
                  child: Column(
                    children: <Widget>[
                      _getNumberOfDaysCard(context, 0),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        height: 1.0,
                        color: Color.fromRGBO(212, 214, 226, 1),
                      ),
                      _getNumberOfDaysCard(context, 1),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        height: 1.0,
                        color: Color.fromRGBO(212, 214, 226, 1),
                      ),
                      _getNumberOfDaysCard(context, 2),
                    ],
                  ))),
        ],
      ),
    );
  }
}

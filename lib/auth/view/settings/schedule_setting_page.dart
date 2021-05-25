import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/generated/l10n.dart';
import 'package:wei_pei_yang_demo/commons/util/font_manager.dart';

class ScheduleSettingPage extends StatefulWidget {
  @override
  _ScheduleSettingPageState createState() => _ScheduleSettingPageState();
}

class _ScheduleSettingPageState extends State<ScheduleSettingPage> {
  final upNumberList = [
    "5${S.current.day}",
    "6${S.current.day}",
    "7${S.current.day}"
  ];
  final downNumberList = [
    S.current.mon_fri,
    S.current.mon_sat,
    S.current.mon_sun
  ];
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
    var hintTextStyle = FontManager.YaHeiRegular.copyWith(
        fontSize: 12, color: Color.fromRGBO(205, 206, 212, 1));
    var mainTextStyle = FontManager.YaHeiRegular.copyWith(
      fontSize: 16.5,
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
            padding: const EdgeInsets.only(left: 15),
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
            child: Text("${S.current.schedule}-${S.current.setting_day_number}",
                style: FontManager.YaQiHei.copyWith(
                    color: Color.fromRGBO(48, 60, 102, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 28)),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(35, 15, 35, 20),
            alignment: Alignment.centerLeft,
            child: Text(S.current.setting_day_number_hint,
                style: FontManager.YaHeiRegular.copyWith(
                    color: Color.fromRGBO(98, 103, 124, 1), fontSize: 11.5)),
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

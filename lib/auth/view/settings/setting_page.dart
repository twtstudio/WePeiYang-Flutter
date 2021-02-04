import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingPageState();
  }
}

class SettingPageState extends State<SettingPage> {
  bool gpa_switch_value = false;
  bool night_mode_switch_value = false;
  bool schedule_show_switch_value = false;
  bool reminder_before_class_start = false;
  bool reminder_before_class = false;
  String language = '简体中文';
  int dayNumber = 6;

  _myCupertinoSwitch(bool switchValue) {
    return CupertinoSwitch(
      value: switchValue,
      onChanged: (onOff) {
        setState(() {
          switchValue = onOff;
        });
      },
      activeColor: Color.fromRGBO(53, 59, 84, 1.0),
      trackColor: Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    const textStyle =
        TextStyle(fontSize: 12.0, color: Color.fromRGBO(205, 206, 212, 1));
    const mainTextStyle = TextStyle(
      fontSize: 18.0,
      color: Color.fromRGBO(98, 103, 122, 1),
    );
    const arrow = Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 22);
    return Scaffold(
      appBar: AppBar(
          title: Text('设置',
              style: TextStyle(
                  fontSize: 22.0,
                  color: Color.fromRGBO(53, 59, 84, 1.0),
                  fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          leading: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(53, 59, 84, 1.0), size: 35),
                onTap: () => Navigator.pop(context)),
          )),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top:15,left: 10,bottom: 5),
                child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text('通用',
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Color.fromRGBO(177, 180, 186, 1),
                        ))),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 90,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9)),
                        child: InkWell(
                          onTap: () =>
                              Navigator.pushNamed(context, '/language_setting'),
                          splashFactory: InkRipple.splashFactory,
                          borderRadius: BorderRadius.circular(9),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 22),
                            child: Row(
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        width: 150,
                                        child:
                                            Text('系统语言', style: mainTextStyle)),
                                    Container(
                                        child:
                                            Text('$language', style: textStyle),
                                        width: 150,
                                        padding: const EdgeInsets.only(top: 3))
                                  ],
                                ),
                                Expanded(child: Text('')),
                                Padding(
                                    padding: const EdgeInsets.only(right: 22),
                                    child: arrow)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 90,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9)),
                        child: InkWell(
                          onTap: () =>
                              Navigator.pushNamed(context, '/language_setting'),
                          splashFactory: InkRipple.splashFactory,
                          borderRadius: BorderRadius.circular(9),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 22),
                            child: Row(
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                        width: 230,
                                        child:
                                            Text('调色板', style: mainTextStyle)),
                                    Container(
                                        width: 230,
                                        child: Text('给课表、GPA以及黄页自定义喜欢的颜色',
                                            style: textStyle),
                                        padding: const EdgeInsets.only(top: 3))
                                  ],
                                ),
                                Expanded(child: Text('')),
                                Padding(
                                    padding: const EdgeInsets.only(right: 22),
                                    child: arrow)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 90,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9)),
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 22),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      width: 150,
                                      child: Text('首页不显示GPA',
                                          style: mainTextStyle)),
                                ],
                              ),
                            ),
                            Expanded(child: Text('')),
                            Padding(
                                padding: const EdgeInsets.only(right: 22),
                                child: _myCupertinoSwitch(gpa_switch_value))
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 90,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9)),
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 22),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                          width: 240,
                                          child: Text('开启夜猫子模式',
                                              style: mainTextStyle)),
                                      Container(
                                          width: 240,
                                          child: Text(
                                            '晚上9:00以后首页课表将展示第二天课程安排',
                                            style: textStyle,
                                          ),
                                          padding:
                                              const EdgeInsets.only(top: 3))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(child: Text('')),
                            Padding(
                                padding: const EdgeInsets.only(right: 22),
                                child:
                                    _myCupertinoSwitch(night_mode_switch_value))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top:15,left: 10,bottom: 5),
                child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text('课程表',
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Color.fromRGBO(177, 180, 186, 1),
                        ))),
              ),
              Expanded(
                  child: Column(children: <Widget>[
                Container(
                  height: 90,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9)),
                    child: InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, '/schedule_setting'),
                      splashFactory: InkRipple.splashFactory,
                      borderRadius: BorderRadius.circular(9),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 22),
                        child: Row(
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    width: 150,
                                    child:
                                        Text('每周显示天数', style: mainTextStyle)),
                                Container(
                                    child: Text('$dayNumber', style: textStyle),
                                    width: 150,
                                    padding: const EdgeInsets.only(top: 3))
                              ],
                            ),
                            Expanded(child: Text('')),
                            Padding(
                                padding: const EdgeInsets.only(right: 22),
                                child: arrow)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 90,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9)),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 22),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                      width: 230,
                                      child: Text('课表显示非本周课程',
                                          style: mainTextStyle)),
                                  Container(
                                      width: 230,
                                      child: Text('课表中将会展示当周并未开课的课程',
                                          style: textStyle),
                                      padding: const EdgeInsets.only(top: 3))
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: Text('')),
                        Padding(
                            padding: const EdgeInsets.only(right: 22),
                            child:
                                _myCupertinoSwitch(schedule_show_switch_value))
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 90,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9)),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 22),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  width: 150,
                                  child: Text('开课前提醒', style: mainTextStyle)),
                            ],
                          ),
                        ),
                        Expanded(child: Text('')),
                        Padding(
                            padding: const EdgeInsets.only(right: 22),
                            child:
                                _myCupertinoSwitch(reminder_before_class_start))
                      ],
                    ),
                  ),
                ),
                Container(
                    height: 120,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9)),
                        child: Padding(
                            padding: const EdgeInsets.only(left: 22),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                          width: 150,
                                          child: Text('课前提醒',
                                              style: mainTextStyle)),
                                      Expanded(child: Text('')),
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(right: 22),
                                          child: _myCupertinoSwitch(
                                              reminder_before_class))
                                    ],
                                  ),
                                ),
                                  Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.fromLTRB(0,0,23,0),
                                    height: 1.0,
                                    color: Colors.grey,
                                  ),

                                Padding(
                                  padding:
                                      const EdgeInsets.only(right: 24, top: 10),
                                  child: Row(
                                    children: <Widget>[
                                      Container(

                                          child: Text('课前提醒时间',
                                              style: mainTextStyle)),
                                      Expanded(child: Text('')),
                                      Container(
                                          child:
                                              Text('15min', style: textStyle)),
                                    ],
                                  ),
                                ),
                              ],
                            )))),
              ])),
            ],
          )),
    );
  }
}

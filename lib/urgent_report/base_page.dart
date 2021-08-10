import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';

class ReportBasePage extends StatelessWidget {
  final Widget body;
  final Widget action;

  const ReportBasePage({this.body, Key key, this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xfff7f7f8),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(140),
          child: Container(
            color: Color(0xff63677b),
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Hero(
              tag: 'appbar',
              transitionOnUserGestures: true,
              child: AppBar(
                titleSpacing: 0,
                leadingWidth: 30,
                brightness: Brightness.light,
                elevation: 0,
                centerTitle: true,
                automaticallyImplyLeading: false,
                title: Text(
                  '防疫信息填报',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                leading: FlatButton(
                  padding: EdgeInsets.all(0),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.transparent,
                actions: [action],
                bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(50),
                    child: SelfInformation()),
              ),
            ),
          ),
        ),
        body: body,
      ),
    );
  }
}

class SelfInformation extends StatefulWidget {
  @override
  _SelfInformationState createState() => _SelfInformationState();
}

class _SelfInformationState extends State<SelfInformation> {
  String name;
  String id;
  String department;
  String type;
  String major;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    name = CommonPreferences().realName.value;
    id = 'ID: ${CommonPreferences().userNumber.value}';
    department = CommonPreferences().department.value;
    type = CommonPreferences().stuType.value;
    major = CommonPreferences().major.value;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(fontSize: 13),
      child: Container(
          height: 90,
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 5),
                      Text(", 你好"),
                    ],
                  ),
                  SizedBox(width: 30),
                  Text(id),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(department),
                  SizedBox(width: 20),
                  Text(type),
                  SizedBox(width: 20),
                  Text(major),
                ],
              ),
            ],
          )),
    );
  }
}

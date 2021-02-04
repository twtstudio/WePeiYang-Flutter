import 'package:flutter/material.dart';

class ScheduleSettingPage extends StatelessWidget {

  final upNumberList = ["5天","6天","7天"];
  final downNumberList = ["周一至周五","周一至周六","周一至周日"];
  Widget _getNumberofDaysCard(BuildContext context, int index){
    const textStyle =
    TextStyle(fontSize: 13.0, color: Color.fromRGBO(205, 206, 212, 1));
    const mainTextStyle = TextStyle(
      fontSize: 18.0,
      color: Color.fromRGBO(98, 103, 122, 1),
    );
    return Padding(
      padding: const EdgeInsets.only(left: 22,top:10),
      child: Row(
        children: <Widget>[
          Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  width: 150,
                  child: Text(upNumberList[index],
                      style: mainTextStyle)),
              Container(
                  width: 150,
                  child: Text(downNumberList[index],
                      style: textStyle),
                  padding:
                  const EdgeInsets.only(top: 3))
            ],
          ),
          Expanded(child: Text('')),
          Padding(
            padding:
            const EdgeInsets.only(right: 22),
            child: Icon(
              Icons.check,
            ),
          )
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(53, 59, 84, 1.0), size: 35),
                onTap: () => Navigator.pop(context)),
          )),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text("课程表-每周展示天数",
                    style: TextStyle(
                        color: Color.fromRGBO(48, 60, 102, 1),
                        fontWeight: FontWeight.bold,
                        fontSize: 30)),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 20.0),
                alignment: Alignment.centerLeft,
                child: Text("课程表页面将会根据选择调整展示的天数。",
                    style: TextStyle(
                        color: Color.fromRGBO(98, 103, 124, 1), fontSize: 12)),
              ),
              Container(
                  height: 250,
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9)),
                      child: Padding(
                          padding: const EdgeInsets.only(left: 22),
                          child: Column(
                            children: <Widget>[
                              _getNumberofDaysCard(context, 0),
                              Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.fromLTRB(0, 10, 23, 10),
                                height: 1.0,
                                color: Colors.grey,
                              ),
                              _getNumberofDaysCard(context, 1),
                              Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.fromLTRB(0, 10, 23, 10),
                                height: 1.0,
                                color: Colors.grey,
                              ),
                              _getNumberofDaysCard(context, 2),
                            ],
                          )))),
            ],
          )),
    );
  }
}

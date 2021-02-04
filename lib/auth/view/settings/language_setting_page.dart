import 'package:flutter/material.dart';

class LanguageSettingPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    const textStyle =
    TextStyle(fontSize: 12.0, color: Color.fromRGBO(205, 206, 212, 1));
    const mainTextStyle =
    TextStyle(fontSize: 18.0, color: Color.fromRGBO(98, 103, 122, 1),
    );
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
                child: Text("系统语言",
                    style: TextStyle(
                        color: Color.fromRGBO(48, 60, 102, 1),
                        fontWeight: FontWeight.bold,
                        fontSize: 30)),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.symmetric(vertical: 15.0),
                child: Text(
                    "请注意，只有WeiPeiyang应用程序级别内的文本将被更改。依赖外部资源的文本，如课程名称和校务转区的回复内容，将不被翻译。",
                    style: TextStyle(
                        color: Color.fromRGBO(98, 103, 124, 1), fontSize: 12)),
              ),
              Container(
                height: 90,
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9)),
                  child: InkWell(
                    onTap: () =>
                        Navigator.pushNamed(context, '/language_setting'),//这里设置点击逻辑
                    splashFactory: InkRipple.splashFactory,
                    borderRadius: BorderRadius.circular(9),
                    child:Padding(
                      padding: const EdgeInsets.only(left: 22),
                      child: Row(
                        children: <Widget>[

                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:<Widget> [

                              Container(
                                  width:150,
                                  child: Text('简体中文', style: mainTextStyle)
                              ),

                              Container(
                                  width:150,
                                  child: Text('简体中文',
                                      style: textStyle),
                                  padding: const EdgeInsets.only(top: 3))
                            ],
                          ),

                          Expanded(child: Text('')),
                          Padding(
                              padding: const EdgeInsets.only(right: 22),
                              child: Icon(
                                Icons.check,
                              ),)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 90,
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9)),
                  child: InkWell(
                    onTap: () =>
                        Navigator.pushNamed(context, '/language_setting'),//这里应该设置点击逻辑
                    splashFactory: InkRipple.splashFactory,
                    borderRadius: BorderRadius.circular(9),
                    child:Padding(
                      padding: const EdgeInsets.only(left: 22),
                      child: Row(
                        children: <Widget>[

                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:<Widget> [

                              Container(
                                  width:150,
                                  child: Text('English', style: mainTextStyle)
                              ),

                              Container(
                                  width:150,
                                  child: Text('英文',
                                      style: textStyle),
                                  padding: const EdgeInsets.only(top: 3))
                            ],
                          ),

                          Expanded(child: Text('')),
                          Padding(
                            padding: const EdgeInsets.only(right: 22),
                            child: Icon(
                              Icons.check,
                            ),)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';

class LanguageSettingPage extends StatefulWidget {
  @override
  _LanguageSettingPageState createState() => _LanguageSettingPageState();
}

class _LanguageSettingPageState extends State<LanguageSettingPage> {
  String _language = CommonPreferences().language.value;

  Widget _judgeLanguage(String value){
    if(_language != value)
      return Container();
    else
      return Padding(
        padding: const EdgeInsets.only(right: 22),
        child: Icon(
          Icons.check,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    const hintTextStyle =
        TextStyle(fontSize: 12, color: Color.fromRGBO(205, 206, 212, 1));
    const mainTextStyle = TextStyle(
      fontSize: 18.0,
      color: Color.fromRGBO(98, 103, 122, 1),
    );
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(53, 59, 84, 1.0), size: 32),
                onTap: () => Navigator.pop(context)),
          )),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(35, 30, 35, 0),
            alignment: Alignment.centerLeft,
            child: Text("系统语言",
                style: TextStyle(
                    color: Color.fromRGBO(48, 60, 102, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 30)),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(35, 15, 35, 15),
            alignment: Alignment.centerLeft,
            child: Text(
                "请注意，只有WeiPeiyang应用程序级别内的文本将被更改。依赖外部资源的文本，如课程名称和校务转区的回复内容，将不被翻译。",
                style: TextStyle(
                    color: Color.fromRGBO(98, 103, 124, 1), fontSize: 9)),
          ),
          Container(
            height: 80,
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9)),
              child: InkWell(
                onTap: () {
                  setState(() => _language = "简体中文");
                  CommonPreferences().language.value = _language;
                },
                splashFactory: InkRipple.splashFactory,
                borderRadius: BorderRadius.circular(9),
                child: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Row(
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              width: 150,
                              child: Text('简体中文', style: mainTextStyle)),
                          Container(
                              width: 150,
                              height: 20,
                              child: Text((_language == '简体中文') ? '简体中文' : "Simplified Chinese", style: hintTextStyle),
                              padding: const EdgeInsets.only(top: 3))
                        ],
                      ),
                      Expanded(child: Text('')),
                      _judgeLanguage("简体中文")
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 80,
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9)),
              child: InkWell(
                onTap: () {
                  setState(() => _language = "English");
                  CommonPreferences().language.value = _language;
                },
                splashFactory: InkRipple.splashFactory,
                borderRadius: BorderRadius.circular(9),
                child: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Row(
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              width: 150,
                              child: Text('English', style: mainTextStyle)),
                          Container(
                              width: 150,
                              height: 20,
                              child: Text((_language == '简体中文') ? '英文' : 'English', style: hintTextStyle),
                              padding: const EdgeInsets.only(top: 3))
                        ],
                      ),
                      Expanded(child: Text('')),
                      _judgeLanguage("English")
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

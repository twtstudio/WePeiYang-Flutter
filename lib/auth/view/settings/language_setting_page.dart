import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:we_pei_yang_flutter/commons/local/local_model.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class LanguageSettingPage extends StatelessWidget {
  Widget _judgeLanguage(String value) => Padding(
        padding: const EdgeInsets.only(right: 22),
        child: Icon(Icons.check),
      );

  @override
  Widget build(BuildContext context) {
    var hintTextStyle = FontManager.YaHeiRegular.copyWith(
        fontSize: 12, color: Color.fromRGBO(205, 206, 212, 1));
    var mainTextStyle = FontManager.YaHeiRegular.copyWith(
      fontSize: 18,
      color: Color.fromRGBO(98, 103, 122, 1),
    );
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          elevation: 0,
          brightness: Brightness.light,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(53, 59, 84, 1), size: 32),
                onTap: () => Navigator.pop(context)),
          )),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(35, 30, 35, 0),
            alignment: Alignment.centerLeft,
            child: Text(S.current.setting_language,
                style: FontManager.YaQiHei.copyWith(
                    color: Color.fromRGBO(48, 60, 102, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 30)),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(35, 15, 35, 15),
            alignment: Alignment.centerLeft,
            child: Text(S.current.setting_language_hint,
                style: FontManager.YaHeiRegular.copyWith(
                    color: Color.fromRGBO(98, 103, 124, 1), fontSize: 9)),
          ),
          Consumer<LocaleModel>(
            builder: (_, model, __) => ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: model.localeValueList.length,
              itemBuilder: (_, index) => SizedBox(
                height: 80,
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9)),
                  child: InkWell(
                    onTap: () async => await model.switchLocale(index),
                    splashFactory: InkRipple.splashFactory,
                    borderRadius: BorderRadius.circular(9),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Row(
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                  width: 150,
                                  child: Text(LocaleModel.localeName(index),
                                      style: mainTextStyle)),
                              SizedBox(height: 3),
                              SizedBox(
                                  width: 150,
                                  height: 20,
                                  child: Text(LocaleModel.localeName(index),
                                      style: hintTextStyle))
                            ],
                          ),
                          Spacer(),
                          if (CommonPreferences.language.value == index)
                            _judgeLanguage(LocaleModel.localeName(index))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

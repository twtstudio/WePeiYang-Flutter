import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:we_pei_yang_flutter/commons/local/local_model.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class LanguageSettingPage extends StatelessWidget {
  Widget _judgeLanguage(String value) => Padding(
        padding: const EdgeInsets.only(right: 22),
        child: Icon(Icons.check),
      );

  @override
  Widget build(BuildContext context) {
    var hintTextStyle = TextUtil.base.regular.sp(12).whiteHint205;
    var mainTextStyle = TextUtil.base.regular.sp(18).blue98122;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: ColorUtil.white250,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
                child:
                    Icon(Icons.arrow_back, color: ColorUtil.blue53, size: 32),
                onTap: () => Navigator.pop(context)),
          )),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(35, 30, 35, 0),
            alignment: Alignment.centerLeft,
            child: Text(S.current.setting_language,
                style: TextUtil.base.bold.sp(30).blue48),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(35, 15, 35, 15),
            alignment: Alignment.centerLeft,
            child: Text(S.current.setting_language_hint,
                style: TextUtil.base.regular.sp(9).blue98),
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

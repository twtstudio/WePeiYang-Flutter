// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class LocaleModel extends ChangeNotifier {
  // zh_Hans_CN => 世界上所有的简体中文
  // final localeValueList = [Platform.localeName, 'zh_Hans_CN', 'en_CN'];
  final localeValueList = ['zh_Hans_CN', 'en_CN'];

  final key = 'language';

  late int _localeIndex;

  int get localeIndex => _localeIndex;

  Locale locale() {
    var value = localeValueList[_localeIndex].split("_");
    return Locale(value[0], '');
  }

  LocaleModel() {
    // _localeIndex = CommonPreferences.getPref().getInt(key) ?? 0;
    _localeIndex = 0;
    S.load(locale());
  }

  switchLocale(int index) async {
    _localeIndex = index;
    await CommonPreferences.sharedPref.setInt(key, index);
    await S.load(locale());
    notifyListeners();
  }

  static String localeName(index) {
    switch (index) {
      case 0:
        return S.current.autoBySystem;
      case 1:
        return '中文';
      case 2:
        return 'English';
      default:
        return '';
    }
  }
}

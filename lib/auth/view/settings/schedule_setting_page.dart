import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/widgets/w_button.dart';

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
  int _index = CommonPreferences.dayNumber.value - 5;

  Widget _judgeIndex(int index) {
    if (index != _index)
      return Container();
    else
      return Padding(
        padding: const EdgeInsets.only(right: 22),
        child: Icon(Icons.check),
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
    final hintTextStyle = TextUtil.base.regular.sp(12).oldHintWhite(context);
    final mainTextStyle =
        TextUtil.base.regular.sp(16.5).oldThirdAction(context);
    return InkWell(
      onTap: () {
        setState(() => _index = index);
        CommonPreferences.dayNumber.value = index + 5;
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
                SizedBox(
                  width: 150,
                  child: Text(upNumberList[index], style: mainTextStyle),
                ),
                SizedBox(height: 3),
                SizedBox(
                  width: 150,
                  child: Text(downNumberList[index], style: hintTextStyle),
                )
              ],
            ),
            Spacer(),
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
          backgroundColor:
              WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: WButton(
                child: Icon(Icons.arrow_back,
                    color:
                        WpyTheme.of(context).get(WpyColorKey.oldActionColor),
                    size: 32),
                onPressed: () => Navigator.pop(context)),
          )),
      body: ListView(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.fromLTRB(35, 20, 35, 0),
            child: Text(
              "${S.current.schedule}-${S.current.setting_day_number}",
              style: TextUtil.base.bold.sp(28).oldFurthAction(context),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(35, 15, 35, 20),
            alignment: Alignment.centerLeft,
            child: Text(
              S.current.setting_day_number_hint,
              style: TextUtil.base.regular.sp(11.5).oldThirdAction(context),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
            child: Column(
              children: <Widget>[
                _getNumberOfDaysCard(context, 0),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  height: 1,
                  color: WpyTheme.of(context).get(WpyColorKey.oldHintColor),
                ),
                _getNumberOfDaysCard(context, 1),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  height: 1,
                  color: WpyTheme.of(context).get(WpyColorKey.oldHintColor),
                ),
                _getNumberOfDaysCard(context, 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

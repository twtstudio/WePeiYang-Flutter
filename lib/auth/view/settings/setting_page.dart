import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/gpa/model/gpa_notifier.dart';
import 'package:we_pei_yang_flutter/schedule/model/schedule_notifier.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  static final titleTextStyle = FontManager.YaHeiBold.copyWith(
      fontSize: 14,
      color: Color.fromRGBO(177, 180, 186, 1),
      fontWeight: FontWeight.bold);
  static final mainTextStyle = FontManager.YaHeiRegular.copyWith(
      fontSize: 14,
      color: Color.fromRGBO(98, 103, 122, 1),
      fontWeight: FontWeight.bold);
  static final hintTextStyle = FontManager.YaHeiRegular.copyWith(
      fontSize: 10, color: Color.fromRGBO(205, 206, 212, 1));
  static final arrow =
      Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 22);

  var pref = CommonPreferences();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(S.current.setting,
              style: FontManager.YaHeiRegular.copyWith(
                  fontSize: 16,
                  color: Color.fromRGBO(36, 43, 69, 1),
                  fontWeight: FontWeight.bold)),
          elevation: 0,
          brightness: Brightness.light,
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(53, 59, 84, 1.0), size: 32),
                onTap: () => Navigator.pop(context)),
          )),
      body: ListView(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
            alignment: Alignment.centerLeft,
            child: Text(S.current.setting_general, style: titleTextStyle),
          ),
          // TODO 系统语言
          // Container(
          //   height: 80,
          //   child: Card(
          //     margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          //     elevation: 0,
          //     shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(9)),
          //     child: InkWell(
          //       onTap: () =>
          //           Navigator.pushNamed(context, AuthRouter.languageSetting).then((_) {
          //         /// 使用pop返回此页面时进行rebuild
          //         this.setState(() {});
          //       }),
          //       splashFactory: InkRipple.splashFactory,
          //       borderRadius: BorderRadius.circular(9),
          //       child: Row(
          //         children: <Widget>[
          //           Column(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               Container(
          //                   width: 150,
          //                   margin: const EdgeInsets.only(left: 15),
          //                   child: Text(S.current.setting_language, style: mainTextStyle)),
          //               Container(
          //                   width: 150,
          //                   margin: const EdgeInsets.only(left: 15, top: 3),
          //                   child: Text(S.current.language,
          //                       style: hintTextStyle,
          //                       textAlign: TextAlign.left))
          //             ],
          //           ),
          //           Expanded(child: Text('')),
          //           Padding(
          //               padding: const EdgeInsets.only(right: 26), child: arrow)
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          Container(
            height: 80,
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9)),
              child: InkWell(
                onTap: () =>
                    Navigator.pushNamed(context, AuthRouter.colorSetting)
                        .then((_) {
                  /// 使用pop返回此页面时进行rebuild
                  this.setState(() {});
                }),
                splashFactory: InkRipple.splashFactory,
                borderRadius: BorderRadius.circular(9),
                child: Row(
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            width: 230,
                            margin: const EdgeInsets.only(left: 15),
                            child: Text(S.current.setting_color,
                                style: mainTextStyle)),
                        Container(
                            width: 230,
                            margin: const EdgeInsets.only(left: 15, top: 3),
                            child: Text(S.current.setting_color_hint,
                                style: hintTextStyle))
                      ],
                    ),
                    Expanded(child: Text('')),
                    Padding(
                        padding: const EdgeInsets.only(right: 26), child: arrow)
                  ],
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
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Container(
                        width: 150,
                        child:
                            Text(S.current.setting_gpa, style: mainTextStyle)),
                  ),
                  Expanded(child: Text('')),
                  Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Switch(
                        value: pref.hideGPA.value,
                        onChanged: (value) {
                          setState(() => pref.hideGPA.value = value);
                          Provider.of<GPANotifier>(context, listen: false)
                              .hideGPAWithNotify = value;
                        },
                        activeColor: Color.fromRGBO(105, 109, 127, 1),
                        inactiveThumbColor: Color.fromRGBO(205, 206, 212, 1),
                        activeTrackColor: Color.fromRGBO(240, 241, 242, 1),
                        inactiveTrackColor: Color.fromRGBO(240, 241, 242, 1),
                      ))
                ],
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
              child: Row(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 210,
                          margin: const EdgeInsets.only(left: 15),
                          child: Text(S.current.setting_night_mode,
                              style: mainTextStyle)),
                      Container(
                          width: 210,
                          margin: const EdgeInsets.only(left: 15, top: 3),
                          child: Text(
                            S.current.setting_night_mode_hint,
                            style: hintTextStyle,
                          ))
                    ],
                  ),
                  Expanded(child: Text('')),
                  Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Switch(
                        value: pref.nightMode.value,
                        onChanged: (value) {
                          setState(() => pref.nightMode.value = value);
                          Provider.of<ScheduleNotifier>(context, listen: false)
                              .nightMode = value;
                        },
                        activeColor: Color.fromRGBO(105, 109, 127, 1),
                        inactiveThumbColor: Color.fromRGBO(205, 206, 212, 1),
                        activeTrackColor: Color.fromRGBO(240, 241, 242, 1),
                        inactiveTrackColor: Color.fromRGBO(240, 241, 242, 1),
                      ))
                ],
              ),
            ),
          ),
          Container(
              padding: const EdgeInsets.fromLTRB(20, 17, 20, 5),
              alignment: Alignment.centerLeft,
              child: Text(S.current.schedule, style: titleTextStyle)),
          Container(
            height: 80,
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9)),
              child: InkWell(
                onTap: () =>
                    Navigator.pushNamed(context, AuthRouter.scheduleSetting)
                        .then((_) {
                  /// 使用pop返回此页面时进行rebuild
                  this.setState(() {});
                }),
                splashFactory: InkRipple.splashFactory,
                borderRadius: BorderRadius.circular(9),
                child: Row(
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 150,
                            margin: const EdgeInsets.only(left: 15),
                            child: Text(S.current.setting_day_number,
                                style: mainTextStyle)),
                        Container(
                            width: 150,
                            margin: const EdgeInsets.only(left: 15, top: 3),
                            child: Text('${pref.dayNumber.value}',
                                style: hintTextStyle))
                      ],
                    ),
                    Expanded(child: Text('')),
                    Padding(
                        padding: const EdgeInsets.only(right: 26), child: arrow)
                  ],
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
              child: Row(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: 210,
                              margin: const EdgeInsets.only(left: 15),
                              child: Text(S.current.setting_other_week,
                                  style: mainTextStyle)),
                          Container(
                              width: 210,
                              margin: const EdgeInsets.only(left: 15, top: 3),
                              child: Text(S.current.setting_other_week_hint,
                                  style: hintTextStyle))
                        ],
                      ),
                    ],
                  ),
                  Expanded(child: Text('')),
                  Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Switch(
                        value: pref.otherWeekSchedule.value,
                        onChanged: (value) {
                          setState(() => pref.otherWeekSchedule.value = value);
                        },
                        activeColor: Color.fromRGBO(105, 109, 127, 1),
                        inactiveThumbColor: Color.fromRGBO(205, 206, 212, 1),
                        activeTrackColor: Color.fromRGBO(240, 241, 242, 1),
                        inactiveTrackColor: Color.fromRGBO(240, 241, 242, 1),
                      ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
